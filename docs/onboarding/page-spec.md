# Onboarding 画面 Spec(S1–S5)

Status: PLANNED(2026-07-05)
上游依据: `docs/onboarding-flow-design.md`(产品设计,APPROVED)+ 用户手绘流程稿(2026-07-05,已逐屏确认)。实现路线见 `docs/onboarding/migration-roadmap.md`,任务清单见 `docs/onboarding/todo.md`。
视觉: **Aurora 设计系统**(`design-system/`,Fresh Matcha)。本文所有颜色/间距/圆角一律引用 token 名,不写裸值;吉祥物一律用 `design-system/lottie/` 资产或其 SVG 姿态,**不用 emoji**。

通用规则:
- 触达目标 ≥ 48dp;正文对比度 ≥ 4.5:1(token 层已数学核验,组件不得自配色)
- 所有网络/文件 I/O 走 Isolate.run(见 roadmap「iOS I/O 铁律」)
- 文案以英文为 demo 主语言(视频需要),下表给出定稿英文;中文仅注释用途

---

## S1 · Splash 开场屏(仅 first-run)

手绘稿①:吉祥物(盆栽,带动效)居中偏上 + 品牌文案 + 底部单按钮。

**路由** `/onboarding/splash`(StatefulShellRoute 之外;redirect 门控见 roadmap D-A2)

**布局**(自上而下,居中)
| 区块 | 内容 | Token/资产 |
|---|---|---|
| 背景 | 单色平涂 | `bg`(无渐变) |
| 吉祥物 | `bonsai-idle.json` Lottie 循环(呼吸+眨眼),约 200dp | `assets/lottie/bonsai-idle.json` |
| 品牌名 | `Bonsai` | display 字级(Baloo 2),`textPrimary` |
| 品牌句 | `Apps you tend, not apps you build.` | body 字级(Nunito),`textSecondary` |
| CTA | `Plant your first seed` 单按钮,全宽内边距 | contained 主按钮:`primary` 底 + `onPrimary` 字 + ink 描边 + elev-pop 硬投影,按压收拢 |

**交互与状态**
- 唯一出口 = CTA → `context.go('/seed?entry=project')`(first-run 默认 Project 框架,设计文档 D2)
- **不可跳过**,无 skip、无登录、无权限弹窗、无 feature tour
- 入场:吉祥物 + 文案淡入上移(`--dur-slow` 级,spring 缓动);CTA 延迟 ~300ms 出现
- **完成即永别**:`firstRunComplete` 置位后(S2 Classified 时)此屏永不再现

**验收**
- [ ] 冷启动(全新安装)必现;`firstRunComplete=true` 后重启直接进 shell
- [ ] Lottie 循环无跳帧;无网络依赖(字体/动画全打包)

---

## S2 · Conversation 对话屏(2 轮追问)

手绘稿②:聊天界面,AI 气泡(带吉祥物头像)+ 用户气泡,底部输入栏,**输入法键盘直接顶起**(无快捷回复 chips)。手绘稿右侧大箭头「same process」:`+ seed` 重入走同一屏。

**路由** `/seed?entry=project|area`

**布局**
| 区块 | 内容 | Token |
|---|---|---|
| 顶栏 | 轻量 appbar:居中标题 `Planting a seed`;first-run 无返回键,`+` 重入时有关闭键(✕,确认弹窗后放弃) | `surface`,title 字级 |
| 消息流 | AI 气泡左对齐(吉祥物 32dp 头像 + `surface-2` 底 + ink 细描边),用户气泡右对齐(`primary-container` 底) | 气泡圆角 `rLg`,间距 `s3` |
| typing 指示 | AI 思考时三点动画气泡 | `subtle` |
| 输入栏 | 单行输入框 + 发送 icon 按钮;吸底,随键盘上移 | field outlined:`surface` 底 + `border` 描边,聚焦 `primary`;发送钮 `icon-btn--filled` |

