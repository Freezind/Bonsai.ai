# Onboarding 开发路线图

Status: PLANNED(2026-07-05)
Scope: onboarding flow(种一颗种子)+ 5-tab app 骨架的实现路线。产品设计依据 `docs/onboarding-flow-design.md`(APPROVED),画面细节见 `docs/onboarding/page-spec.md`,任务清单见 `docs/onboarding/todo.md`。
视觉依据: **Aurora 设计系统**(`design-system/`,Fresh Matcha 主题)+ 吉祥物 Lottie(`design-system/lottie/bonsai-*.json`)。

## 总原则

- **onboarding 全部原生 Dart**,不走 DSL。桥接 AI bridge 做三件事:实时生成追问、收尾分类、生成第一个 goal dashboard(dashboard 是 rfw DSL,由 reveal 屏渲染)。
- **app 骨架 = 5 tab**(Home / Projects / Areas / Resources / Archive),GoRouter `StatefulShellRoute` tab 栈。骨架本期**不接 DSL**,tab root 是原生空页;主体开发再做桥接。
- **状态管理从简**:ValueNotifier + 单例,与 ScreenStore/rfw 层同一习惯。不引入 riverpod/hooks 等新框架。
- **iOS I/O 铁律**(必须遵守,历史上已多次踩坑):
  - 所有 dart:io 网络/文件 I/O 放进 `Isolate.run`
  - 跨共享 Future 取结果用 `.then` + `Timer.run` 手动交接到 Completer,不直接 `await sharedFuture`
  - 根 widget 常驻 2 秒 keep-alive Timer 维持事件循环唤醒(注意:onboarding 先于 shell 存在,Timer 必须放在 main.dart 根部,不能放 ShellScaffold)
- goal ≡ project/area(同义词,文档统一用 goal)。

## 目标 lib/ 结构

```
lib/
  main.dart                      # BonsaiApp;先 await AppPrefs.init() 再 runApp;根 keep-alive Timer
  app/
    router.dart                  # GoRouter StatefulShellRoute,5 tab 分支 + onboarding 顶级路由 + redirect 门控
    shell_scaffold.dart          # shell 外壳(顶栏 wordmark、robot icon、底部 tab bar)
    tab_root_page.dart           # 原生空 tab root(空状态 + "+ seed" 按钮 + goal 卡列表)
  ds/
    aurora_tokens.dart           # Aurora 设计系统 token(Fresh Matcha 值 + 吉祥物色板)
  bridge/
    bridge_client.dart           # bridge HTTP 客户端(Isolate.run 全包),含 nextQuestion()/conclude() 两个 onboarding 方法
  state/
    app_prefs.dart               # AppPrefs 单例:firstRunComplete / coachMarkSeen / goal 注册表;Isolate.run 读写 bonsai_state.json
  goals/
    goal.dart                    # Goal {id, title, kind: project|area, intent, status: growing|ready}
    goal_dashboard_page.dart     # reveal 落点:渲染 bridge 生成的 dashboard DSL;原生 Still-growing 占位
    goal_dashboard_store.dart    # 拉取 DSL + 静默重试退避
  onboarding/
    seed_flow_state.dart         # sealed 状态机状态
    seed_flow_controller.dart    # ValueNotifier<SeedFlowState> + async submitAnswer()
    scripted_fallback.dart       # 脚本问题(按入口分支)+ 本地分类兜底
    ui/
      splash_page.dart           # S1 开场屏(仅 first-run)
      conversation_page.dart     # S2 对话
      growing_page.dart          # S3 生长 loading
      widgets/                   # 气泡、typing 指示、文案轮播、吉祥物 Lottie 容器
  screens/
    screen_store.dart            # DSL 缓存(内存+磁盘)+ in-flight dedupe(Phase 5 迁入)
    agent_sheet.dart             # robot bottom sheet,adjust UI with bot(Phase 6 迁入)
  rfw_pool/
    pool_runtime.dart            # rfw Runtime 构建 + applyDsl(Phase 5 迁入)
    local_widgets.dart           # 冻结组件池,rfw 命名空间 bonsai.*(Phase 5 迁入)
```

