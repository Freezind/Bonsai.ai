#!/usr/bin/env python3
"""Local Bonsai agent bridge.

POST /generate  {"intent": "..."}  ->  {"dsl": "<rfwtxt>", "latency_ms": N}

Runs headless Claude Code (`claude -p`) with the component-pool system prompt,
returns the rfw text the model produced. Dev-loop only: runs on the Mac; the
device reaches it via `adb reverse tcp:8787 tcp:8787`.

Uses the local `claude` login (subscription) — no API key here.
"""
import hashlib
import json
import os
import re
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HERE = os.path.dirname(os.path.abspath(__file__))
SYSTEM_PROMPT = open(os.path.join(HERE, "system_prompt.txt"), encoding="utf-8").read()
PORT = int(os.environ.get("BONSAI_BRIDGE_PORT", "8787"))
# Economy: e.g. BONSAI_BRIDGE_MODEL=haiku — DSL generation is a small task.
MODEL = os.environ.get("BONSAI_BRIDGE_MODEL", "")

# Bridge-side persistent cache: an intent is generated once, ever — survives
# app reinstalls and serves every device on the LAN. Keyed on prompt+intent
# so editing system_prompt.txt naturally invalidates old entries.
# BONSAI_CACHE picks the cache FILE (per user profile: cache.jobhunt.json /
# cache.health.json) so personas never overwrite each other; timeline
# evolution (day1 -> day90) overwrites within one profile's file by design.
CACHE_PATH = os.path.join(HERE, os.environ.get("BONSAI_CACHE", "cache.json"))
_cache_lock = threading.Lock()
try:
    with open(CACHE_PATH, encoding="utf-8") as f:
        CACHE = json.load(f)
except (OSError, json.JSONDecodeError):
    CACHE = {}


# ---------------- Context pack (the "data axis") ----------------
# BONSAI_CONTEXT points at the user's context snapshot (.json, or .jsonl whose
# lines are deep-merged). It is injected into every generation TASK prompt —
# deliberately NOT into the system prompt: the cache key is
# sha1(SYSTEM_PROMPT + intent), so keeping the system prompt stable lets
# warm.py --evolve re-generate ONLY the context-sensitive screens (force=true)
# while every other screen stays a cache hit.
CONTEXT_PATH = os.environ.get("BONSAI_CONTEXT", "")


def _merge(base, extra):
    """Deep-merge for jsonl packs: dicts recurse, lists concat, rest overwrite."""
    if isinstance(base, dict) and isinstance(extra, dict):
        out = dict(base)
        for k, v in extra.items():
            out[k] = _merge(out[k], v) if k in out else v
        return out
    if isinstance(base, list) and isinstance(extra, list):
        return base + extra
    return extra


def _load_pack(path: str):
    with open(path, encoding="utf-8") as f:
        text = f.read()
    if path.endswith(".jsonl"):
        pack = {}
        for line in text.splitlines():
            line = line.strip()
            if line:
                pack = _merge(pack, json.loads(line))
        return pack
    return json.loads(text)


CONTEXT_PACK = _load_pack(CONTEXT_PATH) if CONTEXT_PATH else None

