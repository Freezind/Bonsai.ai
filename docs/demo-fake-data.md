# Demo fake data — periodic note (Home digest) + 三块 goal dashboard

Status: DRAFT(2026-07-05,供 hackathon demo 用)
上游依据:`docs/onboarding-flow-design.md`(APPROVED)+ 本次 periodic note 设计讨论。
定位:**纯 UI 内容层**——每屏长什么样、放哪些组件、写什么 fake 文案。实现(cron、bridge、缓存)不在本文范围。

**Fake data 纪律**:
- persona、公司名、数字、习惯记录**全部虚构**,不含任何真实个人数据
- 仅名人名言为真实公开引语(Jobs / Buffett),属"励志名人名言"设计需求
- 用户的 Obsidian Health 笔记只借用了**版式骨架**(引言 → 当前状态 → 习惯热力图 → 睡眠 → 冥想),内容零复用
- 文案以英文为 demo 主语言(视频要求),中文仅注释

**Persona(虚构)**:Aya,senior software engineer,8 年经验,求职中。app 内 1 个 Project + 2 个 Area:
- `P` Job Hunt — Senior SWE(求职 Project)
- `A` Career(职业 Area,链接到求职 Project)
- `A` Health(健康 Area)

日期设定:今天 = **Sunday, Jul 5, 2026(Week 27 收官日)**——周日正好是 weekly digest 的自然出刊日。

---

## H0 · Home tab = Periodic Note digest(新功能)

产品定义:Home 首屏就是 AI 的周期性总结(periodic note)。叙事上由后台任务在夜间生成("Bonsai dreams while you sleep" 的全 goal 版):每天早上一张今日卡,每周日一份 weekly digest。本期决策:

| # | 决策 | 结果 |
|---|------|------|
| PN1 | 呈现位置 | Home tab 首屏(填补 Home 空缺) |
| PN2 | 粒度 | 今日卡 + 本周回顾,同屏两种节奏 |
| PN3 | 内容性质 | 回顾 + 建议(每段以 next-step / 决策收尾,呼应 Day90 "人只做决策") |
| PN4 | 数据来源 | mock 活动流(本文档),生成链路后议 |

**布局(自上而下)**

| 区块 | 组件(冻结池) | Fake 内容 |
|---|---|---|
| 顶栏 | `AppBar(large)` | overline: `SUNDAY · JUL 5 · WEEK 27` / title: `This week, tended.` |
| 今日卡 | `Banner(icon: sparkle)` | title: `While you slept` / subtitle: `Lumina's onsite is Tuesday at 2pm, but your focus peaks before noon — prep block moved to Monday morning. One thing needs a decision: Orbit has been silent for 12 days.` |
| 今日决策 | `Button(contained)` + `Button(text)` | `Draft a follow-up` / `Let it go` |
| 分组头 | `SectionHeader` | `THIS WEEK · JOB HUNT`,action: `Open` |
| 指标行 | `Stat` ×3(Row) | `Applications · 12 · +5` / `In pipeline · 5 · +2` / `Interviews · 2 · +2` |
| 求职周评 | `Card` + `Txt(body2)` | `A strong week: two interviews booked, and replies doubled after the resume rewrite. Next: prep Lumina's system-design round — your payments-migration notes are your best material.` |
| 分组头 | `SectionHeader` | `THIS WEEK · CAREER` |
| 职业周评 | `ListItem(status: actionable)` | title: `Both interviewers echoed the same strength: calm under incident pressure` / subtitle: `Negotiation practice is still untouched — it matters within two weeks if an offer lands` |
| 分组头 | `SectionHeader` | `THIS WEEK · HEALTH` |
| 健康周评 | `Alert(severity: warning)` | `Sleep dipped under 6h on both interview eves. Wind-down reminder is on for 22:45 tonight.` |
| 健康指标 | `Stat` ×2(Row) | `Avg sleep · 6h 29m · -18m` / `Meditation streak · 6 days · +6` |
| 尾注 | `Txt(label)` | `Grown overnight by your gardener · Sun 6:04` |

---

## G1 · Job Hunt — Senior SWE(Project dashboard)

要素:goal、励志名言、job tracking、todos。主打组件:**Stepper(pipeline)+ StatusTable + CheckItem**。

| 区块 | 组件 | Fake 内容 |
|---|---|---|
| 顶栏 | `AppBar(large, onBack)` | overline: `P · PROJECT` / title: `Job Hunt — Senior SWE` |
| Goal 卡 | `Card` + `Ico(target)` + `Txt(body2)` | `Goal: a senior role on a product team that ships — offer signed by end of August.` |
| 名言 | `Card` + `Txt(body)` | `"The only way to do great work is to love what you do." — Steve Jobs` |
| 分组头 | `SectionHeader` | `PIPELINE` |
| 管道 | `Stepper` | `Applied(done, n:12)` → `Screens(done, n:6)` → `Tech round(active, n:3)` → `Onsite(upcoming, n:1)` → `Offer(upcoming)` |
| 分组头 | `SectionHeader` | `ACTIVE APPLICATIONS`,action: `See all` |
| 跟踪表 | `StatusTable` | `Lumina Health — onsite Tue · actionable` / `Kite Systems — tech round Thu · actionable` / `Orbit Robotics — silent for 12 days · warning` / `Mapletree Pay — screen scheduled · done` |
| 分组头 | `SectionHeader` | `THIS WEEK'S TODOS` |
| 待办 | `CheckItem` ×4 | `Prep system design: payments case study`(未勾)/ `Send thank-you note to the Kite panel`(已勾)/ `Follow up with Orbit's recruiter`(未勾)/ `Book a mock interview before the onsite`(未勾) |
| 保存 | `Button(contained)` | `Save` |