**对话结构**(轮数客户端强制,状态机见 roadmap D-A4)
1. **开场问题**(客户端固定文案,按入口分支):
   - `entry=project`(含 first-run):`What's something you're working toward right now?`
   - `entry=area`:`What's a part of your life you want to tend for the long run?`
2. **追问 ×2**:每条用户回答 POST `{"converse":true, entry, transcript, turn}` → 显示返回的 `question`(AI 实时生成,一次一问)
3. **收尾**:第 2 答后 POST `{"conclude":true, entry, transcript}` → 显示 `closing` 气泡(含 PARA 分类披露,如 `Got it — your job hunt is a Project: something with a finish line. Planting it now…`);`kind` 可与 `entry` 不同(纠偏,仅口头,无选择控件)
4. closing 气泡停留 ~2s → `context.go('/seed/growing')`

**交互与状态**
- 发送后输入栏禁用至下一问到达;typing 指示常驻等待期
- 多 goal 输入:模型聚焦一个,顺带一句(prompt 层约束,设计文档 D10)
- 新消息自动滚底;键盘弹起不遮输入栏

**降级**(roadmap D-A5)
- converse 3 次重试尽 → 切 `scripted_fallback` 脚本问题(每入口 2 问,如 project:`What kind of role are you looking for?` / `Where are you in the process — just starting, or already interviewing?`),整段保持脚本
- conclude 失败 → 本地分类 = entry;title = 首答截 ~40 字;closing 固定模板

**验收**
- [ ] 两个入口话术正确分支;固定 2 轮后必然收尾
- [ ] 对话中途杀 bridge:下一轮无缝脚本化,用户无感知错误弹窗
- [ ] `Classified` 原子写入 firstRunComplete + goal(growing)后才离屏

---

## S3 · Growing 生长 loading 屏

手绘稿③:吉祥物居中 + Loading,批注「AI thinking」。

**路由** `/seed/growing`

**布局**
| 区块 | 内容 | Token/资产 |
|---|---|---|
| 背景 | `bg` 平涂 | — |
| 吉祥物 | 生长阶段动效:idle 呼吸为底,阶段性切换 seed → sprout 姿态(生长 Lottie 未产出前用现有 idle + SVG 姿态交叉淡化过渡) | `bonsai-idle.json` + `#m-seed`/`#m-sprout` 姿态 |
| 文案轮播 | 每 ~4s 轮换:`Growing your interface…` / `Composed from Bonsai primitives — structure, never code` / `Almost there. Good things grow slow.` | body 字级,`textSecondary`,淡入淡出 |

**数据流**
- 进屏即发 `{"intent":"goal:<slug>", "spec":"<对话转写+dashboard 要求>", "leaf":true}`(ScreenStore.fetch 通道,享三层缓存与 in-flight dedupe)
- **真实时长**(几十秒),无假进度条(设计文档 D3)
- 成功 → `context.go('/<tab>/goal/<slug>')`(kind=project → `/projects/...`,area → `/areas/...`)

**降级**
- 失败或超 90s → 同样导航到 dashboard 路由,由 S4 渲染 Still-growing 占位(流程不阻断)

**验收**
- [ ] loading 期间杀进程:重启进 shell,goal 卡在;不重复生成(命中 bridge 缓存/in-flight)
- [ ] 无假进度条;文案轮播节奏正确

---

## S4 · Goal Dashboard reveal(Project 或 Area)

手绘稿④:标题区 = goal 名(`Projet Dashboard`,红批「could be Projet or Area」),标题右侧 **robot icon**;正文整块批注「AI generated」;底部 5 tab(Home/P/A/R/A)。右侧放大稿:robot icon → **Bottom Sheet,adjust UI with Bot**。

**路由** `/projects/goal/:slug` 或 `/areas/goal/:slug`(shell 内,深度 1)

