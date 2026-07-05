# Bonsai first-run onboarding flow — 产品设计("种一颗种子")

Status: APPROVED(2026-07-05,/spec 流程,用户拍板)
Scope: 产品/UX 层面。实现细节(bridge 协议、模板、状态管理)另行讨论。
上游依据:`docs/demo-design-90s.md` Onboarding flow 一节(视频 Approach A,onboarding 段 12s,位于 hook 之后 Day 1 之前)。

## Context

用户第一次打开 Bonsai 时没有任何 first-run 体验——app 直接进 5-tab PARA shell(构建期模板)。视频叙事已拍板含 onboarding 段:用户用自然语言说出 goal,app 现场长出属于这个 goal 的界面。这是 "users become their own forward deployed engineers" 的第一分钟。

## 核心概念:onboarding = 种一个 goal 的流程

onboarding 不是一次性向导,它就是"种一颗种子"(plant a seed)的通用流程:

- **每次只处理一个 goal**。first-run 的唯一特殊性:前面多一屏品牌开场,且 app 里还什么都没有
- **后续添加 goal 点 `+` 重走同一个 flow**(跳过开场屏)
- demo 剧本:first-run 种求职(Project)→ `+` 种健康(Area)→ 最终 app = 1 Project + 1 Area,跨 goal 对比镜头素材自然产生

onboarding 对话、`+`、chat button 三者是**同一个交互面**:自然语言进,界面出。种下(onboard)→ 修剪(chat)= "apps you tend" 的产品化。

## Flow(5 步)

### Step 1 · 开场屏(仅 first-run)

- 画面:Aurora 视觉,极简盆栽/种子意象 + 品牌句
- 文案:`Bonsai` / `Fed by your life, tending it back.`
- 唯一 CTA:`Plant your first seed` → 进入对话
- 无登录、无权限请求、无 feature tour
- **不可跳过**:first-run 没有 skip——空 app 没有意义,第一颗种子就是 app 存在的前提
- **完成即永别**:种下第一个 goal(或触发失败降级)即视为 first-run 完成,此后打开 app 直接进 shell,开场屏永不再现

### Step 2 · 对话(固定 2 轮追问)

入口按类型分化,开场问题本身就在教 PARA:

- **Projects tab 的 `+`(及 first-run 默认)**:`What's something you're working toward right now?`——有终点的事
- **Areas tab 的 `+`**:`What's a part of your life you want to tend for the long run?`——长期、永不结束的方向

对话结构定死:开场问题 → 追问 1 → 追问 2 → AI 主动收尾。追问只问到"能归类 + 能生成像样 dashboard"为止(最小可生成),不询问隐私细节;更深的 context 留给 Day 1 确认区收集(与既有叙事分工一致)。

求职示例追问:`What kind of role are you looking for?` → `Where are you in the process — just starting, or already interviewing?`

**归类展示(不询问)**:AI 收尾时展示归类结果,顺便教 PARA 语义:
- Project 版:`Got it — your job hunt is a Project: something with a finish line. Planting it now…`
- Area 版:`…is an Area: something you tend for the long run.`
- 归类纠偏(兜底):用户在 Project 入口说了个没有终点的事 → `That sounds like an Area — something you tend, not finish. Planting it there.`
- 模糊输入:听不懂就把追问轮用来澄清;仍不确定时按"有没有终点"口头确认一句,不出选择控件

### Step 3 · 生长 loading(统一揭示)

- 全屏盆栽生长动画,真实时长(几十秒),不做假进度条
- 微文案轮播,顺便讲论点:
  - `Growing your interface…`
  - `Composed from Bonsai primitives — structure, never code`
  - `Almost there. Good things grow slow.`

### Step 4 · 揭示:goal 的 dashboard

- loading 完成 → 直接落在刚种下的 goal 的主页(dashboard),一次性完整揭示。每个 Project/Area 都有自己的 dashboard
- 一条轻提示(coach mark,只出现一次,可跳过):底部 tab 是你的 PARA 结构;`+` 随时种下一颗
- **chat button 常驻**每个 goal 的 dashboard:用户随时用自然语言 fine-tune 这个 UI(`Make this a chart` / `Add my interview pipeline`)。揭示不是终点,是修剪的开始
- 这一屏是视频 onboarding 段的收尾镜头

### Step 5 · 再种

- tab 根 / dashboard 常驻 `+`,点击重入 Step 2(带该 tab 的类型语境)
- 用户一次说了多个 goals 时:AI 只围绕一个展开,其余口头带过(`Let's start with the job hunt — you can plant the others anytime with +`)

## Resources = connectors

Resources tab 的产品定位:**外部 context 的接入口**(connector 列表),数据从 connector 流入、归属到 goal——"工具持有数据,Bonsai 持有目标"的具体产品面。

- **GBrain 是第一个 resource 后端**:个人知识图谱喂进 goal context
- HealthKit 是第二个(健康 Area,post-hackathon)
- demo 呈现:Resources tab 展示 connector 卡片(`GBrain · Connected` / `HealthKit · Coming soon`,kMockData)

## 失败降级(first-run 无"上一屏"可保留)

- 生成失败 → 仍然揭示构建期模板骨架(空 PARA shell),goal 位置放卡片:`Still growing — check back in a moment`
- 后台自动重试,成功后卡片原位换成真 dashboard
- 用户永远有 app 可用;隐喻自洽(盆栽本来就慢)

## 12s 视频映射

打字镜头加速播放 + 真实秒表角标(与 intent 生成段同一处理):

| 镜头 | 秒数 |
|------|------|
| 开场屏(品牌句 + Plant your first seed) | 2s |
| 对话(开场问题 + 2 轮追问,加速) | 4s |
| 生长动画(加速 + 秒表角标) | 3s |
| dashboard 揭示 | 3s |

## Out of Scope

- 账号/登录、语音输入(纯打字)、系统权限请求、通知引导
- seeds 库(多余 goals 暂存再种)——已否决,改为 `+` 重走 flow
- 真 GBrain / HealthKit 接入(demo 用 kMockData 卡片)
- 实现细节:bridge 协议扩展、对话状态管理、动画实现——另行讨论

## 决策记录

| # | 决策 | 结果 |
|---|------|------|
| D1 | 输入形态 | 对话式多轮 |
| D2 | PARA 归类 | AI 自动归类并展示(+入口分化后作为纠偏兜底) |
| D3 | 等待体验 | 统一 loading 后一次揭示 |
| D4 | spec 深度 | 只做产品设计,实现另议 |
| D5 | 对话结束 | AI 判断够了就收(固定 2 轮追问) |
| D6 | 追问深度 | 最小可生成,深 context 留给 Day 1 确认区 |
| D7 | 揭示落点 | goal 自己的 dashboard(每个 Project/Area 有主页) |
| D8 | 失败降级 | 预置模板骨架兜底 + 后台重试 |
| D9 | dashboard 定位 | 每个 goal 的主页,非全局 Home tab |
| D10 | 多 goal 处理 | AI 只问一个,其余 `+` 重走 flow |
