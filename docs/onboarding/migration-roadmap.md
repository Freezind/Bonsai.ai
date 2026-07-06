# Onboarding Development Roadmap

Status: PLANNED (2026-07-05)
Scope: implementation roadmap for the onboarding flow ("plant a seed") + the 5-tab app skeleton. Product design follows `docs/onboarding-flow-design.md` (APPROVED); screen details are in `docs/onboarding/page-spec.md`; the task checklist is in `docs/onboarding/todo.md`.
Visual reference: **Fresh Matcha design system** (`design-system/`, Fresh Matcha theme) + mascot Lottie (`design-system/lottie/bonsai-*.json`).

## Guiding principles

- **Onboarding is entirely native Dart**, no DSL. The AI bridge does three things: generating follow-up questions in real time, final classification, and generating the first goal dashboard (the dashboard is rfw DSL, rendered by the reveal screen).
- **App skeleton = 5 tabs** (Home / Projects / Areas / Resources / Archive), GoRouter `StatefulShellRoute` tab stacks. The skeleton does **not** hook up DSL this phase; tab roots are native empty pages; bridge integration comes with the main app body work.
- **Keep state management simple**: ValueNotifier + singletons, the same convention as the ScreenStore/rfw layer. Do not introduce new frameworks like riverpod/hooks.
- **iOS I/O iron rules** (must be followed; we have been burned by this repeatedly):
  - All dart:io network/file I/O goes inside `Isolate.run`
  - To take a result from a shared Future, use `.then` + `Timer.run` to hand it off manually to a Completer; never `await sharedFuture` directly
  - The root widget keeps a persistent 2-second keep-alive Timer to keep the event loop awake (note: onboarding exists before the shell, so the Timer must live at the root of main.dart, not in ShellScaffold)
- goal ≡ project/area (synonyms; docs consistently use "goal").

## Target lib/ structure

```
lib/
  main.dart                      # BonsaiApp; await AppPrefs.init() before runApp; root keep-alive Timer
  app/
    router.dart                  # GoRouter StatefulShellRoute, 5 tab branches + top-level onboarding routes + redirect gating
    shell_scaffold.dart          # shell chrome (top bar wordmark, robot icon, bottom tab bar)
    tab_root_page.dart           # native empty tab root (empty state + "+ seed" button + goal card list)
  ds/
    matcha_tokens.dart           # Fresh Matcha design system tokens (Fresh Matcha values + mascot palette)
  bridge/
    bridge_client.dart           # bridge HTTP client (fully wrapped in Isolate.run), with nextQuestion()/conclude() onboarding methods
  state/
    app_prefs.dart               # AppPrefs singleton: firstRunComplete / coachMarkSeen / goal registry; reads/writes bonsai_state.json via Isolate.run
  goals/
    goal.dart                    # Goal {id, title, kind: project|area, intent, status: growing|ready}
    goal_dashboard_page.dart     # reveal destination: renders the bridge-generated dashboard DSL; native Still-growing placeholder
    goal_dashboard_store.dart    # fetches DSL + silent retry backoff
  onboarding/
    seed_flow_state.dart         # sealed state machine states
    seed_flow_controller.dart    # ValueNotifier<SeedFlowState> + async submitAnswer()
    scripted_fallback.dart       # scripted questions (branched by entry) + local classification fallback
    ui/
      splash_page.dart           # S1 splash screen (first-run only)
      conversation_page.dart     # S2 conversation
      growing_page.dart          # S3 growing loading
      widgets/                   # bubbles, typing indicator, copy carousel, mascot Lottie container
  screens/
    screen_store.dart            # DSL cache (memory + disk) + in-flight dedupe (moved in during Phase 5)
    agent_sheet.dart             # robot bottom sheet, adjust UI with bot (moved in during Phase 6)
  rfw_pool/
    pool_runtime.dart            # rfw Runtime construction + applyDsl (moved in during Phase 5)
    local_widgets.dart           # frozen component pool, rfw namespace bonsai.* (moved in during Phase 5)
```

## Architecture decisions

### D-A1 State management: ValueNotifier + singletons
New code follows the same convention as the existing layers: `SeedFlowController` holds a `ValueNotifier<SeedFlowState>`; the `AppPrefs` singleton holds `ValueNotifier`s and reads/writes `documents/bonsai_state.json` via Isolate.run (matching the ScreenStore disk pattern); pages = StatefulWidget + ValueListenableBuilder. No shared_preferences (its platform-channel Futures are unverified in this project against the iOS deadlock issue; file + Isolate.run is the proven path).

### D-A2 Routing and gating
Onboarding routes live **outside** the StatefulShellRoute:

```
/onboarding/splash      # S1, first-run only
/seed?entry=project|area  # S2 conversation
/seed/growing           # S3 loading
```

redirect reads `AppPrefs.instance.firstRunComplete` synchronously: not complete and not on an onboarding path → jump to `/onboarding/splash`. The flag flips only once, and all in-flow navigation is explicit `context.go(...)`, so no refreshListenable is needed. `+ seed` goes directly to `context.go('/seed?entry=area')`; the redirect no longer fires.