**布局**
| 区块 | 内容 | Token |
|---|---|---|
| 顶栏 | 返回键 + goal 标题(title 字级)+ **robot icon**(常驻,48dp) | `surface` |
| 正文 | **rfw 渲染 bridge 生成的 dashboard DSL**(冻结组件池 `bonsai.*`) | 组件池自带 Aurora token |
| 底部 | shell 的 5-tab bar(reveal 时首次完整可见) | — |
| coach mark | 一次性浮层:`Bottom tabs are your PARA structure — tap + anytime to plant another.`,点击任意处消失,`coachMarkSeen` 置位 | scrim + `surface-2` 卡 |

**交互与状态**
- reveal 动画:整屏一次性揭示(淡入 + 轻微上移),不做渐进披露(设计文档 D3)
- robot icon → 打开 bottom sheet(`agent_sheet` 模式):自然语言改 UI(`Make this a chart`)。Phase 6 接通编辑;此前 icon 在位、sheet 显示「coming soon」占位 —— **入口位置本期即定型**
- DSL 事件:`back` 出栈;`navigate` 本期视为 no-op + 状态行提示(dashboard 以 leaf 生成);本地状态事件(toggle 等)照常
- 解析失败保上屏,绝不白屏

**Still-growing 占位**(生成未就绪时本屏的原生形态)
- 吉祥物 `bonsai-thirsty.json` + 卡片 `Still growing — check back in a moment`(`card--outlined`)
- 10/30/60/120s 静默重试;成功后 DSL **原位换入**,goal 状态翻 ready

**验收**
- [ ] reveal 落点 = goal 自己的 dashboard,回滑落在所属 tab root(D7/D9)
- [ ] coach mark 仅 first-run 出一次
- [ ] 占位→真 dashboard 原位替换,无导航跳动
- [ ] 二次启动此屏缓存秒开

---

## S5 · `+ seed` 循环(tab root)

手绘稿⑤:tab root 右上 `+ seed` 按钮 → 大箭头「same process」回 S2。

**位置** Projects / Areas tab root(`tab_root_page.dart`)

**布局**
| 区块 | 内容 | Token |
|---|---|---|
| 顶栏 | tab 名 + `+ seed` 按钮(icon `i-plus` + 文字,或 FAB 形态) | `fab--extended`:`secondary` 底 + ink 描边 + elev-pop |
| 空状态 | 无 goal 时:吉祥物 seed 姿态 + `Nothing planted here yet.` + `+ seed` 引导 | `textSecondary` |
| goal 列表 | 注册表驱动的 goal 卡:标题 + kind 徽标 + 状态(growing 卡带 thirsty 小图);点击 → dashboard | `card--pop`,徽标 `chip--filter` |

**交互**
- `+ seed` → `context.go('/seed?entry=<tab>')`:Projects 入口带 project 语境,Areas 带 area 语境;**跳过 S1**(firstRunComplete 已置位,redirect 不触发)
- Home / Resources / Archive 本期保持原生空页(Resources 显示连接器占位卡,kMockData)

**验收**
- [ ] Projects/Areas 两入口话术分支正确;流程结束新 goal 卡出现在对应 tab
- [ ] demo 剧本可复现:first-run 种 Project(求职)→ `+` 种 Area(健康)→ 1 Project + 1 Area

---

## 状态机总览(实现锚点)

```
[S1 Splash] --CTA--> [S2 Opening] -> AwaitingAnswer(0) -> AskingFollowUp(1) -> AwaitingAnswer(1)
   -> AskingFollowUp(2) -> AwaitingAnswer(2) -> Concluding -> Classified(写 prefs+注册表)
   --2s--> [S3 Growing] --成功--> [S4 Revealed]
                        --失败/90s--> [S4 GrowingFallback(占位+静默重试)]
[S5 + seed] --entry=tab--> [S2 Opening](跳过 S1)
```

与 `onboarding-flow-design.md` 决策记录 D1–D10 逐条核对无冲突(D1 多轮对话 ✓ / D2 分类披露+入口纠偏 ✓ / D3 统一 loading 一次性 reveal ✓ / D5 固定 2 轮 ✓ / D7·D9 goal 自有主页 ✓ / D8 模板骨架降级→本期实现为原生占位 ✓ / D10 多 goal 聚焦 ✓)。