CONTEXT_RULES = """
USER CONTEXT — the person this app is generated for. The JSON snapshot below
is the ONLY source of names, numbers, streaks and copy: never invent data.

Widget language (persona-driven slot filling):
- Process/pipeline personas (e.g. a job hunt: applications moving through
  stages) -> Stepper, StatusTable/StatusRow, CheckItem, Stat, Timeline.
- Metric personas (e.g. health: vitals tracked over days) -> BarChart,
  ProgressRing, Stat (with delta), HabitHeatmap.

Assistant posture (from ai.* + timeline.familiarity):
- ai.pending_confirmations non-empty and familiarity low -> the AI is still
  LEARNING: render (a) a confirmation slot — Alert(severity: "info") headed
  "Needs your input" with each question as a ListItem whose onTap navigates
  to a triage/confirm screen; and (b) a LOCKED slot — a Card with
  Ico(name: "lock"), ProgressRing(value: <familiarity>), and copy such as
  "AI needs more time with you to unlock proactive suggestions".
- ai.suggestions / ai.lessons non-empty -> the AI is TRUSTED: the SAME slot
  positions render proactive output instead — a Banner (what the AI already
  organized), the reordered priorities as a list, and every lessons[] entry
  as an Alert carrying its severity (these are lessons learned from the
  user's own past behavior).

Layout skeleton — IDENTICAL across personas and days; only the widgets
INSIDE the slots change:
  AppBar (greeting) -> assistant slot(s) -> primary metrics Row ->
  main content section(s) -> quick-capture Fab.

Hard rules (apply to EVERY generated screen):
- EVERY ListItem carries an onTap (navigate to a screen this graph/bundle
  defines, or reuse an already-declared link target verbatim). No bare rows.
- Each metrics[] series renders as a BarChart(values, labels) DIRECTLY on
  the first view — the readings must be visible without navigating.
- A PROJECT's variable region reflects the project's NATURE: a staged
  process (e.g. applications moving through stages) renders as Stepper +
  StatusTable; metric-driven work renders as BarChart + Stat + ProgressRing.
  The same rule shapes the highlighted project on the first view.
- ai.briefing non-null -> render a "Today's briefing" Card near the top of
  the first view (below the assistant slot): its items as ListItems with a
  clock/bell Ico. ai.briefing null AND familiarity low -> the LOCKED slot's
  copy mentions it: "Daily briefing unlocks as I get to know your rhythm."

CONTEXT SNAPSHOT:
"""


def _context_block() -> str:
    if not CONTEXT_PACK:
        return ""
    return CONTEXT_RULES + json.dumps(CONTEXT_PACK, ensure_ascii=False, indent=1) + "\n\n"


def _nth(seq, i, default=None):
    return seq[i] if isinstance(seq, list) and len(seq) > i else (default or {})


def ui_data() -> dict:
    """CONTEXT_PACK -> the FIXED data schema the Dart templates bind to.
    The mapping lives here so pack-schema changes never touch the client:
    templates bind data.p1/p2, data.area1..3, data.res1..3, data.habit1..3,
    data.stats — always fully populated (padded with neutral text)."""
    p = CONTEXT_PACK or {}
    ai = p.get("ai", {})
    projects = p.get("projects", [])
    areas = p.get("areas", [])
    habits = p.get("habits", [])
    resources = p.get("resources", [])
    archived = p.get("archived", [])

    def project(i):
        pr = _nth(projects, i)
        prog = float(pr.get("progress", 0.0))
        return {
            "title": pr.get("title", "No project yet"),
            "subtitle": pr.get("next_action", "Capture one to get started"),
            "headline": pr.get("next_action", "Nothing in flight"),
            "status": pr.get("status", "foundation"),
            "progress": prog,
            "percent": f"{int(prog * 100)}%",
            "tasks": f'{pr.get("tasks_done", 0)}/{pr.get("tasks_total", 0)}',
        }

    def area(i):
        a = _nth(areas, i)
        return {
            "title": a.get("title", "—"),
            "subtitle": a.get("subtitle", ""),
            "status": a.get("status", "foundation"),
        }

    def habit(i):
        h = _nth(habits, i)
        return {
            "label": h.get("label", "—"),
            "days": h.get("week", "e,e,e,e,e,e,e"),
            "streak": str(h.get("streak_days", 0)) + "d",
        }

    def item(seq, i, fallback):
        it = _nth(seq, i)
        return {"title": it.get("title", fallback), "subtitle": it.get("subtitle", "")}

    active = sum(1 for x in projects if x.get("status") == "actionable")
    return {
        "user": {"headline": p.get("persona", {}).get("headline", "Welcome to Bonsai")},
        # Alias for the built-in fallback dashboard (kConceptDsl binds data.project.*).
        "project": project(0),
        "stats": {
            "active": str(active),
            "blocked": str(sum(1 for x in projects if x.get("status") in ("blocked", "blocker"))),
            "inbox": str(p.get("inbox", {}).get("count", 0)),
        },
        "p1": project(0),
        "p2": project(1),
        "area1": area(0), "area2": area(1), "area3": area(2),
        "habit1": habit(0), "habit2": habit(1), "habit3": habit(2),
        "res1": item(resources, 0, "Save your first resource"),
        "res2": item(resources, 1, "Articles, talks and links land here"),
        "res3": item(resources, 2, "Tag them for a future you"),
        "arc1": item(archived, 0, "Nothing archived yet"),
        "arc2": item(archived, 1, "Finished work rests here"),
    }


