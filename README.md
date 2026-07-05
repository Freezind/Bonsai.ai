# Bonsai

> Fed by your life, tending it back.

Built for **c0mpiled in Japan pt.3** (2026-07-05), addressing YC RFS Summer 2026's [**Dynamic Software Interfaces**](https://www.ycombinator.com/rfs#dynamic-software-interfaces).

## Submission description

> Bonsai — fed by your life, tending it back. It's the Dynamic Software Interfaces thesis made concrete: say a goal in plain language, and an agent composes a living, native screen for it from a frozen, whitelisted component pool — structured DSL only, never code, rendered on-device. Every goal lives inside PARA (Projects, Areas, Resources, Archive), so your life's context is organized by purpose, not by which tool holds it. The interface isn't generated once: as a goal accumulates context, its screen evolves with it — a job hunt starts as a day-one checklist collecting missing context, and by day ninety has reorganized into a decision dashboard, the user's role shifting from feeding context to making decisions.

## The problem

Before AI, every user of a piece of software got the same interface — a theme, a view option, nothing more. YC's Ankit Gupta frames it directly: coding agents are now good enough that users can become their own forward deployed engineers, radically customizing the software they consume, as long as a software team ships the shared primitives underneath.

Bonsai takes that literally, and one step further: not just different people getting different interfaces, but the same person's every goal getting its own interface — because tools that hold your data (email, calendars, chat, Notion) never hold your goals, and a life organized by *tool* looks nothing like a life organized by *purpose*.

## What it is

Bonsai is a personal goal-operating system. Say a goal in plain language; an agent composes a living, native screen for it. Every goal lives inside PARA (Projects, Areas, Resources, Archive) — context is organized by purpose, not by which app happens to hold it — and each screen is built to push the user toward a decision, not just display information.

The interface isn't generated once and left to rot. As a goal accumulates context, its screen evolves with it: a job hunt starts as a confirmation checklist the user fills in, and by day ninety has reorganized itself into a decision dashboard — the user's role shifting from feeding context to just making the call.

Three parts:

- `lib/` — the Flutter app (Dart SDK ^3.9, Flutter 3.44.4)
- `bridge/` — a local Python bridge (`serve.py`, zero third-party dependencies) that drives a headless `claude -p` to generate DSL, using the developer's own Claude login (no API key)
- `design-system/` — the Aurora visual reference (HTML/CSS, not part of the build)

## Architecture: the model never writes code

Intent text → `AgentClient` posts to the bridge's `/generate` → the bridge appends `bridge/system_prompt.txt` and calls `claude -p` → the model returns **rfw DSL**, a structural description, never executable code → `applyDsl` parses it and renders against a **frozen, whitelisted component pool**. Parse failures keep the previous screen — the app never goes blank.

This is a capability lock, not a convenience: the model can only compose components from a pool the developers designed and shipped ahead of time (kept in sync across `lib/rfw_pool/local_widgets.dart`, `bridge/system_prompt.txt`, and `lib/ds/aurora_tokens.dart`). Rendering always happens on-device. That's the difference between a browser-sandbox demo and an architecture that can actually pass App Store review and ship to a consumer's phone.

Navigation is a closed, finite app (GoRouter `StatefulShellRoute`, 5 top-level tabs, max depth 3) — the model can hallucinate a deeper link and it simply won't work, enforced client-side. Three cache layers (bridge disk cache, on-device memory + disk cache, warm-up peek) mean every intent is generated once, ever, for its life.

## Why this isn't just [X]

**Not a one-shot AI app builder (vs. Lovable / v0 / Replit).** Those tools generate once and hand you a static artifact that starts decaying the moment it ships, same as any hand-written app. Bonsai's generation is a continuous process: as a goal's context changes, its screen changes with it. Day 90 and Day 1 are different interfaces, and the user never touched a line of code to get there. This isn't a full regeneration each time — the layout skeleton persists, only the content and controls evolve, so the user's spatial memory of "this is my app" survives.

**Structural safety, not a chatbot with a UI on top.** Every "AI-generates-UI" approach hits the same wall: arbitrary code execution doesn't clear App Store review or enterprise security audits. Bonsai's model only ever emits structure from a whitelisted pool; it never emits code, and rendering never leaves the device. That's the architecture that can actually ship to a stranger's phone, not a toy running in a browser sandbox.

**Goal-native, not tool-native (vs. ChatGPT / Notion).** ChatGPT gives advice but holds no goal state — every conversation starts from zero. Notion and calendars hold data but don't advance anything — they're warehouses, not engines. Bonsai organizes context by purpose and has the agent actively push the goal forward: a Day 1 screen that asks the user for the context it's missing, evolving into a Day 90 screen that hands the user a short list of decisions. A goal deserves its own interface — a blood sugar trend should be a chart, a job search should be a pipeline, and a chat bubble expresses neither well.

