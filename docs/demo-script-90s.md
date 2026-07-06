# 90s demo voiceover script

Status: WIP (2026-07-05) — the 0:00–0:30 onboarding segment is locked; the remaining 60s still to be written
Upstream: `docs/demo-design-90s.md` (Approach A, APPROVED). The actual cut is the source of truth: first 30s = the entire onboarding flow, ending on the project dashboard the AI drew; the first 5s is the loading animation, which carries the app introduction.
Language: all-English voiceover + subtitles (hard submission requirement). Pacing is word-counted against TTS at ~155 wpm (≈2.6 words/sec); each beat has its word count marked — if it runs long, cut the parenthesized words first.

## 0:00–0:30 · Onboarding segment

| Time | Visuals | Voiceover (English) | Words ≈ sec |
|---|---|---|---|
| 0:00–0:05 | Loading animation (mascot/brand) | **Dynamic Software Interfaces: a native app with AI-generated views. UX for the AI era.** | 15w ≈ 6s (at the limit; alternatives below) |
| 0:05–0:09 | Splash: `Plant your first seed` | **This is Bonsai. No sign-up, no tutorial — you just plant a seed.** | 13w ≈ 5s (name and logo appear in the same frame) |
| 0:09–0:19 | Conversation screen, typing sped up (real recording: senior SWE job hunt, see `screenshot/0705-1529.png`) | **You say what you're working toward — a new role, three months out. Two quick questions later, Bonsai files it PARA-style: a Project, something with a finish line.** | 27w ≈ 10s |
| 0:19–0:25 | Growth animation + real stopwatch corner badge | **Then your interface grows. No template, no code — just structure, composed live from hand-designed primitives.** | 16w ≈ 6s |
| 0:25–0:30 | Dashboard reveal (the project the AI drew) | **A dashboard for exactly this goal. You didn't build it — you grew it.** | 13w ≈ 5s |

Total 84 words ≈ 30s. If the TTS runs over in practice, cut in this order:
1. Short version of the 0:00 beat: `Dynamic Software Interfaces: AI-generated views in a real native app.` (-4w ≈ 1.5s)
2. `This is Bonsai.` → `Bonsai.` (the 0:05 beat, -2w)
3. `— a new role, three months out` (the 0:09 beat, -6w; cut this last — it is where the voiceover interlocks with the typed content on screen)

### Design intent of the key lines

- **The 0:00 beat** names the RFS topic (Dynamic Software Interfaces) right out of the gate, followed by a three-part positioning: native app / AI-generated views / UX for the AI era — the judges get the topic mapping and the product positioning within 6 seconds
- **The 0:05 beat**: the instant the voiceover says "Bonsai" is exactly when the logo/splash is on screen — audio-visual sync reinforces brand memory
- **The 0:09 beat** names PARA (`files it PARA-style`): judges who know PARA immediately map the organizational method, and those who don't get the second half of the sentence as an explanation (`a Project, something with a finish line`); same wording as the in-app closing copy, so the on-screen text and the voiceover corroborate each other
- **The 0:19 beat** plants the Direction 2 argument (structure, never code) without expanding on it; the stopwatch corner badge proves authenticity on its own, so the voiceover doesn't need to explain the speed-up
- **The 0:25 beat**: "You didn't build it — you grew it" is the memory hook of the first 30s, and it deliberately leaves room for the closing brand line ("fed by your life, tending it back") — that one is saved for the 90s ending

### Alternatives (0:25 kicker, if you want it punchier)

- `Thirty seconds ago, this app didn't exist.` (8w, harder-hitting, but loses the grow metaphor)
- `You didn't build an app. You planted one.` (8w, closes the seed-metaphor loop)

## 0:30–0:60 · Pruning segment (the Gardener edits the UI live)

Footage sequence: `0705-1540` (dashboard) → `1543` (Gardener sheet opens) → `1544` (chip: Reorder) → `1549` (typed: Add an interview pipeline tracker) → `1550` (pipeline appears in place) → `1551` (typed: bar chart → Done — applied) → `1552` (final state: bar chart + stages list).

| Time | Visuals | Voiceover (English) | Words ≈ sec |
|---|---|---|---|
| 0:30–0:39 | Dashboard close-up: banner/insight card/Week 1 ring (`1540`) | **Day one. The dashboard already carries the plan — three months, AI plus product — and it tells you why: "not a pivot, a repositioning."** | 23w ≈ 9s |
| 0:39–0:47 | robot icon → Gardener sheet; tap chip, typing (`1543`–`1549`) | **And nothing here is final. Open the Gardener and just ask: reorder my next steps. Add an interview pipeline tracker.** | 20w ≈ 8s |
| 0:47–0:54 | The screen recomposes in place: pipeline appears → bar chart request → Done (`1550`–`1552`) | **Each request reshapes the screen in place — even "can I have a bar chart?" Done. Applied. Undoable.** | 17w ≈ 7s |
| 0:54–1:00 | Final-state dashboard in full (`1552`) | **A chatbot gives you a wall of text you'll forget. Bonsai keeps the context — visible, living, yours.** | 17w ≈ 6.5s |

Total 77 words ≈ 30s. If further cuts are needed: first delete beat 1's `— and it tells you why: "not a pivot, a repositioning."` (-8w ≈ 3s), then `Done. Applied. Undoable.` → `Done.` (-2w), and finally `visible, living, yours` → `visible, and yours` (-1w).

### Design intent of this segment