## 架构决策

### D-A1 状态管理:ValueNotifier + 单例
新代码与既有层同一习惯:`SeedFlowController` 持 `ValueNotifier<SeedFlowState>`;`AppPrefs` 单例持 `ValueNotifier` 并用 Isolate.run 读写 `documents/bonsai_state.json`(与 ScreenStore 磁盘模式一致);页面 = StatefulWidget + ValueListenableBuilder。不用 shared_preferences(平台通道 Future 在 iOS 死锁问题上未经本项目验证,文件 + Isolate.run 是已验证路径)。

### D-A2 路由与门控
onboarding 路由在 StatefulShellRoute **之外**:

```
/onboarding/splash      # S1,仅 first-run
/seed?entry=project|area  # S2 对话
/seed/growing           # S3 loading
```

redirect 同步读 `AppPrefs.instance.firstRunComplete`:未完成且不在 onboarding 路径 → 跳 `/onboarding/splash`。flag 只翻转一次,流程内跳转全部显式 `context.go(...)`,不需要 refreshListenable。`+ seed` 直接 `context.go('/seed?entry=area')`,redirect 不再触发。

reveal 落点:每个 tab 分支加子路由 `goal/:id`(如 `/projects/goal/job-hunt`,深度 1)。reveal = `context.go('/projects/goal/job-hunt')` —— 分支切换 + 压栈一步完成,回滑落在 tab root(满足设计文档 D7/D9:dashboard 是 goal 自己的主页)。

### D-A3 bridge 协议扩展(扩展 POST /generate,不加新端点)

**(a) 对话轮次 `converse`** —— AI 实时生成下一个追问:

```json
POST /generate
{"converse": true, "entry": "project",
 "transcript": [
   {"role": "assistant", "text": "What's something you're working toward right now?"},
   {"role": "user", "text": "Finding a staff engineer job"}],
 "turn": 1}
→ 200 {"question": "What kind of role are you looking for?", "latency_ms": 4200}
```

新增 CONVERSE 附加 system prompt:只输出一个简短追问;目标 = 达到"可分类 + 可生成像样 dashboard"的最少信息;不问隐私细节;输入模糊时用这一轮澄清。纯文本输出,无 DSL。

**(b) 收尾分类 `conclude`** —— 秒级返回,**不生成 dashboard**(分类气泡要先于 loading 屏出现):

```json
{"conclude": true, "entry": "project", "transcript": [ ...全部 6 条消息... ]}
→ 200 {"kind": "project", "title": "Job hunt", "slug": "job-hunt",
       "closing": "Got it — your job hunt is a Project: something with a finish line. Planting it now…",
       "intent": "goal:job-hunt", "latency_ms": 6100}
```

`kind` 可与 `entry` 不同(设计文档的纠偏兜底);closing 文案由模型出,纠偏才读得自然。严格 JSON 输出,复用现有 fence 剥离/`{...}` 提取。

**(c) dashboard 生成 —— 零新协议**,走现有 intent 通道:

```json
{"intent": "goal:job-hunt",
 "spec": "Dashboard for the goal 'Job hunt' (a PROJECT). Conversation:\n<transcript>\n...",
 "leaf": true}
```

关键:`spec` 注入生成任务但**不进缓存 key**(既有机制),`goal:<slug>` 成为稳定缓存 key —— 三层缓存、in-flight dedupe、未来 warm 工具全部免费复用。`leaf: true` 使 dashboard 不含下钻 intent(子页生成属主体开发);edit 模式(robot sheet)对 leaf 屏照常可用。

**轮次缓存语义**:`converse`/`conclude` 结果进独立**内存** TURN_CACHE(key = sha1(system + entry + transcript)),共享 in-flight 去重表,保证客户端 3 次重试幂等(丢包重试不会得到不同问题、不会重跑模型)。不落盘 —— 转写不会跨会话复现,不污染 cache.json。