LEAF_ADDENDUM = """

LEAF SCREEN (CRITICAL): this screen sits at the app's MAXIMUM depth — it is a
fully CLOSED leaf. It must NOT contain any `event "navigate" { intent: ... }`
link (nothing may open a deeper screen). Every control is still interactive:
- state controls (CheckItem/Switch/MoodOption/Slider) use toggle/mood events;
- a Save button persists edits (event "save" { ... });
- the AppBar carries onBack: event "back" { };
- routes (dashboard/projects/areas/resources/archive/habits/mood/
  project-detail) are allowed.
Design it so the user needs nothing deeper: complete detail, complete actions."""


def _cache_key(intent: str) -> str:
    # ONE key per intent — the app always fetches by plain intent, so leaf-ness
    # must never fork the key (it only shapes the generation prompt).
    return hashlib.sha1((SYSTEM_PROMPT + "\x00" + intent).encode("utf-8")).hexdigest()


def _extract_dsl(text: str) -> str:
    """Strip code fences / stray prose; keep from first import to last `);`."""
    t = text.strip()
    t = re.sub(r"^```[a-zA-Z]*\n?", "", t)
    t = re.sub(r"\n?```$", "", t).strip()
    start = t.find("import ")
    end = t.rfind(");")
    if start != -1 and end != -1:
        t = t[start:end + 2]
    return t.strip()


BUNDLE_ADDENDUM = """

BUNDLE MODE (CRITICAL): you will output MULTIPLE screens in ONE reply.
Format — repeat this for every screen, with NOTHING else between sections:
=== screen: <id> ===
<the rfw text for that screen: the two imports + one `widget root = ...;`>

Rules:
- A screen's <id> is EXACTLY the intent string used to open it (copy the
  required ids verbatim; invent concise ids for screens you add).
- CLOSURE: every `event "navigate" { intent: "X" }` inside ANY screen of the
  bundle must have X equal to a screen id defined in THIS bundle. No stray
  links. Routes (dashboard/projects/areas/resources/archive/habits/mood/
  project-detail) are always fine.
- Respect the depth budget in the task; the DEEPEST screens are leaves:
  fully interactive (toggle/mood/save/back) but ZERO intent links.
- Keep every screen compact (roughly 40-60 lines of rfw text)."""

BUNDLE_HEADER_RE = re.compile(r"^===\s*screen:\s*(.+?)\s*===\s*$", re.MULTILINE)

EDIT_ADDENDUM = """

EDIT MODE (CRITICAL): you are EDITING an existing screen, not designing a new
one. You get the CURRENT rfw text and ONE user request. Apply ONLY what the
request asks for; every other widget, every copy string, every event and
every intent link stays byte-identical. If the request implies new content
(e.g. "create a project"), add it in the style of the existing screen using
only pool widgets, wiring interactions with the screen's existing intents,
routes, or state events — never a brand-new intent. Output the FULL modified
rfw text (imports + one `widget root`), nothing else."""

PLAN_ADDENDUM = """

PLAN MODE (CRITICAL): do NOT output rfw text. Output ONE strict JSON object —
no prose, no markdown fences — describing the app's NAVIGATION GRAPH:

{
  "screens": [
    {
      "id": "<the intent string that opens this screen>",
      "tab": "home|projects|areas|resources|archive",
      "depth": 1,
      "title": "<screen title>",
      "purpose": "<one line: what the user accomplishes here>",
      "links": [
        {"control": "<which control carries the link, e.g. Button 'Open log'>",
         "to": "<id of another screen in THIS graph>"}
      ],
      "interactions": [
        {"control": "<e.g. CheckItem 'Meditate 10 minutes'>",
         "event": "toggle|mood|save|back"}
      ]
    }
  ]
}

Rules:
- Every REQUIRED id given in the task must appear as a screen, verbatim.
- Every "to" must reference an id defined in this graph. No dangling targets.
- depth is 0..3 (0 is ONLY for a tab-root screen the task explicitly requires,
  e.g. "first-view"); a link goes from depth N to N+1 only.
- depth-3 screens are LEAVES: "links" MUST be [] — but their "interactions"
  must be COMPLETE: enumerate EVERY control a user would expect to touch
  (checklists, switches, mood options, sliders, a Save button, back).
  Do not leave an interactive-looking control without an action.
- Non-leaf screens also list their interactions (at minimum back on
  sub-screens; Save wherever there are state controls).
- Keep the graph BUDGETED: prefer few, purposeful screens over sprawl."""