- **The voiceover reuses on-screen text throughout**: `reorder my next steps` = the chip copy; `Add an interview pipeline tracker` = the user's message verbatim; `can I have a bar chart` = the typed line verbatim; `Done. Applied. Undoable.` ↔ the Gardener reply `Done — applied to the screen behind me` + the `Undo` link. Whatever the audience hears, they see
- **The close lands the chatbot contrast** (Direction 3, goal-native vs tool-native): chat returns a pile of text that people forget the moment they turn away; Bonsai stores the context and visualizes it. The wording puts the "forgetting" on the human (`you'll forget`) rather than the bot, leaving the judges nothing to nitpick; the word `living` also loops back to the "living app" main narrative
- The frame carries its own easter egg without the voiceover calling it out: the first row of the interview pipeline is `Anthropic · Applied product eng · actionable`

### Alternative (0:54 close, if you want the RFS-leaning one)

- `You're not programming — you're pruning: your own forward-deployed engineer, without writing a line.` (13w, hits the RFS text verbatim, but too much insider jargon for judges unfamiliar with the RFS)

## 0:60–0:90 · Closing 30s

### Resources / connector segment (0:60–0:72)

Footage sequence: `0705-1611` (empty state: Nothing feeds your garden yet) → `1612` (Connect a resource panel: GBrain/HealthKit/Calendar/Mail/Notes) → `1613` (GBrain · Connected + Linking HealthKit…).

| Time | Visuals | Voiceover (English) | Words ≈ sec |
|---|---|---|---|
| 0:60–0:69 | Empty state → connector panel (`1611`–`1612`) | **Goals feed on more than conversation. In Resources, you connect your life: GBrain, your second brain; HealthKit, streaming straight into your health goals.** | 23w ≈ 9s |
| 0:69–0:72 | GBrain Connected · Linking HealthKit (`1613`) | **Tools hold your data. Bonsai holds your goals.** | 8w ≈ 3s |

Total 31 words ≈ 12s. If it runs over, cut `straight` first (-1w).

Design intent:
- **The verb `feed` is a setup for the brand line**: when `fed by your life` lands at the end it resonates without repeating; the empty-state copy `Nothing feeds your garden yet` sits in the same verb field
- **`Tools hold your data. Bonsai holds your goals.` has on-screen backing**: the `1613` screen literally reads `Tools hold data. Bonsai holds goals — connected sources water the goals they belong to.`; the voiceover and the on-screen text corroborate each other (the only natural landing spot for Direction 3 as a full sentence)
- GBrain is read out as "your second brain" to give judges who don't know it an instant definition; HealthKit matches the wording on the on-screen card

### 90-day evolution segment + close (0:72–0:88)

Footage sequence: `0705-1617` (Home = weekly digest: `This week, tended.` + While you slept card + Draft a follow-up/Let it go decision buttons + three Stats + Project Highlights) → `1618` (Daily Training: habit heatmap + weekly exercise bar chart + streak) → `1619` (Career: growth gaps + resume Timeline + Staff readiness 70% ring) → brand closing frame.

| Time | Visuals | Voiceover (English) | Words ≈ sec |
|---|---|---|---|
| 0:72–0:81 | Home weekly digest (`1617`) | **Fast-forward ninety days. Every Sunday it writes your week — and overnight, it moved your prep block and flagged one decision for you.** | 22w ≈ 8.5s |
| 0:81–0:85 | Quick flash: Daily Training → Career (`1618`–`1619`) | **Your training, your career, your health — every goal grows its own screen.** | 12w ≈ 5s |
| 0:85–0:88 | Brand closing frame (logo/mascot) | **Bonsai — fed by your life, tending it back.** | 8w ≈ 3s |

Total 42 words ≈ 16s; the full cut lands at 0:88, inside the 90s hard cap. If there is still 2–3s of headroom, a market line can follow the brand line: `Born global — generated interfaces need no translation.` (7w ≈ 3s, matching the written submission's globalization narrative).

Design intent:
- **`Fast-forward ninety days` uses the already-finalized presentation approach** (demo-design Open Question #2: make the time jump explicit, don't pretend 90 real days passed)
- **`it writes your week` = the spoken definition of the periodic-note feature**; `moved your prep block`/`flagged one decision` map word-for-word to the While you slept card content (prep block moved to Monday morning / One thing needs a decision) + the two decision buttons — the landing point of the "the human only makes decisions" narrative
- **`every goal grows its own screen`** completes the cross-goal comparison in one sentence (training = heatmap + charts, career = timeline + progress ring, same skeleton, different widgets) — a claim that goes one step beyond the RFS text (every goal of the same person gets its own interface)
- **The brand line closes the show**, looping back to the `feed` setup planted in the 0:60 segment

## End-card tech-stack card (end-card subtitle, not in the voiceover)

Usage: overlay on the 0:85–0:88 brand frame or use as a closing still; the same text is reused directly in the written submission's technical overview. The voiceover is already maxed out at 88s, so this segment is **not spoken** (reading it aloud takes about 20s and would blow the 90s cap).

> **Under the hood** — Dynamic UI generation and live editing are powered by Flutter rfw (Remote Flutter Widgets). Natural-language prompts are bridged to the AI, which returns each screen as a DSL structure — not code — translated and rendered on-device. Fully native and cross-platform: iOS, Android, Web, macOS, and ready to extend to Windows.

(Chinese-language mirror of the above, comment only: dynamic UI generation and editing rely on Flutter rfw; natural-language prompts are bridged to the AI, which returns each screen as a DSL structure — not code — transpiled and rendered on-device; fully native and cross-platform: iOS/Android/Web/macOS, extensible to Windows.)

If a spoken version is insisted upon, ~8s must be cut from other segments to make room; compressed line: `Built on Flutter's Remote Flutter Widgets: AI returns structure, the device renders it — one native codebase, every platform.` (19w ≈ 7.5s)