### D-A4 对话状态机

```
Opening → AwaitingAnswer(0) → AskingFollowUp(1) → AwaitingAnswer(1)
        → AskingFollowUp(2) → AwaitingAnswer(2) → Concluding
        → Classified → Growing → Revealed | GrowingFallback
```

- 追问轮数(固定 2)由客户端 controller 强制,不问模型"够了吗"(设计文档 D5)。
- **对话中途不持久化**:对话不到一分钟,中途被杀直接重走(splash 是否出现只看 firstRunComplete)。
- `Classified` 时原子写入两件事:`firstRunComplete = true` + Goal(status: growing)入注册表。此后 loading 中被杀也能完美恢复:重启 → shell → Projects tab 有 goal 卡("Still growing")→ 拉取命中 bridge 缓存或加入 in-flight。

### D-A5 降级链(逐级,互不纠缠)

| 失败点 | 行为 |
|---|---|
| 单轮 converse 失败(3 次重试尽) | 切 `scripted_fallback` 脚本问题(按入口分支 2 问),此后整段对话保持脚本,不混用 |
| conclude 失败 / 对话已是脚本 | 本地分类 = entry 类型;title = 首条回答截 ~40 字;slug 去重(重名加 `-2`);closing 用固定模板 |
| dashboard 生成失败 / 超 90s | 流程照常完成:goal 以 growing 状态入注册表,reveal 照常导航,GoalDashboardPage 渲染**原生** Fresh Matcha 占位(吉祥物 thirsty Lottie + "Still growing — check back in a moment" 卡);10/30/60/120s 静默重试,in-flight dedupe 保证重试是**加入**进行中的生成而非重启;成功后 DSL 原位换入,状态翻 ready |

占位用原生实现(而非 rfw 模板)是有意的 —— 本期完全不需要模板层。

### D-A6 标识符规范
- rfw 组件命名空间:`bonsai.*`(capability-lock 三处同步:`lib/rfw_pool/local_widgets.dart` + `bridge/system_prompt.txt` + `lib/ds/aurora_tokens.dart`)
- App 类:`BonsaiApp`;bridge 环境变量:`BONSAI_CONTEXT` / `BONSAI_CACHE`
- 持久化文件:`bonsai_state.json`(prefs + goal 注册表)、`dsl_cache.json`(DSL 缓存)

### D-A7 Token 与资产
- `lib/ds/aurora_tokens.dart`,`class Aurora`,值 = Fresh Matcha(`design-system/styles.css`):primary `#2C8248`、secondary `#2F7BB4`、accent `#F4B63C`、bg `#F6F4E9`、ink `#26302A` 等;吉祥物色板(mLeaf `#3FA34D`、mPot `#E8703A`、mInk `#33302B`…)与 Lottie 烘焙值一致。
- 招牌 elev-pop:`BoxShadow(offset: Offset(3,3), blurRadius: 0, color: ink)`。
- **字体打包 TTF**(Baloo 2 display + Nunito body),不用 google_fonts 运行时拉取(demo 现场热点网络不可靠)。Patrick Hand 本期不需要。
- Lottie:`design-system/lottie/bonsai-{idle,cheer,thirsty,sleep}.json` → `assets/lottie/`,`lottie` 包加载。

## 分阶段计划