def generate_edit(intent: str, instruction: str, current: str) -> dict:
    """One claude call: current screen + user request -> modified screen.
    Overwrites the screen's cache entry so the edit persists across fetches."""
    t0 = time.time()
    cmd = [
        "claude", "-p",
        "--output-format", "json",
        "--append-system-prompt", SYSTEM_PROMPT + EDIT_ADDENDUM,
    ]
    if MODEL:
        cmd += ["--model", MODEL]
    task = (_context_block()
            + f"CURRENT SCREEN (id: {intent}):\n{current}\n\n"
            + f"USER REQUEST: {instruction}\n\n"
            + "Output the full modified rfw text now.")
    cmd.append(task)
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    latency = int((time.time() - t0) * 1000)
    if proc.returncode != 0:
        return {"error": f"claude exited {proc.returncode}: {proc.stderr[:400]}", "latency_ms": latency}
    try:
        raw = json.loads(proc.stdout).get("result", "")
    except json.JSONDecodeError:
        raw = proc.stdout
    dsl = _extract_dsl(raw)
    if "widget root" not in dsl:
        return {"error": "edit did not produce a root widget", "raw": raw[:600], "latency_ms": latency}
    with _cache_lock:
        CACHE[_cache_key(intent)] = dsl
        try:
            with open(CACHE_PATH, "w", encoding="utf-8") as f:
                json.dump(CACHE, f)
        except OSError:
            pass
    return {"dsl": dsl, "latency_ms": latency}


def generate_plan(spec: str) -> dict:
    """One claude call -> the navigation-graph JSON (not cached; caller saves)."""
    t0 = time.time()
    cmd = [
        "claude", "-p",
        "--output-format", "json",
        "--append-system-prompt", SYSTEM_PROMPT + PLAN_ADDENDUM,
    ]
    if MODEL:
        cmd += ["--model", MODEL]
    cmd.append(_context_block() + spec)
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    latency = int((time.time() - t0) * 1000)
    if proc.returncode != 0:
        return {"error": f"claude exited {proc.returncode}: {proc.stderr[:400]}", "latency_ms": latency}
    try:
        raw = json.loads(proc.stdout).get("result", "")
    except json.JSONDecodeError:
        raw = proc.stdout
    text = raw.strip()
    text = re.sub(r"^```[a-zA-Z]*\n?", "", text)
    text = re.sub(r"\n?```$", "", text).strip()
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end == -1:
        return {"error": "no JSON object in plan reply", "raw": raw[:600], "latency_ms": latency}
    try:
        graph = json.loads(text[start:end + 1])
    except json.JSONDecodeError as e:
        return {"error": f"plan JSON invalid: {e}", "raw": text[:600], "latency_ms": latency}
    return {"graph": graph, "latency_ms": latency}


def split_bundle(raw: str) -> dict:
    """-> {screen_id: dsl} for every well-formed section."""
    out = {}
    matches = list(BUNDLE_HEADER_RE.finditer(raw))
    for i, m in enumerate(matches):
        end = matches[i + 1].start() if i + 1 < len(matches) else len(raw)
        dsl = _extract_dsl(raw[m.end():end])
        if "widget root" in dsl:
            out[m.group(1)] = dsl
    return out


