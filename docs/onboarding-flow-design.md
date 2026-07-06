# Bonsai first-run onboarding flow — product design ("plant a seed")

Status: APPROVED (2026-07-05, /spec process, signed off by the user)
Scope: product/UX level. Implementation details (bridge protocol, templates, state management) to be discussed separately.
Upstream basis: the Onboarding flow section of `docs/demo-design-90s.md` (video Approach A, onboarding segment 12s, placed after the hook and before Day 1).

## Context

When users open Bonsai for the first time there is no first-run experience — the app goes straight into the 5-tab PARA shell (build-time templates). The video narrative has been finalized to include an onboarding segment: the user states a goal in natural language, and the app grows an interface belonging to that goal on the spot. This is the first minute of "users become their own forward deployed engineers".

## Core concept: onboarding = the flow for planting one goal

Onboarding is not a one-off wizard; it is the general-purpose "plant a seed" flow:

- **Only one goal is handled at a time**. The only thing special about first-run: there is one extra brand splash screen up front, and the app contains nothing yet
- **Adding later goals via `+` re-runs the same flow** (skipping the splash screen)
- Demo script: first-run plants job hunt (Project) → `+` plants health (Area) → final app = 1 Project + 1 Area, naturally producing cross-goal comparison shot material

The onboarding conversation, `+`, and the chat button are **the same interaction surface**: natural language in, interface out. Plant (onboard) → prune (chat) = the productization of "apps you tend".

## Flow (5 steps)

### Step 1 · Splash screen (first-run only)

- Visual: Fresh Matcha look, minimalist bonsai/seed imagery + brand line
- Copy: `Bonsai` / `Fed by your life, tending it back.`
- Single CTA: `Plant your first seed` → enters the conversation
- No login, no permission requests, no feature tour
- **Not skippable**: first-run has no skip — an empty app is meaningless; the first seed is the precondition for the app existing at all
- **Complete once, gone forever**: planting the first goal (or triggering the failure fallback) counts as first-run complete; from then on the app opens straight into the shell and the splash screen never appears again

### Step 2 · Conversation (fixed 2 rounds of follow-up questions)

Entry points branch by type; the opening question itself teaches PARA:

- **`+` on the Projects tab (and the first-run default)**: `What's something you're working toward right now?` — something with an endpoint
- **`+` on the Areas tab**: `What's a part of your life you want to tend for the long run?` — a long-term, never-ending direction

The conversation structure is fixed: opening question → follow-up 1 → follow-up 2 → the AI proactively wraps up. Follow-ups only go as far as "can be classified + can generate a decent dashboard" (minimum viable for generation); no probing into private details — deeper context is left for the Day 1 confirmation area to collect (consistent with the existing narrative's division of labor).

Job-hunt example follow-ups: `What kind of role are you looking for?` → `Where are you in the process — just starting, or already interviewing?`

**Classification is shown, not asked**: when the AI wraps up, it presents the classification result, teaching PARA semantics along the way:
- Project version: `Got it — your job hunt is a Project: something with a finish line. Planting it now…`
- Area version: `…is an Area: something you tend for the long run.`
- Classification correction (safety net): the user describes something with no endpoint at the Project entry → `That sounds like an Area — something you tend, not finish. Planting it there.`
- Ambiguous input: if the AI doesn't understand, it uses the follow-up rounds for clarification; if still unsure, it verbally confirms once based on "does it have an endpoint" — no choice controls are shown

### Step 3 · Growing loading (unified reveal)

- Full-screen bonsai growing animation, real duration (tens of seconds), no fake progress bar
- Micro-copy rotation that also makes the thesis:
  - `Growing your interface…`
  - `Composed from Bonsai primitives — structure, never code`
  - `Almost there. Good things grow slow.`

### Step 4 · Reveal: the goal's dashboard

- Loading completes → land directly on the home page (dashboard) of the goal just planted, revealed all at once in full. Every Project/Area has its own dashboard
- One light hint (coach mark, shown only once, skippable): the bottom tabs are your PARA structure; `+` plants another seed anytime
- **The chat button is a permanent fixture** on every goal's dashboard: users can fine-tune this UI in natural language at any time (`Make this a chart` / `Add my interview pipeline`). The reveal is not the end — it is the beginning of pruning
- This screen is the closing shot of the video's onboarding segment

### Step 5 · Plant again

- Tab roots / dashboards carry a permanent `+`; tapping re-enters Step 2 (with that tab's type context)
- When the user names multiple goals at once: the AI only expands on one and verbally acknowledges the rest (`Let's start with the job hunt — you can plant the others anytime with +`)

## Resources = connectors

Product positioning of the Resources tab: **the intake point for external context** (a connector list); data flows in from connectors and is attributed to goals — the concrete product face of "tools hold the data, Bonsai holds the goals".

- **GBrain is the first resource backend**: the personal knowledge graph feeds into goal context
- HealthKit is the second (health Area, post-hackathon)
- Demo presentation: the Resources tab shows connector cards (`GBrain · Connected` / `HealthKit · Coming soon`, kMockData)

## Failure fallback (first-run has no "previous screen" to keep)

- Generation fails → still reveal the build-time template skeleton (empty PARA shell), with a card in the goal's slot: `Still growing — check back in a moment`
- Automatic retries in the background; on success the card is swapped in place with the real dashboard
- The user always has a usable app; the metaphor stays coherent (bonsai are slow by nature)

## 12s video mapping

Typing shots played at accelerated speed + a real stopwatch corner badge (same treatment as the intent generation segment):

| Shot | Seconds |
|------|------|
| Splash screen (brand line + Plant your first seed) | 2s |
| Conversation (opening question + 2 rounds of follow-ups, accelerated) | 4s |
| Growing animation (accelerated + stopwatch badge) | 3s |
| Dashboard reveal | 3s |

## Out of Scope

- Accounts/login, voice input (typing only), system permission requests, notification onboarding
- A seeds library (stashing extra goals to plant later) — rejected; replaced by re-running the flow via `+`
- Real GBrain / HealthKit integration (demo uses kMockData cards)
- Implementation details: bridge protocol extensions, conversation state management, animation implementation — to be discussed separately

## Decision log

| # | Decision | Outcome |
|---|------|------|
| D1 | Input modality | Conversational, multi-turn |
| D2 | PARA classification | AI classifies automatically and presents it (with entry-point branching, serves as the correction safety net) |
| D3 | Waiting experience | Unified loading followed by a single reveal |
| D4 | Spec depth | Product design only; implementation discussed separately |
| D5 | Conversation ending | AI wraps up when it judges it has enough (fixed 2 rounds of follow-ups) |
| D6 | Follow-up depth | Minimum viable for generation; deep context left for the Day 1 confirmation area |
| D7 | Reveal destination | The goal's own dashboard (every Project/Area has a home page) |
| D8 | Failure fallback | Preset template skeleton as the safety net + background retries |
| D9 | Dashboard positioning | Each goal's home page, not a global Home tab |
| D10 | Multi-goal handling | AI asks about only one; the rest re-run the flow via `+` |
