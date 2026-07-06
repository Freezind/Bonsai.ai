# Onboarding TODO

Maps to Phase 0–6 of `docs/onboarding/migration-roadmap.md`; screen details are governed by `docs/onboarding/page-spec.md`. Each item is independently verifiable; pass the phase checkpoint before checking items off.

## Phase 0 · Scaffold
- [x] flutter create (Flutter 3.44.4 / Dart ^3.9, written to .tool-versions)
- [x] pubspec deps: go_router ^16 / rfw ^1.1.3 / http / path_provider / lottie (no state management library)
- [x] `design-system/lottie/bonsai-*.json` → `assets/lottie/`; Baloo 2 + Nunito TTF → `assets/fonts/` + pubspec font declarations
- [x] analysis_options (flutter_lints)
- [x] Checkpoint: `flutter run` shows an empty MaterialApp; `flutter analyze` is clean

## Phase 1 · Tokens + 5-tab skeleton
- [x] `lib/ds/matcha_tokens.dart`: class Matcha, Fresh Matcha values + mascot palette + elev-pop constants + type scale (Baloo 2 / Nunito)
- [x] `lib/app/router.dart`: StatefulShellRoute.indexedStack, 5 branches (Home/Projects/Areas/Resources/Archive), AppTab / DepthObserver / kMaxDepth=3
- [x] `lib/app/shell_scaffold.dart` + `lib/app/tab_root_page.dart` (native empty pages + empty states; `+ seed` button placeholder)
- [x] `lib/main.dart`: BonsaiApp; root keep-alive Timer (2s, must live outside the shell)
- [x] Checkpoint: 5 tabs render in Fresh Matcha, switching resets to root, depth observer in place

## Phase 2 · Bridge + ping
- [x] `bridge/serve.py` + `bridge/system_prompt.txt` in place (env vars BONSAI_CONTEXT/BONSAI_CACHE; empty cache.json; component namespace `bonsai.*` declared)
- [x] `lib/bridge/bridge_client.dart`: everything wrapped in Isolate.run + 3 retries + `--dart-define=BRIDGE_URL`
- [x] Temporary status line: ping result visible inside the app
- [ ] Checkpoint: on a real device (adb reverse / LAN IP), an empty intent ping returns 400 (pending real device)

## Phase 3 · Onboarding UI (static, scripted questions)
- [x] `lib/state/app_prefs.dart`: singleton + ValueNotifier; Isolate.run reads/writes `documents/bonsai_state.json` (firstRunComplete / coachMarkSeen / goals)
- [x] router: `/onboarding/splash`, `/seed?entry=`, `/seed/growing` top-level routes + redirect gating
- [x] `lib/goals/goal.dart`: Goal model (id/title/kind/intent/status)
- [x] S1 `splash_page.dart`: idle Lottie + brand line + CTA (spec S1)
- [x] S2 `conversation_page.dart`: bubble stream + typing indicator + input bar (spec S2); this phase uses `scripted_fallback.dart` questions only
- [x] `lib/onboarding/seed_flow_state.dart` + `seed_flow_controller.dart` (sealed state machine, fixed 2 rounds)
- [x] S3 `growing_page.dart`: mascot + copy rotation (spec S3); endpoint temporarily lands on a stub page
- [x] Checkpoint: complete S1→S2→S3→stub offline; restart skips Splash; killing the process midway re-runs the conversation

## Phase 4 · Wire the conversation to AI
- [x] serve.py: `converse` mode (+CONVERSE appended prompt, single-question output)
- [x] serve.py: `conclude` mode (strict JSON: kind/title/slug/closing/intent)
- [x] serve.py: in-memory TURN_CACHE (sha1(system+entry+transcript)) + shared in-flight dedupe
- [x] `bridge_client.nextQuestion()` / `.conclude()`
- [x] controller: live ↔ scripted fallback (a single-turn failure switches to the script with no mixing back; a conclude failure falls back to local classification)
- [ ] Checkpoint: real-device AI live follow-ups; killing the bridge mid-conversation degrades seamlessly (bridge side verified with curl; real device pending)

## Phase 5 · rfw subset + generation + reveal
- [x] `lib/rfw_pool/pool_runtime.dart` + `local_widgets.dart` migrated in, component namespace unified to `bonsai.*` (in sync with system_prompt.txt — capability lock consistent across all three places)
- [x] `lib/screens/screen_store.dart` migrated in (memory+disk cache, in-flight dedupe, Timer.run handoff, pattern unchanged)
- [x] `lib/goals/goal_dashboard_page.dart`: renders DSL; parse failure keeps the previous screen; navigate events no-op + status line
- [x] fetch(goal:slug) wrapper (folded into goal_dashboard_page + screen_store's spec/leaf parameters, no separate file)
- [x] router: `/projects/goal/:slug`, `/areas/goal/:slug` child routes (depth 1)
- [x] S3 wiring: on screen entry send `{"intent":"goal:<slug>","spec":<transcription>,"leaf":true}`; on success → reveal navigation
- [x] Classified atomic write (firstRunComplete + goal into the registry) moved into the real flow
- [ ] Checkpoint: real-device seed→dashboard end-to-end (bridge-side generation + pool parsing verified; real device pending)

## Phase 6 · Fallbacks + polish
- [x] S4 Still-growing placeholder (thirsty Lottie + card) + silent retries at 10/30/60/120s + DSL swapped in place
- [x] Coach mark one-time overlay (coachMarkSeen)
- [x] `lib/screens/agent_sheet.dart` migrated in; dashboard top-bar robot icon → bottom sheet (editing wired up)
- [x] Tab root: goal card list (registry-driven, growing-state indicator) + both `+ seed` entry points wired (with entry context, skipping S1)
- [x] Close button when re-entering S2 via `+` (✕ + abandon confirmation)
- [x] Resources tab connector placeholder cards (kMockData)
- [ ] Checkpoint: full demo script (widget tests cover the offline path; a real-device walkthrough pending)

## Parked (awaiting main app body development)
- [ ] Dashboard sub-page drill-down (remove the leaf restriction, wire up navigate)
- [ ] Tab root DSL-ification + warm pre-generation toolchain
- [ ] Home tab first screen (first-view)
- [ ] Real GBrain / HealthKit connectors
- [ ] Growth-stage-specific Lottie (plant_seed / grow_up / generating, etc., see `design-system/motion-lottie.md`)