def generate_bundle(spec: str) -> dict:
    """One claude call -> many screens, each cached under its own id."""
    t0 = time.time()
    cmd = [
        "claude", "-p",
        "--output-format", "json",
        "--append-system-prompt", SYSTEM_PROMPT + BUNDLE_ADDENDUM,
    ]
    if MODEL:
        cmd += ["--model", MODEL]
    cmd.append(_context_block() + spec)
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    latency = int((time.time() - t0) * 1000)
    if proc.returncode != 0:
        return {"error": f"claude exited {proc.returncode}: {proc.stderr[:400]}", "latency_ms": latency}
    try:
        raw = json.loads(proc.stdout).get("result", "")
    except json.JSONDecodeError:
        raw = proc.stdout
    screens = split_bundle(raw)
    if not screens:
        return {"error": "no well-formed screens in bundle", "raw": raw[:600], "latency_ms": latency}
    with _cache_lock:
        for sid, dsl in screens.items():
            CACHE[_cache_key(sid)] = dsl
        try:
            with open(CACHE_PATH, "w", encoding="utf-8") as f:
                json.dump(CACHE, f)
        except OSError:
            pass
    return {"screens": sorted(screens), "count": len(screens), "latency_ms": latency}


# In-flight dedupe: a client retry (fresh connection) while claude is still
# generating the same intent must WAIT for that run, never start a second one.
_inflight: dict = {}


def generate(intent: str, leaf: bool = False, spec: str = "", force: bool = False) -> dict:
    key = _cache_key(intent)
    with _cache_lock:
        hit = None if force else CACHE.get(key)
        if hit:
            return {"dsl": hit, "latency_ms": 0, "cached": True}
        ev = _inflight.get(key)
        if ev is None:
            ev = threading.Event()
            _inflight[key] = ev
            owner = True
        else:
            owner = False

    if not owner:
        print(f"  (joining in-flight generation)")
        ev.wait(timeout=190)
        with _cache_lock:
            hit = CACHE.get(key)
        if hit:
            return {"dsl": hit, "latency_ms": 0, "cached": True}
        return {"error": "in-flight generation failed or timed out"}

    try:
        return _generate_owner(intent, key, leaf, spec)
    finally:
        with _cache_lock:
            _inflight.pop(key, None)
        ev.set()


