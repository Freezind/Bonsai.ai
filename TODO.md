# TODO

## Honest inventory: what is mocked, what ships next

> PoC boundary statement for the hackathon build. Everything that "moves" in
> the demo falls into one of three tiers.

### ✅ Real today (not mock)

- Onboarding conversation: follow-ups and classification are generated live by local claude (`converse`/`conclude`), including course correction (an area-shaped goal entered through the project branch gets reclassified)
- Full degradation chain when the bridge is unreachable (scripted questions → local classification → Still-growing placeholder + silent retries)
- On-device persistence of the goal registry and state; three-layer caching + in-flight dedupe
- rfw frozen-pool rendering (capability lock: the model emits structure only, never code)
- Design system, the mascot's five growth stages, the iOS I/O workaround patterns

### 🎭 Pure mock (demo theater — data and behavior are fake)

- [ ] **Home weekly digest (periodic note)**: the whole screen is hardcoded `DemoScenario` content (persona "Aya", `docs/demo-fake-data.md`). No real activity stream, no AI generation pipeline; the two "While you slept" decision buttons are dead → real version: a nightly job summarizes each goal's data through the bridge into the digest (PN4)
- [ ] **The Day-90 world**: the long-press on Home injects a fake goal set (2 P + 2 A). Tree growth stages are hand-assigned, not earned by real tending → real version: stages advance from actual behavior (check-ins, completed todos, digest continuity)
- [ ] **The four goal detail pages** (`kDemoDashboards` G1–G4): build-time rfw templates; companies, metrics and habit logs are all fictional → real version: see the fixed-frame pivot below
- [ ] **Resource connections**: the connect flow works end to end in the UI, but the GBrain "handshake" is a mocked pause — nothing is actually linked; HealthKit/Calendar/Mail/Notes are placeholders → real version: GBrain MCP reads + HealthKit authorization
- [ ] **The "bridge connected" status line**: hardcoded for clean recordings — it always reads connected (`bridge_client.dart` DEMO OVERRIDE) → revert the override, restore truthful status
- [ ] **The current device build is a recording build**: `RESET_STATE=true` wipes all state on every cold start — recording behavior, not product behavior; must be reinstalled without that dart-define before any handoff

### 🚧 Half real (the plumbing exists, but is superseded by the pivot or unfinished)

- [ ] **Implement the fixed-frame pivot** (decided, not built): dashboards = build-time rfw templates + `data.*` bindings; the AI only makes bounded adjustments — **list reorder/add/remove** and **widget-form switching within predefined slots** (Ring↔Bar↔Stepper). The bot sheet's edit still uses the old whole-screen DSL rewrite path and must be narrowed to data/config-layer output
- [ ] **`conclude` also extracts initial data**: at classification, have the AI emit an initial dashboard data JSON (next steps, stage) to fill the fixed frame; the growing screen becomes a 2–3s animation (no more waiting on whole-screen generation)
- [ ] **Gardener quick actions**: the four suggestions are canned; they should be generated from the screen currently on stage
- [ ] **Sub-page navigation**: dashboards are all leaves today; `navigate` is a no-op → wire up in the main-body phase (closed subtrees, depth ≤ 3)
- [ ] **The data axis**: `ScreenStore.uiData` is neutral defaults; the context-pack/persona data flow is not connected
- [ ] **Archive tab**: placeholder empty page
- [ ] **Mascot animations**: 4 of the 11 specified Lotties exist (idle/cheer/thirsty/sleep); in-app growth uses SVG cross-fades as a stand-in → complete per `design-system/motion-lottie.md` (plant_seed/grow_up/bloom/fruit/wither/water_revive/generating)
- [ ] **Device checkpoints**: the 4 on-device checkpoints in `docs/onboarding/todo.md` (mostly exercised today — check off with notes)

- [ ] **Write the second-by-second shot-by-shot script** (Approach A "one life, one living app", 83s budget: hook 8s → Day1 18s → Day90 24s → intent generation 18s → comparison + close 15s; each shot = visuals + English voiceover lines) -- based on the approved design doc `docs/demo-design-90s.md`; backfill the format after the organizers announce the submission rules at 10:35
- [ ] The Assignment: rough cut the Day 1 → Day 90 evolution segment, show it to someone who has never seen the project, and have them restate it in one sentence -- validates whether the narrative holds

- [ ] Study the 90-second demo videos of past winning c0mpiled teams (structure, pacing, how to cover problem → demo → market in 90 seconds)
  - Lead: the organizers' past-event highlights page https://www.notion.so/melts/Transpose-x-OUVC-YC-367903bd64b8807a9bbafc9a07c50a80
  - Lead: the Tokyo event c0mpiled-7 / San Fransokyo (2026-03-08, Toranomon Hills) detail page https://melts.notion.site/Transpose-IPC-YC-2-305903bd64b88088a162e8e9ff8682cd -- the rules were likewise "90-second video, judges only see the recorded deliverable", making it the most directly relevant reference
- [ ] Find winning 90-second demo videos from c0mpiled events in other countries/cities (this event is c0mpiled-12, Tokyo was c0mpiled-7; the series has run at least 12 events, so there should be winning entries from overseas events to reference)
