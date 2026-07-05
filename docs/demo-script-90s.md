# 90s demo 旁白脚本

Status: WIP(2026-07-05)— 0:00–0:30 onboarding 段已定,后 60s 待写
上游:`docs/demo-design-90s.md`(Approach A,APPROVED)。实剪为准:前 30s = onboarding 全过程,结尾落在 AI 画出的 project dashboard;前 5s 为载入动画,承担 app 介绍。
语言:全英文旁白 + 字幕(提交硬性要求)。语速按 TTS ~155 wpm(≈2.6 词/秒)卡字数;每拍已标 word count,超长先砍括号里的词。

## 0:00–0:30 · Onboarding 段

| 时间 | 画面 | 旁白(英文) | 词数≈秒 |
|---|---|---|---|
| 0:00–0:05 | 载入动画(吉祥物/品牌) | **Dynamic Software Interfaces: a native app with AI-generated views. UX for the AI era.** | 15w ≈ 6s(顶格,备选见下) |
| 0:05–0:09 | Splash:`Plant your first seed` | **This is Bonsai. No sign-up, no tutorial — you just plant a seed.** | 13w ≈ 5s(名字与 logo 同帧出现) |
| 0:09–0:19 | 对话屏,打字加速(实录:senior SWE 求职,见 `screenshot/0705-1529.png`) | **You say what you're working toward — a new role, three months out. Two quick questions later, Bonsai files it PARA-style: a Project, something with a finish line.** | 27w ≈ 10s |
| 0:19–0:25 | 生长动画 + 真实秒表角标 | **Then your interface grows. No template, no code — just structure, composed live from hand-designed primitives.** | 16w ≈ 6s |
| 0:25–0:30 | dashboard 揭示(AI 画出的 project) | **A dashboard for exactly this goal. You didn't build it — you grew it.** | 13w ≈ 5s |

合计 84 词 ≈ 30s。若 TTS 实测超时,按此顺序砍:
1. 0:00 拍短版:`Dynamic Software Interfaces: AI-generated views in a real native app.`(-4w ≈ 1.5s)
2. `This is Bonsai.` → `Bonsai.`(0:05 拍,-2w)
3. `— a new role, three months out`(0:09 拍,-6w;最后才砍——这段是旁白与画面打字内容的咬合点)

### 关键句设计意图

- **0:00 拍**开口点名 RFS 赛题(Dynamic Software Interfaces),随后三连定位:native app / AI-generated views / UX for the AI era——评委 6 秒内拿到赛题映射和产品定位
- **0:05 拍**旁白念出 "Bonsai" 的瞬间正是 logo/splash 在画面上的时刻,音画同步强化品牌记忆
- **0:09 拍**点名 PARA(`files it PARA-style`):懂 PARA 的评委立刻对上组织方法,不懂的有后半句解释(`a Project, something with a finish line`);与 app 内 closing 文案同款,画面文案和旁白互证
- **0:19 拍**埋方向 2 论点(structure, never code)但不展开;秒表角标自证真实,旁白不需要解释加速
- **0:25 拍** "You didn't build it — you grew it" 是前 30s 的记忆点,也为结尾 brand 句("fed by your life, tending it back")留着不抢——那句留给 90s 收尾

### 备选(0:25 kicker,如想更狠)

- `Thirty seconds ago, this app didn't exist.`(8w,更硬,但丢掉 grow 隐喻)
- `You didn't build an app. You planted one.`(8w,种子隐喻闭环)

## 0:30–0:60 · 修剪段(Gardener 现场改 UI)

素材序列:`0705-1540`(dashboard)→ `1543`(Gardener sheet 打开)→ `1544`(chip:Reorder)→ `1549`(输入:Add an interview pipeline tracker)→ `1550`(pipeline 原位出现)→ `1551`(输入:bar chart → Done — applied)→ `1552`(终态:bar chart + stages 清单)。

| 时间 | 画面 | 旁白(英文) | 词数≈秒 |
|---|---|---|---|
| 0:30–0:39 | dashboard 细看:Banner/洞察卡/Week 1 环(`1540`) | **Day one. The dashboard already carries the plan — three months, AI plus product — and it tells you why: "not a pivot, a repositioning."** | 23w ≈ 9s |
| 0:39–0:47 | robot icon → Gardener sheet;点 chip、打字(`1543`–`1549`) | **And nothing here is final. Open the Gardener and just ask: reorder my next steps. Add an interview pipeline tracker.** | 20w ≈ 8s |
| 0:47–0:54 | 屏幕原位重组:pipeline 出现 → bar chart 请求 → Done(`1550`–`1552`) | **Each request reshapes the screen in place — even "can I have a bar chart?" Done. Applied. Undoable.** | 17w ≈ 7s |
| 0:54–1:00 | 终态 dashboard 全貌(`1552`) | **A chatbot gives you a wall of text you'll forget. Bonsai keeps the context — visible, living, yours.** | 17w ≈ 6.5s |

合计 77 词 ≈ 30s。若需再砍:先删 beat1 的 `— and it tells you why: "not a pivot, a repositioning."`(-8w ≈ 3s),再 `Done. Applied. Undoable.` → `Done.`(-2w),最后 `visible, living, yours` → `visible, and yours`(-1w)。

### 本段设计意图