def _generate_owner(intent: str, key: str, leaf: bool = False, spec: str = "") -> dict:
    t0 = time.time()
    cmd = [
        "claude", "-p",
        "--output-format", "json",
        "--append-system-prompt", SYSTEM_PROMPT + (LEAF_ADDENDUM if leaf else ""),
    ]
    if MODEL:
        cmd += ["--model", MODEL]
    task = _context_block() + f"User intent: {intent}"
    if spec:
        task += f"\n\nEXACT SPECIFICATION for this screen (follow it precisely):\n{spec}"
    cmd.append(task + "\n\nOutput the rfw text for this screen now.")
    # 300s: a context-pack screen (rich pack + exact spec + evolve note) can
    # legitimately take >180s; the in-flight dedupe protects against pileups.
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    latency = int((time.time() - t0) * 1000)
    if proc.returncode != 0:
        return {"error": f"claude exited {proc.returncode}: {proc.stderr[:400]}", "latency_ms": latency}
    try:
        payload = json.loads(proc.stdout)
        raw = payload.get("result", "")
    except json.JSONDecodeError:
        raw = proc.stdout
    dsl = _extract_dsl(raw)
    if "widget root" not in dsl:
        return {"error": "model did not produce a root widget", "raw": raw[:600], "latency_ms": latency}
    with _cache_lock:
        CACHE[key] = dsl
        try:
            with open(CACHE_PATH, "w", encoding="utf-8") as f:
                json.dump(CACHE, f)
        except OSError:
            pass
    return {"dsl": dsl, "latency_ms": latency}


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, obj):
        body = json.dumps(obj).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path != "/generate":
            return self._send(404, {"error": "not found"})
        n = int(self.headers.get("Content-Length", "0"))
        try:
            req = json.loads(self.rfile.read(n) or b"{}")
        except json.JSONDecodeError:
            return self._send(400, {"error": "bad json"})
        if req.get("info"):  # which profile/cache is this bridge serving?
            return self._send(200, {
                "profile": CONTEXT_PACK.get("profile_id") if CONTEXT_PACK else None,
                "cache_file": os.path.basename(CACHE_PATH),
                "entries": len(CACHE),
            })
        if req.get("data"):  # the UI data blob the app injects into templates
            return self._send(200, {"data": ui_data(),
                                     "profile": CONTEXT_PACK.get("profile_id") if CONTEXT_PACK else None})
        intent = (req.get("intent") or "").strip()
        leaf = bool(req.get("leaf"))
        spec = (req.get("spec") or "").strip()
        force = bool(req.get("force"))
        if not intent:
            return self._send(400, {"error": "empty intent"})
        if req.get("peek"):  # cache lookup only — never generates
            with _cache_lock:
                hit = CACHE.get(_cache_key(intent))
            return self._send(200, {"dsl": hit, "cached": hit is not None} if hit
                              else {"cached": False})
        if req.get("edit"):  # robot chat: modify ONE screen per user request
            instruction = (req.get("instruction") or "").strip()
            current = (req.get("current") or "").strip()
            if not instruction or not current:
                return self._send(400, {"error": "edit needs instruction + current"})
            print(f"→ EDIT {intent[:40]!r}: {instruction[:80]!r}")
            try:
                result = generate_edit(intent, instruction, current)
            except subprocess.TimeoutExpired:
                result = {"error": "claude timed out"}
            print(f"← edit: {('ok ' + str(result.get('latency_ms')) + 'ms') if 'dsl' in result else result.get('error', '?')[:80]}")
            return self._send(200 if "dsl" in result else 502, result)
        if req.get("plan"):  # one call -> the navigation graph (JSON, uncached)
            print(f"→ PLAN: {intent[:80]!r}…")
            result = generate_plan(intent)
            print(f"← plan: {len(result.get('graph', {}).get('screens', []))} screens "
                  f"({result.get('latency_ms', 0)}ms) {result.get('error', '')}")
            return self._send(200 if "graph" in result else 502, result)
        if req.get("bundle"):  # one call -> many screens, split + cached here
            print(f"→ BUNDLE: {intent[:80]!r}…")
            result = generate_bundle(intent)
            print(f"← bundle: {result.get('count', 0)} screens "
                  f"({result.get('latency_ms', 0)}ms) {result.get('error', '')}")
            return self._send(200 if "screens" in result else 502, result)
        print(f"→ intent{' [leaf]' if leaf else ''}{' [spec]' if spec else ''}: {intent!r}")
        try:
            result = generate(intent, leaf, spec, force)
        except subprocess.TimeoutExpired:
            result = {"error": "claude timed out"}
        print(f"← {('ok ' + str(result.get('latency_ms')) + 'ms') if 'dsl' in result else result.get('error')}")
        # full DSL to a log file so any blank render can be inspected exactly
        try:
            with open(os.path.join(HERE, "dsl.log"), "a", encoding="utf-8") as f:
                f.write(f"\n===== {time.strftime('%H:%M:%S')}  intent: {intent}\n")
                f.write(result.get("dsl") or f"[ERROR] {result.get('error')}\n{result.get('raw','')}")
                f.write("\n")
        except OSError:
            pass
        self._send(200 if "dsl" in result else 502, result)

    def log_message(self, *a):  # quiet default logging
        pass


def _candidate_urls():
    """Every URL a phone on the same network could use to reach this bridge."""
    urls = []
    try:
        out = subprocess.run(["ifconfig"], capture_output=True, text=True).stdout
        for m in re.finditer(r"inet (\d+\.\d+\.\d+\.\d+)", out):
            ip = m.group(1)
            if not ip.startswith(("127.", "169.254.")):
                urls.append(f"http://{ip}:{PORT}")
    except OSError:
        pass
    try:
        host = subprocess.run(["scutil", "--get", "LocalHostName"],
                              capture_output=True, text=True).stdout.strip()
        if host:
            urls.append(f"http://{host}.local:{PORT}")
    except OSError:
        pass
    return urls


if __name__ == "__main__":
    print(f"Bonsai bridge on http://0.0.0.0:{PORT}  (POST /generate)")
    print(f"cache: {os.path.basename(CACHE_PATH)} · {len(CACHE)} entries · model: {MODEL or 'default'}")
    print(f"context: {CONTEXT_PATH or '(none — set BONSAI_CONTEXT=bridge/context/<profile>.json)'}"
          + (f" · profile: {CONTEXT_PACK.get('profile_id', '?')}" if CONTEXT_PACK else ""))
    print("Bridge URLs for the app (Debug page -> Bridge URL, then Test):")
    for url in _candidate_urls():
        print(f"  {url}")
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