| Phase | 内容 | 检查点(app 可跑) | 风险 |
|---|---|---|---|
| **0 Scaffold** | flutter create(Flutter 3.44.4 / Dart ^3.9);deps:`go_router ^16` `rfw ^1.1.3` `http` `path_provider` `lottie`(零状态管理新依赖);Lottie + 字体资产入 assets;analysis_options | `flutter run` 出空 MaterialApp | 版本漂移;iOS 签名 |
| **1 Tokens + 骨架** | `aurora_tokens.dart`(Fresh Matcha 值);`app/router.dart`:StatefulShellRoute 5 分支,tab root = 原生空页 + `+ seed`;AppTab / DepthObserver / kMaxDepth 机制照常;keep-alive Timer 放 main.dart 根部;`BonsaiApp` | 5 tab Fresh Matcha 渲染,切换正常,深度观察器就位 | 低;go_router 16 API 对齐 |
| **2 Bridge + ping** | `bridge/serve.py` + `system_prompt.txt` 就位(环境变量 `BONSAI_*`,空 cache.json,命名空间 `bonsai.*` 声明);`bridge_client.dart`(Isolate.run 全包 + 3 次重试 + `--dart-define=BRIDGE_URL`);临时状态行显示 ping 结果 | 真机空 intent ping 返回 400 | 真机 LAN 可达性;Mac 上 claude CLI 登录 |
| **3 Onboarding 静态** | S1/S2/S3 三页 UI 全建(**仅脚本问题**,不接 bridge);`app_prefs.dart` + redirect 门控;流程终点先落 stub 页;文案轮播;吉祥物 Lottie 状态 | 离线可走完整流程;杀进程重启跳过 splash | 全视觉,无逻辑风险 |
| **4 对话接线** | serve.py `converse`/`conclude` 模式 + TURN_CACHE;`bridge_client.nextQuestion()`/`.conclude()`;controller 按 D-A5 在 live/脚本间切换 | 真机 AI 实时追问;对话中途杀 bridge 无缝降级脚本 | prompt 调优(问题质量/延迟);JSON 提取边角 |
| **5 rfw 子集 + 生成 + reveal** | `pool_runtime.dart` + `local_widgets.dart`(命名空间 `bonsai.*`,与 system_prompt 同步)+ `screen_store.dart` 迁入;`GoalDashboardPage`(解析失败保上屏、navigate 视为 no-op);growing 页发 `generate(goal:<slug>, spec, leaf)`;`goal/:id` 子路由;reveal 导航 | 真机种子→dashboard 全链路;二次启动 dashboard 缓存秒开 | **风险峰值**:iOS 死锁面 + rfw 面;缓解 = I/O 模式逐字节沿用已验证写法 |
| **6 兜底 + 润色** | Still-growing 占位 + 重试退避;coach mark(一次性,`coachMarkSeen`);`agent_sheet.dart` 迁入(robot icon → bottom sheet);tab root `+ seed` 全接 + goal 卡列表(注册表驱动) | 完整 demo 剧本:first-run 种 Project → `+` 种 Area → bot 改 UI | 生成 dashboard 上的 edit 质量;coach mark 层级/时机 |

排序理由:Phase 3 先于 4 —— demo 先有离线保底脊柱,AI 再入环(hackathon 保险丝);Phase 5 单独隔离,因为它承载全部 iOS 死锁面与 rfw 面。

## 本期不做

- warm.py 预热 / plan / bundle 工具链(主体开发期)
- 模板全集与 tab root DSL 化(骨架保持原生空页)
- context packs / persona 数据(ScreenStore.uiData 用中性默认值)
- debug 页(Phase 6 视调试需要可加,半小时工作量)
- 子页下钻生成(dashboard 以 leaf 生成,无 intent 链接)
- 真实 GBrain / HealthKit 接入(Resources tab 维持 kMockData 连接器卡)

## 验收(整体)

1. first-run:Splash → 对话(AI 追问)→ 分类披露 → 生长 loading → 落在 goal 自己的 dashboard(rfw 渲染),coach mark 一次
2. 杀 bridge 重走:脚本问题兜底,全流程可完成,占位卡 + 静默重试语义正确
3. `+ seed`(Areas 入口)重入同一流程,跳过 Splash,分类为 area
4. 重启 app:不再出 Splash;goal 卡在对应 tab root;dashboard 缓存秒开
5. `flutter analyze` 干净;tab 深度/切换行为与骨架测试一致