- **旁白全部复用画面原文**:`reorder my next steps` = chip 文案;`Add an interview pipeline tracker` = 用户消息原句;`can I have a bar chart` = 打字原句;`Done. Applied. Undoable.` ↔ Gardener 回复 `Done — applied to the screen behind me` + `Undo` 链接。观众听到什么就看到什么
- **收尾打 chatbox 对比**(方向 3,goal-native vs tool-native):chat 返回一堆文字、人转头就忘;Bonsai 把上下文存下来并可视化。措辞让"忘"落在人身上(`you'll forget`)而非 bot,不给评委留杠点;`living` 一词顺带回扣 "living app" 主叙事
- 画面自带彩蛋不用旁白点破:interview pipeline 第一行是 `Anthropic · Applied product eng · actionable`

### 备选(0:54 收尾,如想要 RFS 向的)

- `You're not programming — you're pruning: your own forward-deployed engineer, without writing a line.`(13w,逐字命中 RFS 原文,但对不熟 RFS 的评委太黑话)

## 0:60–0:90 · 收尾 30s

### Resources / connector 段(0:60–0:72)

素材序列:`0705-1611`(空状态:Nothing feeds your garden yet)→ `1612`(Connect a resource 面板:GBrain/HealthKit/Calendar/Mail/Notes)→ `1613`(GBrain · Connected + Linking HealthKit…)。

| 时间 | 画面 | 旁白(英文) | 词数≈秒 |
|---|---|---|---|
| 0:60–0:69 | 空状态 → connector 面板(`1611`–`1612`) | **Goals feed on more than conversation. In Resources, you connect your life: GBrain, your second brain; HealthKit, streaming straight into your health goals.** | 23w ≈ 9s |
| 0:69–0:72 | GBrain Connected · Linking HealthKit(`1613`) | **Tools hold your data. Bonsai holds your goals.** | 8w ≈ 3s |

合计 31 词 ≈ 12s。超时先砍 `straight`(-1w)。

设计意图:
- **`feed` 动词是品牌句的前站**:结尾 `fed by your life` 落地时有呼应而不重复;空状态文案 `Nothing feeds your garden yet` 也在同一动词场里
- **`Tools hold your data. Bonsai holds your goals.` 有画面背书**:`1613` 屏幕上印着 `Tools hold data. Bonsai holds goals — connected sources water the goals they belong to.`,旁白与屏幕文字互证(方向 3 成句的唯一自然落点)
- GBrain 念作 "your second brain" 给不认识它的评委即时定义;HealthKit 跟画面卡片用词一致

### 90 天演化段 + 收尾(0:72–0:88)

素材序列:`0705-1617`(Home = weekly digest:`This week, tended.` + While you slept 卡 + Draft a follow-up/Let it go 决策按钮 + 三个 Stat + Project Highlights)→ `1618`(Daily Training:习惯热力图 + 周运动 bar chart + streak)→ `1619`(Career:成长短板 + 履历 Timeline + Staff readiness 70% 环)→ 品牌收尾帧。

| 时间 | 画面 | 旁白(英文) | 词数≈秒 |
|---|---|---|---|
| 0:72–0:81 | Home weekly digest(`1617`) | **Fast-forward ninety days. Every Sunday it writes your week — and overnight, it moved your prep block and flagged one decision for you.** | 22w ≈ 8.5s |
| 0:81–0:85 | 快闪:Daily Training → Career(`1618`–`1619`) | **Your training, your career, your health — every goal grows its own screen.** | 12w ≈ 5s |
| 0:85–0:88 | 品牌收尾帧(logo/吉祥物) | **Bonsai — fed by your life, tending it back.** | 8w ≈ 3s |

合计 42 词 ≈ 16s,全片落在 0:88,90s 硬上限内。若还有 2–3s 余量,可在品牌句后加 market 一句:`Born global — generated interfaces need no translation.`(7w ≈ 3s,对应书面提交的全球化叙事)。

设计意图:
- **`Fast-forward ninety days` 用已定稿的呈现方案**(demo-design Open Question #2:明示时间跳跃,不假装真用了 90 天)
- **`it writes your week` = periodic note 功能的口播定义**;`moved your prep block`/`flagged one decision` 逐字对应 While you slept 卡内容(prep block moved to Monday morning / One thing needs a decision)+ 两颗决策按钮——"人只做决策"叙事的落点
- **`every goal grows its own screen`** 一句话完成跨 goal 对比(训练=热力图+图表,职业=时间线+进度环,同骨架异控件),这是比 RFS 原文更进一步的主张(同一个人的每个 goal 都有自己的界面)
- **品牌句压轴**,与 0:60 段的 `feed` 前站呼应闭环

## 片尾技术栈卡(end card 字幕,不进旁白)

用法:叠在 0:85–0:88 品牌帧上或作片尾静帧;同段文字直接复用于书面提交的技术概要。旁白已 88s 顶格,此段**不口播**(念出来约 20s 会爆 90s 上限)。

> **Under the hood** — Dynamic UI generation and live editing are powered by Flutter rfw (Remote Flutter Widgets). Natural-language prompts are bridged to the AI, which returns each screen as a DSL structure — not code — translated and rendered on-device. Fully native and cross-platform: iOS, Android, Web, macOS, and ready to extend to Windows.

(中文对照,仅注释:动态 UI 生成与修改依托 Flutter rfw;自然语言 prompt 经桥接给 AI,返回页面 DSL 结构——不是代码——在端内转译渲染;完全原生且跨平台:iOS/Android/Web/macOS,可拓展至 Windows。)

如坚持要口播版,需砍其他段换 ~8s,压缩句:`Built on Flutter's Remote Flutter Widgets: AI returns structure, the device renders it — one native codebase, every platform.`(19w ≈ 7.5s)