Reveal destination: each tab branch adds a child route `goal/:id` (e.g. `/projects/goal/job-hunt`, depth 1). reveal = `context.go('/projects/goal/job-hunt')` — branch switch + push in one step, and swiping back lands on the tab root (satisfying design doc D7/D9: the dashboard is the goal's own home page).

### D-A3 Bridge protocol extensions (extend POST /generate, no new endpoints)

**(a) Conversation turn `converse`** — the AI generates the next follow-up question in real time:

```json
POST /generate
{"converse": true, "entry": "project",
 "transcript": [
   {"role": "assistant", "text": "What's something you're working toward right now?"},
   {"role": "user", "text": "Finding a staff engineer job"}],
 "turn": 1}
→ 200 {"question": "What kind of role are you looking for?", "latency_ms": 4200}
```

New CONVERSE supplementary system prompt: output only a single short follow-up question; goal = reach the minimum information needed to "classify + generate a decent dashboard"; do not ask for private details; when the input is vague, use this turn to clarify. Plain text output, no DSL.

**(b) Final classification `conclude`** — returns within seconds, **does not generate the dashboard** (the classification bubble must appear before the loading screen):

```json
{"conclude": true, "entry": "project", "transcript": [ ...all 6 messages... ]}
→ 200 {"kind": "project", "title": "Job hunt", "slug": "job-hunt",
       "closing": "Got it — your job hunt is a Project: something with a finish line. Planting it now…",
       "intent": "goal:job-hunt", "latency_ms": 6100}
```

`kind` may differ from `entry` (the design doc's correction fallback); the closing copy comes from the model so a correction reads naturally. Strict JSON output, reusing the existing fence stripping / `{...}` extraction.

**(c) Dashboard generation — zero new protocol**, uses the existing intent channel:

```json
{"intent": "goal:job-hunt",
 "spec": "Dashboard for the goal 'Job hunt' (a PROJECT). Conversation:\n<transcript>\n...",
 "leaf": true}
```

Key point: `spec` injects the generation task but is **not part of the cache key** (existing mechanism), so `goal:<slug>` becomes a stable cache key — the three-layer cache, in-flight dedupe, and future warm tooling are all reused for free. `leaf: true` means the dashboard contains no drill-down intents (child page generation belongs to the main app body work); edit mode (robot sheet) still works as usual on leaf screens.

**Turn cache semantics**: `converse`/`conclude` results go into a separate **in-memory** TURN_CACHE (key = sha1(system + entry + transcript)), sharing the in-flight dedupe table, guaranteeing the client's 3 retries are idempotent (a retry after packet loss will not get a different question and will not rerun the model). Not persisted to disk — transcripts never recur across sessions, so cache.json stays unpolluted.

### D-A4 Conversation state machine

```
Opening → AwaitingAnswer(0) → AskingFollowUp(1) → AwaitingAnswer(1)
        → AskingFollowUp(2) → AwaitingAnswer(2) → Concluding
        → Classified → Growing → Revealed | GrowingFallback
```

- The number of follow-up turns (fixed at 2) is enforced by the client controller; we never ask the model "is that enough?" (design doc D5).
- **No persistence mid-conversation**: the conversation takes under a minute; if killed midway, just redo it (whether splash appears depends only on firstRunComplete).
- At `Classified`, two things are written atomically: `firstRunComplete = true` + the Goal (status: growing) enters the registry. From then on, being killed during loading recovers perfectly: restart → shell → the Projects tab has the goal card ("Still growing") → the fetch hits the bridge cache or joins the in-flight generation.

### D-A5 Degradation chain (step by step, mutually independent)

| Failure point | Behavior |
|---|---|
| A single converse turn fails (3 retries exhausted) | Switch to `scripted_fallback` scripted questions (2 questions branched by entry); the rest of the conversation stays scripted, no mixing |
| conclude fails / conversation already scripted | Local classification = entry type; title = first answer truncated to ~40 chars; slug deduped (append `-2` on collision); closing uses a fixed template |
| Dashboard generation fails / exceeds 90s | The flow completes as normal: the goal enters the registry in growing status, reveal navigates as usual, GoalDashboardPage renders a **native** Fresh Matcha placeholder (mascot thirsty Lottie + "Still growing — check back in a moment" card); silent retries at 10/30/60/120s, with in-flight dedupe guaranteeing a retry **joins** the ongoing generation rather than restarting it; on success the DSL is swapped in place and the status flips to ready |

Making the placeholder native (rather than an rfw template) is intentional — the template layer is not needed at all this phase.

### D-A6 Identifier conventions
- rfw component namespace: `bonsai.*` (capability lock kept in sync across three places: `lib/rfw_pool/local_widgets.dart` + `bridge/system_prompt.txt` + `lib/ds/matcha_tokens.dart`)
- App class: `BonsaiApp`; bridge env vars: `BONSAI_CONTEXT` / `BONSAI_CACHE`
- Persisted files: `bonsai_state.json` (prefs + goal registry), `dsl_cache.json` (DSL cache)

### D-A7 Tokens and assets
- `lib/ds/matcha_tokens.dart`, `class Matcha`, values = Fresh Matcha (`design-system/styles.css`): primary `#2C8248`, secondary `#2F7BB4`, accent `#F4B63C`, bg `#F6F4E9`, ink `#26302A`, etc.; the mascot palette (mLeaf `#3FA34D`, mPot `#E8703A`, mInk `#33302B`...) matches the values baked into the Lottie files.
- Signature elev-pop: `BoxShadow(offset: Offset(3,3), blurRadius: 0, color: ink)`.
- **Bundle fonts as TTF** (Baloo 2 display + Nunito body); no google_fonts runtime fetching (hotspot networking at the demo venue is unreliable). Patrick Hand is not needed this phase.
- Lottie: `design-system/lottie/bonsai-{idle,cheer,thirsty,sleep}.json` → `assets/lottie/`, loaded with the `lottie` package.

## Phased plan

| Phase | Content | Checkpoint (app runnable) | Risk |
|---|---|---|---|
| **0 Scaffold** | flutter create (Flutter 3.44.4 / Dart ^3.9); deps: `go_router ^16` `rfw ^1.1.3` `http` `path_provider` `lottie` (zero new state-management deps); Lottie + font assets into assets; analysis_options | `flutter run` shows an empty MaterialApp | Version drift; iOS signing |
| **1 Tokens + skeleton** | `matcha_tokens.dart` (Fresh Matcha values); `app/router.dart`: StatefulShellRoute with 5 branches, tab root = native empty page + `+ seed`; AppTab / DepthObserver / kMaxDepth mechanisms as usual; keep-alive Timer at the root of main.dart; `BonsaiApp` | 5 tabs render in Fresh Matcha, switching works, depth observer in place | Low; go_router 16 API alignment |
| **2 Bridge + ping** | `bridge/serve.py` + `system_prompt.txt` in place (env vars `BONSAI_*`, empty cache.json, namespace `bonsai.*` declared); `bridge_client.dart` (fully wrapped in Isolate.run + 3 retries + `--dart-define=BRIDGE_URL`); temporary status line shows the ping result | Empty-intent ping from a real device returns 400 | LAN reachability from the device; claude CLI login on the Mac |
| **3 Onboarding static** | Build all three S1/S2/S3 page UIs (**scripted questions only**, no bridge); `app_prefs.dart` + redirect gating; the flow ends at a stub page for now; copy carousel; mascot Lottie states | The full flow works offline; killing the process and restarting skips splash | All visual, no logic risk |
| **4 Conversation wiring** | serve.py `converse`/`conclude` modes + TURN_CACHE; `bridge_client.nextQuestion()`/`.conclude()`; controller switches between live/scripted per D-A5 | Real-time AI follow-ups on device; killing the bridge mid-conversation degrades seamlessly to script | Prompt tuning (question quality/latency); JSON extraction edge cases |
| **5 rfw subset + generation + reveal** | Move in `pool_runtime.dart` + `local_widgets.dart` (namespace `bonsai.*`, synced with system_prompt) + `screen_store.dart`; `GoalDashboardPage` (keep previous screen on parse failure, treat navigate as a no-op); the growing page sends `generate(goal:<slug>, spec, leaf)`; `goal/:id` child route; reveal navigation | Full seed → dashboard pipeline on device; on second launch the dashboard opens instantly from cache | **Peak risk**: iOS deadlock surface + rfw surface; mitigation = reuse the proven I/O patterns byte for byte |
| **6 Fallbacks + polish** | Still-growing placeholder + retry backoff; coach mark (one-time, `coachMarkSeen`); move in `agent_sheet.dart` (robot icon → bottom sheet); fully wire tab root `+ seed` + goal card list (registry-driven) | Full demo script: first-run plants a Project → `+` plants an Area → bot adjusts UI | Edit quality on generated dashboards; coach mark layering/timing |

Ordering rationale: Phase 3 comes before 4 — the demo gets an offline safety spine first, then AI enters the loop (hackathon fuse); Phase 5 is isolated on its own because it carries the entire iOS deadlock surface and the rfw surface.

## Out of scope this phase

- warm.py pre-generation / plan / bundle tooling (main app body development phase)
- Full template set and DSL-izing tab roots (skeleton keeps native empty pages)
- context packs / persona data (ScreenStore.uiData uses neutral defaults)
- Debug page (can be added in Phase 6 if debugging calls for it; half an hour of work)
- Child page drill-down generation (dashboards are generated as leaf, no intent links)
- Real GBrain / HealthKit integration (Resources tab keeps the kMockData connector cards)

## Acceptance (overall)

1. first-run: Splash → conversation (AI follow-ups) → classification disclosure → growing loading → land on the goal's own dashboard (rfw-rendered), coach mark once
2. Rerun with the bridge killed: scripted-question fallback, the whole flow completes, placeholder card + silent retry semantics correct
3. `+ seed` (Areas entry) re-enters the same flow, skips Splash, classifies as area
4. Restart the app: Splash never reappears; goal cards sit on the corresponding tab roots; dashboards open instantly from cache
5. `flutter analyze` is clean; tab depth/switching behavior matches the skeleton tests
