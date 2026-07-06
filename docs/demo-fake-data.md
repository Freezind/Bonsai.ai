# Demo fake data — periodic note (Home digest) + three goal dashboards

Status: DRAFT (2026-07-05, for the hackathon demo)
Upstream basis: `docs/onboarding-flow-design.md` (APPROVED) + this round's periodic note design discussion.
Scope: **pure UI content layer** — what each screen looks like, which components it uses, and what fake copy to write. Implementation (cron, bridge, caching) is out of scope for this document.

**Fake data discipline**:
- Persona, company names, numbers, and habit records are **entirely fictional**; no real personal data is included
- Only the celebrity quotes are real public quotations (Jobs / Buffett), per the "inspirational quotes" design requirement
- The user's Obsidian Health note only lends its **layout skeleton** (quote → current status → habit heatmap → sleep → meditation); zero content is reused
- Copy is in English as the demo's primary language (video requirement); Chinese appears only in comments

**Persona (fictional)**: Aya, senior software engineer, 8 years of experience, job hunting. 1 Project + 2 Areas in the app:
- `P` Job Hunt — Senior SWE (job-hunt Project)
- `A` Career (career Area, linked to the job-hunt Project)
- `A` Health (health Area)

Date setting: today = **Sunday, Jul 5, 2026 (final day of Week 27)** — Sunday is exactly the natural publication day for the weekly digest.

---

## H0 · Home tab = Periodic Note digest (new feature)

Product definition: the Home landing screen is the AI's periodic summary (periodic note). Narratively it is generated overnight by a background task (the all-goals version of "Bonsai dreams while you sleep"): a today card every morning, plus a weekly digest every Sunday. Decisions for this round:

| # | Decision | Outcome |
|---|------|------|
| PN1 | Placement | Home tab landing screen (fills the Home gap) |
| PN2 | Granularity | Today card + weekly review, two cadences on one screen |
| PN3 | Content nature | Review + suggestions (each section ends with a next-step / decision, echoing Day90's "humans only make decisions") |
| PN4 | Data source | Mock activity stream (this document); generation pipeline to be discussed later |

**Layout (top to bottom)**

| Section | Component (frozen pool) | Fake content |
|---|---|---|
| Top bar | `AppBar(large)` | overline: `SUNDAY · JUL 5 · WEEK 27` / title: `This week, tended.` |
| Today card | `Banner(icon: sparkle)` | title: `While you slept` / subtitle: `Lumina's onsite is Tuesday at 2pm, but your focus peaks before noon — prep block moved to Monday morning. One thing needs a decision: Orbit has been silent for 12 days.` |
| Today's decision | `Button(contained)` + `Button(text)` | `Draft a follow-up` / `Let it go` |
| Section header | `SectionHeader` | `THIS WEEK · JOB HUNT`, action: `Open` |
| Metric row | `Stat` ×3 (Row) | `Applications · 12 · +5` / `In pipeline · 5 · +2` / `Interviews · 2 · +2` |
| Job-hunt weekly review | `Card` + `Txt(body2)` | `A strong week: two interviews booked, and replies doubled after the resume rewrite. Next: prep Lumina's system-design round — your payments-migration notes are your best material.` |
| Section header | `SectionHeader` | `THIS WEEK · CAREER` |
| Career weekly review | `ListItem(status: actionable)` | title: `Both interviewers echoed the same strength: calm under incident pressure` / subtitle: `Negotiation practice is still untouched — it matters within two weeks if an offer lands` |
| Section header | `SectionHeader` | `THIS WEEK · HEALTH` |
| Health weekly review | `Alert(severity: warning)` | `Sleep dipped under 6h on both interview eves. Wind-down reminder is on for 22:45 tonight.` |
| Health metrics | `Stat` ×2 (Row) | `Avg sleep · 6h 29m · -18m` / `Meditation streak · 6 days · +6` |
| Footer note | `Txt(label)` | `Grown overnight by your gardener · Sun 6:04` |

---

## G1 · Job Hunt — Senior SWE (Project dashboard)

Elements: goal, inspirational quote, job tracking, todos. Featured components: **Stepper (pipeline) + StatusTable + CheckItem**.

| Section | Component | Fake content |
|---|---|---|
| Top bar | `AppBar(large, onBack)` | overline: `P · PROJECT` / title: `Job Hunt — Senior SWE` |
| Goal card | `Card` + `Ico(target)` + `Txt(body2)` | `Goal: a senior role on a product team that ships — offer signed by end of August.` |
| Quote | `Card` + `Txt(body)` | `"The only way to do great work is to love what you do." — Steve Jobs` |
| Section header | `SectionHeader` | `PIPELINE` |
| Pipeline | `Stepper` | `Applied(done, n:12)` → `Screens(done, n:6)` → `Tech round(active, n:3)` → `Onsite(upcoming, n:1)` → `Offer(upcoming)` |
| Section header | `SectionHeader` | `ACTIVE APPLICATIONS`, action: `See all` |
| Tracking table | `StatusTable` | `Lumina Health — onsite Tue · actionable` / `Kite Systems — tech round Thu · actionable` / `Orbit Robotics — silent for 12 days · warning` / `Mapletree Pay — screen scheduled · done` |
| Section header | `SectionHeader` | `THIS WEEK'S TODOS` |
| Todos | `CheckItem` ×4 | `Prep system design: payments case study` (unchecked) / `Send thank-you note to the Kite panel` (checked) / `Follow up with Orbit's recruiter` (unchecked) / `Book a mock interview before the onsite` (unchecked) |
| Save | `Button(contained)` | `Save` |

---

## G2 · Career (Area dashboard, linked to the job-hunt Project)

Elements: linked Project, career status, strengths/weaknesses. Featured components: **KeyValue + ProjectCard + Chip + DependencyGraph + Timeline + ProgressRing** (zero overlap with G1).

| Section | Component | Fake content |
|---|---|---|
| Top bar | `AppBar(large, onBack)` | overline: `A · AREA` / title: `Career` |
| Career status | `Card` + `KeyValue` ×4 | `Role — Senior Software Engineer` / `Experience — 8 years` / `Edge — Distributed systems` / `Season — Actively interviewing` |
| Project link | `ProjectCard` | category: `P · PROJECT` / status: `actionable` / title: `Job Hunt — Senior SWE` / subtitle: `5 in pipeline · 2 interviews this week` / progress: `0.45` (tap → G1) |
| Section header | `SectionHeader` | `STRENGTHS` |
| Strengths | `Chip` ×3 (selected) | `Systems design` / `Incident command` / `Mentoring` |
| Section header | `SectionHeader` | `GROWTH EDGES` |
| Weaknesses | `StatusTable` | `Salary negotiation · warning` / `Public speaking · warning` / `Visible writing · blocked` |
| Skill graph | `DependencyGraph` | `senior scope(done)` / `staff scope(actionable)` / `negotiation(blocker)` / `open-source visibility(blocked)` |
| Career timeline | `Timeline` | `2019 — Joined Kite Systems, first backend role` / `2022 — Senior promotion after the payments re-architecture` / `2025 — Led incident program, cut MTTR 40%(done)` / `2026 — Hunting staff scope(actionable)` |
| Readiness | `ProgressRing(0.7)` | label: `Staff readiness` |

---

## G3 · Health (Area dashboard)

Layout borrows the Obsidian Health skeleton: quote → current status → habit heatmap → sleep → meditation/morning check-in. Content is entirely fictional. Featured components: **HabitHeatmap + BarChart + MoodPicker + Switch** (zero overlap with G1/G2).

| Section | Component | Fake content |
|---|---|---|
| Top bar | `AppBar(large, onBack)` | overline: `A · AREA` / title: `Health` |
| Quote | `Card` + `Txt(body)` | `"You only get one mind and one body. And it's got to last a lifetime." — Warren Buffett` |
| Current status | `Card` + `Ico(leaf)` + `Txt(body2)` | `One habit at a time: building a 10-minute morning stretch. Sleep and meditation hold steady; strength training waits in the queue.` |
| Section header | `SectionHeader` | `HABITS · LAST 14 DAYS` |
| Heatmap | `HabitHeatmap` | `Sleep by 23:30 — d,d,m,d,d,d,m,d,d,d,d,m,d,t` / `Stretch 10 min — e,e,e,e,e,e,e,d,d,m,d,d,d,t` (micro-habit newly started on 6/29) / `Meditate — d,d,d,d,m,d,d,d,d,d,m,d,d,t` / `10k steps — m,d,d,m,d,d,d,m,m,d,d,d,m,t` |
| Section header | `SectionHeader` | `SLEEP · THIS WEEK` |
| Sleep chart | `BarChart` | values: `6.1,7.2,5.8,6.9,7.4,5.6,6.4` / labels: `M,T,W,T,F,S,S` |
| Sleep metrics | `Stat` ×2 (Row) | `Avg sleep · 6h 29m · -18m` / `Meditation streak · 6 days · +6` |
| Reminder | `Alert(warning)` + Row(`Txt` + `Switch(true)`) | `Under 6h on both interview eves.` / `Wind-down reminder · 22:45` |
| Morning check-in | `MoodPicker` | `😴 low` / `🙂 ok(selected)` / `😊 good` |
| Save | `Button(contained)` | `Save` |

---

## Component coverage matrix ("showcase different components")

| Screen | Exclusive components |
|---|---|
| H0 Home digest | Banner, Stat (cluster), SectionHeader, ListItem, Alert |
| G1 Job Hunt | Stepper/Step, StatusTable/StatusRow, CheckItem |
| G2 Career | KeyValue, ProjectCard, Chip, DependencyGraph/DepNode, Timeline/TimeItem, ProgressRing |
| G3 Health | HabitHeatmap/HeatRow, BarChart, MoodPicker/MoodOption, Switch |

The four screens together cover 20+ components of the frozen pool, with zero need for new components — all content can be expressed by the existing `bonsai.*` pool.

## Next steps (not executed in this document)

1. Turn this document's content into kMockData / pre-generated DSL for recording
2. Suggested demo script order: Home digest (periodic note opener) → tap into Job Hunt → Career (show the Project↔Area link) → Health (heatmap/chart shots)