**Not just an Obsidian/Notion setup with AI bolted on.** This is the comparison worth taking seriously, because it's the closest existing thing. Obsidian's Dataview/Bases ecosystem already turns notes into a "living dashboard" — but that's a *query language*: someone has to know how to write the Dataview query and wire up the Templater template. The AI can help write that query, but the person doing it is still acting as their own forward deployed engineer, and the responsibility for maintaining that configuration never leaves them. Making it work well requires two separate scarce skills at once — the engineering skill to write and automate the query/hook/cronjob layer, and the product judgment to know what structure, view, and priority actually fits a given goal (a forward deployed PM's skill, not just an engineer's). Installing an AI-augmented note-taking setup doesn't hand a random user either skill.

A concrete instance of this: an "AI summarizes my periodic notes onto my home note" setup is functionally the same insight as Bonsai's nightly "dream" feature below — but the Obsidian version requires someone to write the cron job, decide what to summarize, and design how it's surfaced. Bonsai ships that behavior natively; nobody has to build the pipeline. Same insight, two very different bars to clear to get it.

**A real native app, not a browser mockup.** In a 5-hour hackathon, most teams ship a web mockup or a chat wrapper. This is a Flutter app running on a real iPhone: tab navigation, native feel, offline-capable cached screens, three-tier caching that makes everything open instantly. This isn't the headline pitch — it's the texture that makes every other claim credible, because it's on camera in the demo video rather than argued for in prose.

### On the roadmap, not in this build

- **iOS HealthKit integration.** The Health area is designed to pull sleep, steps, and other signals directly into a goal's context automatically — proving "tools hold your data, Bonsai holds your goals" as fact rather than assertion. Post-hackathon work; the demo uses mock data (`kMockData`) for this screen, which is intentional for a PoC.
- **Nightly "dream."** The app analyzes accumulated context overnight (e.g. correlating sleep data with a user's self-reported state) and surfaces an insight card in the morning — the clearest demonstration of "the user only makes decisions; the app does the thinking." *"Bonsai dreams while you sleep."*

## Moat: staying at a 20-degree angle from model vendors

Model vendors (Anthropic, OpenAI) build a horizontal layer — general agent capability sold to everyone. Bonsai is vertical: a personal goal operating system. The model is a supplier, not a competitor — the bridge uses `claude -p` today and could swap models tomorrow without changing the pitch.

The moat isn't in the model, it's around it — three things a model vendor has no reason to build:

1. **The goal-context organization layer.** A user's life context accumulates structured by purpose, not by tool. That's a data asset, not a model capability.
2. **The frozen component pool / design system.** RFS says software companies will "ship shared primitives" — that's a product company's job (design taste + domain components), not something a model vendor is incentivized to build for any one vertical.
3. **Accumulated personalization.** Day 90 is worth more than Day 1 because 90 days of context and decision history live inside that goal. Switching cost rises over time.

Model progress is tailwind, not threat: a stronger model means better DSL generation at lower cost, for free. If Anthropic ships something like Claude Artifacts, that's a one-off UI in a browser sandbox with no goal state, no evolution, and no native distribution — the same relationship Shopify has with AWS: use the compute, own the vertical it doesn't build.

## Business model & global market

Consumer subscription for the personal-OS product near-term; the second act is a developer-facing primitives platform — domain teams ship component pools, users' agents compose them ("Shopify for personal apps").

Goal management is universal, and because every interface is generated rather than translated, Bonsai ships to every language and culture on day one — localization is a side effect of the architecture, not a separate workstream.

## Commands

```bash
flutter pub get
flutter test                          # full suite
flutter test test/widget_test.dart    # single file
flutter analyze                       # flutter_lints rules

# run the bridge first, on a Mac
python3 bridge/serve.py               # port 8787; see serve.py header for env overrides
python3 bridge/warm.py [--extra N]    # pre-generate the whole closed app, idempotent

# on-device
adb reverse tcp:8787 tcp:8787         # Android emulator/device
flutter run --dart-define=BRIDGE_URL=http://<mac-lan-ip>:8787   # physical iOS device
```

The bridge URL can also be changed at runtime from the app's Debug page. On generation failure, the full DSL is appended to `bridge/dsl.log`.

See `AGENTS.md` for full engineering documentation (data flow, iOS `await` deadlock workarounds, caching internals, DSL protocol).