---

## G2 · Career(Area dashboard,链接求职 Project)

要素:链接 Project、职业状态、优势/劣势。主打组件:**KeyValue + ProjectCard + Chip + DependencyGraph + Timeline + ProgressRing**(与 G1 零重叠)。

| 区块 | 组件 | Fake 内容 |
|---|---|---|
| 顶栏 | `AppBar(large, onBack)` | overline: `A · AREA` / title: `Career` |
| 职业状态 | `Card` + `KeyValue` ×4 | `Role — Senior Software Engineer` / `Experience — 8 years` / `Edge — Distributed systems` / `Season — Actively interviewing` |
| Project 链接 | `ProjectCard` | category: `P · PROJECT` / status: `actionable` / title: `Job Hunt — Senior SWE` / subtitle: `5 in pipeline · 2 interviews this week` / progress: `0.45`(点击 → G1) |
| 分组头 | `SectionHeader` | `STRENGTHS` |
| 优势 | `Chip` ×3(selected) | `Systems design` / `Incident command` / `Mentoring` |
| 分组头 | `SectionHeader` | `GROWTH EDGES` |
| 劣势 | `StatusTable` | `Salary negotiation · warning` / `Public speaking · warning` / `Visible writing · blocked` |
| 技能图 | `DependencyGraph` | `senior scope(done)` / `staff scope(actionable)` / `negotiation(blocker)` / `open-source visibility(blocked)` |
| 履历线 | `Timeline` | `2019 — Joined Kite Systems, first backend role` / `2022 — Senior promotion after the payments re-architecture` / `2025 — Led incident program, cut MTTR 40%(done)` / `2026 — Hunting staff scope(actionable)` |
| 就绪度 | `ProgressRing(0.7)` | label: `Staff readiness` |

---

## G3 · Health(Area dashboard)

版式借用 Obsidian Health 骨架:引言 → 当前状态 → 习惯热力图 → 睡眠 → 冥想/晨间自评。内容全虚构。主打组件:**HabitHeatmap + BarChart + MoodPicker + Switch**(与 G1/G2 零重叠)。

| 区块 | 组件 | Fake 内容 |
|---|---|---|
| 顶栏 | `AppBar(large, onBack)` | overline: `A · AREA` / title: `Health` |
| 名言 | `Card` + `Txt(body)` | `"You only get one mind and one body. And it's got to last a lifetime." — Warren Buffett` |
| 当前状态 | `Card` + `Ico(leaf)` + `Txt(body2)` | `One habit at a time: building a 10-minute morning stretch. Sleep and meditation hold steady; strength training waits in the queue.` |
| 分组头 | `SectionHeader` | `HABITS · LAST 14 DAYS` |
| 热力图 | `HabitHeatmap` | `Sleep by 23:30 — d,d,m,d,d,d,m,d,d,d,d,m,d,t` / `Stretch 10 min — e,e,e,e,e,e,e,d,d,m,d,d,d,t`(6/29 新起的微习惯)/ `Meditate — d,d,d,d,m,d,d,d,d,d,m,d,d,t` / `10k steps — m,d,d,m,d,d,d,m,m,d,d,d,m,t` |
| 分组头 | `SectionHeader` | `SLEEP · THIS WEEK` |
| 睡眠图 | `BarChart` | values: `6.1,7.2,5.8,6.9,7.4,5.6,6.4` / labels: `M,T,W,T,F,S,S` |
| 睡眠指标 | `Stat` ×2(Row) | `Avg sleep · 6h 29m · -18m` / `Meditation streak · 6 days · +6` |
| 提醒 | `Alert(warning)` + Row(`Txt` + `Switch(true)`) | `Under 6h on both interview eves.` / `Wind-down reminder · 22:45` |
| 晨间自评 | `MoodPicker` | `😴 low` / `🙂 ok(selected)` / `😊 good` |
| 保存 | `Button(contained)` | `Save` |

---

## 组件覆盖矩阵("重点展示不同的组件")

| 屏 | 独占组件 |
|---|---|
| H0 Home digest | Banner、Stat(集群)、SectionHeader、ListItem、Alert |
| G1 Job Hunt | Stepper/Step、StatusTable/StatusRow、CheckItem |
| G2 Career | KeyValue、ProjectCard、Chip、DependencyGraph/DepNode、Timeline/TimeItem、ProgressRing |
| G3 Health | HabitHeatmap/HeatRow、BarChart、MoodPicker/MoodOption、Switch |

四屏合计覆盖冻结池 20+ 个组件,零新增组件需求——全部内容均可由现有 `bonsai.*` 池表达。

## 下一步(不在本文执行)

1. 把本文内容落成 kMockData / 预生成 DSL,供录制
2. demo 剧本顺序建议:Home digest(periodic note 开场)→ 点进 Job Hunt → Career(展示 Project↔Area 链接)→ Health(热力图/图表镜头)
