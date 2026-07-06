# Worklog — c0mpiled-12 (2026-07-05)

Competition-day work log. The full argument for the narrative and differentiation lives in `docs/demo-design-90s.md` (Status: APPROVED); the task list is in `TODO.md`.

## Decisions made

- **Named it Bonsai**: "apps you tend, not apps you build" -- a living thing, it grows, the owner prunes it (AI grows / the human decides); home turf in Japan, high recognition in the West
- **Narrative locked to Approach A** "one life, one living app": timeline narrative, 83s budget leaving 7s of headroom (hook 8s → Day1 18s → Day90 24s → intent generation 18s → comparison + close 15s)
- **The video tells a single main thread, judges get no Q&A**: all other differentiation (capability lock / goal-native / truly native) + the moat argument goes entirely into the written submission materials, same priority as the video
- **Moat principle**: keep at least a 20-degree angle away from the model vendors; build the vertical layer (goal-context organization + shipped primitives + accumulated personalization state); the model is a supplier, not a competitor
- **Default plan** (takes effect automatically at the deadline): voiceover via TTS (replace with a human voice if one is available before 14:00); Day 90 wording "Fast-forward 90 days into her job hunt."; business model = consumer subscription + primitives platform as the second curve; global-market line = "generated, not translated -- ships to every language on day one"; presenting intent latency = sped-up playback + a real stopwatch in the corner

## To-dos and timeline

1. **10:35** attend Demo & Submission Instructions: confirm video format/upload method, and **confirm the compliance boundary for pre-event PoC validation + in-hackathon AI rebuild** (declare the proof-of-concept history to the organizers)
2. If going the in-hackathon rebuild route: 12:00-15:00 rebuild from spec with AI in this repo → 15:00-16:00 record → 16:00-16:45 edit and submit (timeline to be finalized after 10:35)
3. Second-by-second shot-by-shot script (each shot = visuals + English voiceover lines)
4. Written submission materials (English): problem framing + product/tech/business-model overview + global-market perspective
5. **Submit before 16:30**, leaving a 30-minute buffer for mishaps

## Validation move (The Assignment)

Rough cut the Day 1 → Day 90 evolution segment, show it to someone who has never seen the project, and have them restate in one sentence what they saw. If they can't say "the app changed/grew by itself", the narrative doesn't hold -- and we find out before investing in the full edit.

## Notes

- Always run on real devices with `--profile` (debug mode has JIT breakpoint issues); keep pre-generation serial
- Platform caveats for network/file I/O are in `AGENTS.md` (the iOS await-resumption issue and the established workarounds)
- Garry Tan did not attend the previous Tokyo event (c0mpiled-7); this is his first appearance in the series
