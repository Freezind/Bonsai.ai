# AGENTS.md

This file provides guidance to AI coding agents (Claude Code etc.) when working with code in this repository. `CLAUDE.md` is a symlink to this file.

## Purpose

Built for the hackathon **c0mpiled in Japan pt.3** (2026-07-05, https://luma.com/compiled-4qzo), targeting the YC RFS Summer 2026 theme **Dynamic Software Interfaces** (https://www.ycombinator.com/rfs#dynamic-software-interfaces). The thesis this project validates: developers ship only well-designed primitives (a frozen component pool), and users compose their own interfaces on the spot by talking to an agent in natural language — what the RFS calls "users become their own forward deployed engineers".

That framing drives the trade-offs: this is a PoC, mock data (`kMockData`) is intentional, the bridge is a dev-environment tool only, and production-grade robustness and test coverage are non-goals; but **the model only ever outputs structured DSL, never executable code** — that is the project's foundation and no change may compromise it. For background see `docs/hackathon-compiled.md` (event requirements) and `docs/yc-rfs-summer-2026.md` (the RFS text and how this project maps to it).

## What this is

**Bonsai** ("fed by your life, tending it back"): a Flutter app where the user types an intent → a local Claude bridge service generates rfw DSL (structure only, never executable code) → the device renders it through a frozen component pool.

> **Status (2026-07-05)**: lib/, bridge/, and design-system/ are all in place; the onboarding flow ("plant a seed") Phases 0–6 are implemented (roadmap and task list in `docs/onboarding/`); converting the main tabs to DSL and warm pre-generation have not started. The demo narrative design doc is `docs/demo-design-90s.md`.

Three parts:

- `lib/` — Flutter app (Dart SDK ^3.9, Flutter 3.44.4, see `.tool-versions`)
- `bridge/` — local Python bridge running on the Mac (`serve.py`, no third-party dependencies) that generates rfw text DSL via headless `claude -p`; no API key needed, it uses the local claude login. DSL transpilation relies on Flutter's official **rfw** (Remote Flutter Widgets): the device transpiles the structural text into a real native widget tree in real time — so the app is **fully native**, with no WebView/embedding layer, and the model never touches executable code
- `design-system/` — pure HTML/CSS living style guide (the **Fresh Matcha** design system: milky-cream paper background + spring green × sky blue, ink outlines + hard shadows for a picture-book paper-cut feel, Baloo 2 × Nunito rounded type, hand-drawn bonsai mascot with five growth stages); not part of the build. The Dart-side token layer is `lib/ds/aurora_tokens.dart` (the class name keeps `Aurora` for API stability; the values are Fresh Matcha)

## Commands

```bash
flutter pub get
flutter test                          # all tests (test/widget_test.dart)
flutter analyze                       # lint (flutter_lints rules)

# Run the bridge (must start before the app, on the Mac)
python3 bridge/serve.py               # default port 8787; see the top of serve.py for env vars like BONSAI_BRIDGE_PORT / BONSAI_BRIDGE_MODEL

# Run on a real device (iOS, development)
flutter run -d <device> --dart-define=BRIDGE_URL=http://<mac-lan-ip>:8787
# Screen-recording/demo build: only release can launch standalone from the home screen icon while detached (debug builds crash on launch)
#   RESET_STATE=true    wipe persisted state on every cold start (for re-recording first-run)
#   SKIP_ONBOARDING=true skip the seed flow and go straight to the shell
flutter run --release -d <device> --dart-define=BRIDGE_URL=http://<ip>:8787 \
  --dart-define=RESET_STATE=true --dart-define=SKIP_ONBOARDING=true
# Android: after adb reverse tcp:8787 tcp:8787, use http://localhost:8787 as BRIDGE_URL
```

Venue/campus Wi-Fi often has client isolation (the phone can never reach the Mac; "Host is down") — use an iPhone personal hotspot + USB tethering, and point BRIDGE_URL at the Mac's hotspot interface IP (172.20.10.x). On generation failure, the full DSL is appended to `bridge/dsl.log`. The warm.py pre-generation toolchain belongs to main-app development and has not been migrated in yet (see TODO.md).

## Architecture

**Data flow**: intent text → `BridgeClient` (`lib/bridge/bridge_client.dart`) POSTs to the bridge `/generate` → the bridge prepends `bridge/system_prompt.txt` and calls `claude -p` → returns rfw text DSL → `applyDsl` (`lib/rfw_pool/pool_runtime.dart`) parses and renders it. If DSL parsing fails, keep the previous screen (graceful degradation) — never show a blank screen.

**Capability lock philosophy**: the model can only compose whitelisted components. The component pool must stay in sync across three places — `lib/rfw_pool/local_widgets.dart` (Dart implementations), `bridge/system_prompt.txt` (tells the model which components exist), and `lib/ds/aurora_tokens.dart` (design tokens). When changing the component pool, change all three together.

**Navigation model (a closed, finite app)**: `lib/app/router.dart` uses GoRouter's `StatefulShellRoute` — the 5 bottom tabs are siblings (depth 0); only pushed child pages accumulate depth, and switching tabs resets to the root. `kMaxDepth = 3`: a depth-3 screen is a closed leaf (interactive, but cannot navigate deeper). The depth cap is enforced on-device, so any deeper links smuggled into the DSL are ignored. Tab roots are currently native Dart pages; the demo's goal detail pages are fixed build-time rfw templates (`lib/rfw_pool/demo_dashboards.dart`, 0 tokens). warm.py subtree pre-generation belongs to main-app development and has not been migrated in yet.

**Three cache layers; each intent is generated exactly once, ever**:
1. Bridge-side `bridge/cache.json` — the key is sha1(system_prompt + intent), so editing system_prompt.txt automatically invalidates all old entries; the bridge has in-flight dedupe (a retried request waits for the generation already in progress instead of running again)
2. On-device `ScreenStore` (`lib/screens/screen_store.dart`) — memory + disk (documents/dsl_cache.json), with in-flight dedupe
3. `warm.py` peek requests only read the cache and never generate, guaranteeing idempotence

**Warning: on iOS, await can hang forever (reproduced across multiple Flutter versions)** — for a Future completed by socket/file events on the main isolate, the awaiter intermittently never resumes. The established workarounds, which any change to network/file I/O must follow:
- Put all dart:io network and file I/O inside `Isolate.run` (see `bridge_client.dart`, `screen_store.dart`)
- To read a result across a shared Future, use `.then` + `Timer.run` to hand off to a Completer manually; never `await sharedFuture` directly (see `ScreenStore.fetch`)
- `ShellScaffold` runs a 2-second periodic keep-alive Timer to keep the event loop waking up
- ValueNotifier updates can land mid-frame; check the phase via `SchedulerBinding` before notifying (`setStatus`, `_DepthObserver`)

**Bridge protocol for the app** (`bridge/serve.py`, single file): `POST /generate` with `{"intent"}`, plus optional `leaf` (leaf screen; navigate intents forbidden), `peek` (cache lookup only), `bundle` (generate multiple screens at once, separated by `=== screen: <id> ===`). An empty intent returns 400 — the app uses that as a connectivity ping.

## Notes

- rfw DSL rules live in `bridge/system_prompt.txt`: numbers must be doubles (16.0), the whole screen is wrapped in `Canvas(child: ...)`, and there is exactly one `widget root = ...;`
- Test assertions match text from the onboarding copy and the `DemoScenario`/fixed-template content; changing copy affects `test/widget_test.dart`

## Commit message conventions

- Write commit messages in English, imperative mood, present tense: "Add", not "Added" or "Adds".
- Subject line under ~70 chars. Body only when the "why" isn't obvious from the diff — skip it for small, self-explanatory changes.
- No AI co-author trailers (`Co-Authored-By: Claude ...`, `Claude-Session: ...`, etc.) and no emoji. Commits should read as if a human on the team wrote them.
- One logical change per commit. Don't bundle unrelated fixes/refactors into a single commit just because they landed in the same session.
- Reference issue/PR numbers when relevant (`Fixes #12`), but never fabricate one.
