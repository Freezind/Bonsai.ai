# Onboarding Screen Spec (S1-S5)

Status: PLANNED (2026-07-05)
Upstream references: `docs/onboarding-flow-design.md` (product design, APPROVED) + the user's hand-drawn flow sketches (2026-07-05, confirmed screen by screen). Implementation roadmap in `docs/onboarding/migration-roadmap.md`; task checklist in `docs/onboarding/todo.md`.
Visuals: **Aurora design system** (`design-system/`, Fresh Matcha). All colors/spacing/radii in this doc reference token names only, never raw values; the mascot always uses `design-system/lottie/` assets or their SVG poses, **never emoji**.

General rules:
- Touch targets >= 48dp; body-text contrast >= 4.5:1 (mathematically verified at the token layer; components must not pick their own colors)
- All network/file I/O goes through Isolate.run (see the roadmap's "iOS I/O iron rules")
- Copy uses English as the primary demo language (needed for the video); the tables below give the finalized English; Chinese was for annotation only

---

## S1 · Splash screen (first-run only)

Sketch 1: mascot (bonsai, animated) centered slightly above the middle + brand copy + a single bottom button.

**Route** `/onboarding/splash` (outside the StatefulShellRoute; redirect gating in roadmap D-A2)

**Layout** (top to bottom, centered)
| Block | Content | Token/asset |
|---|---|---|
| Background | Flat solid fill | `bg` (no gradient) |
| Mascot | `bonsai-idle.json` Lottie loop (breathing + blinking), ~200dp | `assets/lottie/bonsai-idle.json` |
| Brand name | `Bonsai` | display type size (Baloo 2), `textPrimary` |
| Brand line | `Apps you tend, not apps you build.` | body type size (Nunito), `textSecondary` |
| CTA | `Plant your first seed` single button, full width with padding | contained primary button: `primary` fill + `onPrimary` text + ink outline + elev-pop hard shadow, compresses on press |

**Interaction and state**
- The only exit = CTA → `context.go('/seed?entry=project')` (first-run defaults to the Project frame, design doc D2)
- **Not skippable**: no skip, no login, no permission dialogs, no feature tour
- Entrance: mascot + copy fade in and slide up (`--dur-slow` tier, spring easing); CTA appears after a ~300ms delay
- **Once done, gone forever**: after `firstRunComplete` is set (at S2 Classified) this screen never appears again

**Acceptance**
- [ ] Always appears on cold start (fresh install); after `firstRunComplete=true`, a restart goes straight to the shell
- [ ] Lottie loops with no dropped frames; no network dependencies (fonts/animations fully bundled)

---

## S2 · Conversation screen (2 follow-up turns)

Sketch 2: chat interface, AI bubbles (with mascot avatar) + user bubbles, bottom input bar, **the software keyboard pushes it straight up** (no quick-reply chips). Big arrow on the right of the sketch, "same process": `+ seed` re-entry uses this same screen.

**Route** `/seed?entry=project|area`

**Layout**
| Block | Content | Token |
|---|---|---|
| Top bar | Lightweight appbar: centered title `Planting a seed`; no back button on first-run, a close button on `+` re-entry (✕, abandons after a confirmation dialog) | `surface`, title type size |
| Message stream | AI bubbles left-aligned (32dp mascot avatar + `surface-2` fill + thin ink outline), user bubbles right-aligned (`primary-container` fill) | bubble radius `rLg`, spacing `s3` |
| Typing indicator | Three-dot animated bubble while the AI is thinking | `subtle` |
| Input bar | Single-line input field + send icon button; pinned to the bottom, rises with the keyboard | outlined field: `surface` fill + `border` outline, `primary` on focus; send button `icon-btn--filled` |

**Conversation structure** (turn count enforced client-side; state machine in roadmap D-A4)
1. **Opening question** (fixed client-side copy, branched by entry):
   - `entry=project` (including first-run): `What's something you're working toward right now?`
   - `entry=area`: `What's a part of your life you want to tend for the long run?`
2. **Follow-ups x2**: each user answer POSTs `{"converse":true, entry, transcript, turn}` → display the returned `question` (AI-generated in real time, one question at a time)
3. **Wrap-up**: after the 2nd answer, POST `{"conclude":true, entry, transcript}` → display the `closing` bubble (with the PARA classification disclosure, e.g. `Got it — your job hunt is a Project: something with a finish line. Planting it now…`); `kind` may differ from `entry` (correction, verbal only, no selection control)
4. The closing bubble lingers ~2s → `context.go('/seed/growing')`

**Interaction and state**
- After sending, the input bar is disabled until the next question arrives; the typing indicator stays visible for the whole wait
- Multi-goal input: the model focuses on one and acknowledges the rest in passing (constrained at the prompt layer, design doc D10)
- New messages auto-scroll to the bottom; the keyboard never covers the input bar

**Degradation** (roadmap D-A5)
- converse fails after 3 retries → switch to `scripted_fallback` scripted questions (2 per entry, e.g. project: `What kind of role are you looking for?` / `Where are you in the process — just starting, or already interviewing?`); the rest of the conversation stays scripted
- conclude fails → local classification = entry; title = first answer truncated to ~40 chars; closing uses a fixed template

**Acceptance**
- [ ] The two entries branch to the correct wording; wrap-up always happens after exactly 2 turns
- [ ] Kill the bridge mid-conversation: the next turn scripts seamlessly, the user never sees an error dialog
- [ ] `Classified` atomically writes firstRunComplete + goal (growing) before leaving the screen

---

## S3 · Growing loading screen

Sketch 3: mascot centered + Loading, annotated "AI thinking".

**Route** `/seed/growing`

**Layout**
| Block | Content | Token/asset |
|---|---|---|
| Background | `bg` flat fill | — |
| Mascot | Growth-stage animation: idle breathing as the base, staged transitions through seed → sprout poses (until a dedicated growth Lottie is produced, cross-fade between the existing idle and the SVG poses) | `bonsai-idle.json` + `#m-seed`/`#m-sprout` poses |
| Copy carousel | Rotates every ~4s: `Growing your interface…` / `Composed from Bonsai primitives — structure, never code` / `Almost there. Good things grow slow.` | body type size, `textSecondary`, fades in and out |

**Data flow**
- On entering the screen, immediately send `{"intent":"goal:<slug>", "spec":"<conversation transcript + dashboard requirements>", "leaf":true}` (the ScreenStore.fetch channel, enjoying the three-layer cache and in-flight dedupe)
- **Real duration** (tens of seconds), no fake progress bar (design doc D3)
- On success → `context.go('/<tab>/goal/<slug>')` (kind=project → `/projects/...`, area → `/areas/...`)

**Degradation**
- On failure or after 90s → navigate to the dashboard route anyway; S4 renders the Still-growing placeholder (the flow is never blocked)

**Acceptance**
- [ ] Kill the process during loading: restart lands in the shell, the goal card is still there; no duplicate generation (hits the bridge cache/in-flight)
- [ ] No fake progress bar; copy carousel pacing correct

---

## S4 · Goal Dashboard reveal (Project or Area)

Sketch 4: title area = goal name (`Projet Dashboard`, red note "could be Projet or Area"), **robot icon** to the right of the title; the whole body annotated "AI generated"; bottom 5 tabs (Home/P/A/R/A). Zoomed-in sketch on the right: robot icon → **Bottom Sheet, adjust UI with Bot**.

**Route** `/projects/goal/:slug` or `/areas/goal/:slug` (inside the shell, depth 1)

**Layout**
| Block | Content | Token |
|---|---|---|
| Top bar | Back button + goal title (title type size) + **robot icon** (always present, 48dp) | `surface` |
| Body | **rfw renders the bridge-generated dashboard DSL** (frozen component pool `bonsai.*`) | the component pool carries Aurora tokens itself |
| Bottom | The shell's 5-tab bar (fully visible for the first time at reveal) | — |
| coach mark | One-time overlay: `Bottom tabs are your PARA structure — tap + anytime to plant another.`; tap anywhere to dismiss; sets `coachMarkSeen` | scrim + `surface-2` card |

**Interaction and state**
- Reveal animation: the whole screen reveals at once (fade in + slight upward shift), no progressive disclosure (design doc D3)
- robot icon → opens the bottom sheet (`agent_sheet` pattern): change the UI in natural language (`Make this a chart`). Editing is wired up in Phase 6; before that the icon is in place and the sheet shows a "coming soon" placeholder — **the entry point's position is finalized this phase**
- DSL events: `back` pops the stack; `navigate` is treated as a no-op this phase + a status-line hint (dashboards are generated as leaf); local state events (toggle etc.) work as usual
- Keep the previous screen on parse failure; never a blank screen

**Still-growing placeholder** (this screen's native form while generation is not ready)
- Mascot `bonsai-thirsty.json` + card `Still growing — check back in a moment` (`card--outlined`)
- Silent retries at 10/30/60/120s; on success the DSL is **swapped in place**, the goal status flips to ready

**Acceptance**
- [ ] Reveal destination = the goal's own dashboard; swiping back lands on the owning tab root (D7/D9)
- [ ] coach mark appears only once, on first-run
- [ ] Placeholder → real dashboard replaced in place, no navigation jump
- [ ] On second launch this screen opens instantly from cache

---

## S5 · `+ seed` loop (tab root)

Sketch 5: `+ seed` button at the top right of the tab root → big arrow "same process" back to S2.

**Location** Projects / Areas tab root (`tab_root_page.dart`)

**Layout**
| Block | Content | Token |
|---|---|---|
| Top bar | Tab name + `+ seed` button (icon `i-plus` + text, or FAB form) | `fab--extended`: `secondary` fill + ink outline + elev-pop |
| Empty state | When there are no goals: mascot seed pose + `Nothing planted here yet.` + `+ seed` prompt | `textSecondary` |
| goal list | Registry-driven goal cards: title + kind badge + status (growing cards carry a small thirsty graphic); tap → dashboard | `card--pop`, badge `chip--filter` |

**Interaction**
- `+ seed` → `context.go('/seed?entry=<tab>')`: the Projects entry carries the project context, Areas carries the area context; **skips S1** (firstRunComplete already set, the redirect does not fire)
- Home / Resources / Archive stay native empty pages this phase (Resources shows connector placeholder cards, kMockData)

**Acceptance**
- [ ] The Projects/Areas entries branch to the correct wording; after the flow ends, the new goal card appears on the corresponding tab
- [ ] The demo script is reproducible: first-run plants a Project (job hunt) → `+` plants an Area (health) → 1 Project + 1 Area

---

## State machine overview (implementation anchor)

```
[S1 Splash] --CTA--> [S2 Opening] -> AwaitingAnswer(0) -> AskingFollowUp(1) -> AwaitingAnswer(1)
   -> AskingFollowUp(2) -> AwaitingAnswer(2) -> Concluding -> Classified(writes prefs + registry)
   --2s--> [S3 Growing] --success--> [S4 Revealed]
                        --failure/90s--> [S4 GrowingFallback(placeholder + silent retries)]
[S5 + seed] --entry=tab--> [S2 Opening](skips S1)
```

Checked item by item against decision records D1-D10 in `onboarding-flow-design.md` with no conflicts (D1 multi-turn conversation ✓ / D2 classification disclosure + entry correction ✓ / D3 unified loading, one-shot reveal ✓ / D5 fixed 2 turns ✓ / D7·D9 goal owns its home page ✓ / D8 template-skeleton degradation → implemented this phase as the native placeholder ✓ / D10 multi-goal focus ✓).
