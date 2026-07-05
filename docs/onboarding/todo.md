# Onboarding TODO

对应 `docs/onboarding/migration-roadmap.md` 的 Phase 0–6;画面细节以 `docs/onboarding/page-spec.md` 为准。每项独立可验收;勾选前先过阶段检查点。

## Phase 0 · Scaffold
- [ ] flutter create(Flutter 3.44.4 / Dart ^3.9,写入 .tool-versions)
- [ ] pubspec deps:go_router ^16 / rfw ^1.1.3 / http / path_provider / lottie(不加状态管理库)
- [ ] `design-system/lottie/bonsai-*.json` → `assets/lottie/`;Baloo 2 + Nunito TTF → `assets/fonts/` + pubspec 字体声明
- [ ] analysis_options(flutter_lints)
- [ ] 检查点:`flutter run` 出空 MaterialApp;`flutter analyze` 干净

## Phase 1 · Tokens + 5-tab 骨架
- [ ] `lib/ds/aurora_tokens.dart`:class Aurora,Fresh Matcha 值 + 吉祥物色板 + elev-pop 常量 + 字级(Baloo 2 / Nunito)
- [ ] `lib/app/router.dart`:StatefulShellRoute.indexedStack,5 分支(Home/Projects/Areas/Resources/Archive),AppTab / DepthObserver / kMaxDepth=3
- [ ] `lib/app/shell_scaffold.dart` + `lib/app/tab_root_page.dart`(原生空页 + 空状态;`+ seed` 按钮占位)
- [ ] `lib/main.dart`:BonsaiApp;根 keep-alive Timer(2s,必须在 shell 之外)
- [ ] 检查点:5 tab Fresh Matcha 渲染,切换重置到根,深度观察器就位

## Phase 2 · Bridge + ping
- [ ] `bridge/serve.py` + `bridge/system_prompt.txt` 就位(环境变量 BONSAI_CONTEXT/BONSAI_CACHE;空 cache.json;组件命名空间 `bonsai.*` 声明)
- [ ] `lib/bridge/bridge_client.dart`:Isolate.run 全包 + 3 次重试 + `--dart-define=BRIDGE_URL`
- [ ] 临时状态行:app 内可见 ping 结果
- [ ] 检查点:真机(adb reverse / LAN IP)空 intent ping 返回 400

## Phase 3 · Onboarding UI(静态,脚本问题)
- [ ] `lib/state/app_prefs.dart`:单例 + ValueNotifier;Isolate.run 读写 `documents/bonsai_state.json`(firstRunComplete / coachMarkSeen / goals)
- [ ] router:`/onboarding/splash`、`/seed?entry=`、`/seed/growing` 顶级路由 + redirect 门控
- [ ] `lib/goals/goal.dart`:Goal 模型(id/title/kind/intent/status)
- [ ] S1 `splash_page.dart`:idle Lottie + 品牌句 + CTA(spec S1)
- [ ] S2 `conversation_page.dart`:气泡流 + typing 指示 + 输入栏(spec S2);本阶段仅 `scripted_fallback.dart` 问题
- [ ] `lib/onboarding/seed_flow_state.dart` + `seed_flow_controller.dart`(sealed 状态机,固定 2 轮)
- [ ] S3 `growing_page.dart`:吉祥物 + 文案轮播(spec S3);终点暂落 stub 页
- [ ] 检查点:离线走完 S1→S2→S3→stub;重启跳过 Splash;中途杀进程重走对话

## Phase 4 · 对话接 AI
- [ ] serve.py:`converse` 模式(+CONVERSE 附加 prompt,单问输出)
- [ ] serve.py:`conclude` 模式(严格 JSON:kind/title/slug/closing/intent)
- [ ] serve.py:内存 TURN_CACHE(sha1(system+entry+transcript))+ 共享 in-flight 去重
- [ ] `bridge_client.nextQuestion()` / `.conclude()`
- [ ] controller:live ↔ 脚本降级(单轮失败切脚本且不回混;conclude 失败本地分类)
- [ ] 检查点:真机 AI 实时追问;对话中途杀 bridge 无缝降级;纠偏(project 入口说 area 型 goal)closing 读得自然

## Phase 5 · rfw 子集 + 生成 + reveal
- [ ] `lib/rfw_pool/pool_runtime.dart` + `local_widgets.dart` 迁入,组件命名空间统一 `bonsai.*`(与 system_prompt.txt 同步 —— capability-lock 三处一致)
- [ ] `lib/screens/screen_store.dart` 迁入(内存+磁盘缓存、in-flight dedupe、Timer.run 交接,模式不动)
- [ ] `lib/goals/goal_dashboard_page.dart`:渲染 DSL;解析失败保上屏;navigate 事件 no-op + 状态行
- [ ] `lib/goals/goal_dashboard_store.dart`:fetch(goal:slug) 封装
- [ ] router:`/projects/goal/:slug`、`/areas/goal/:slug` 子路由(深度 1)
- [ ] S3 接线:进屏发 `{"intent":"goal:<slug>","spec":<转写>,"leaf":true}`;成功 → reveal 导航
- [ ] Classified 原子写入(firstRunComplete + goal 入注册表)移到真实流程
- [ ] 检查点:真机种子→dashboard 全链路;二次启动缓存秒开;loading 中杀进程重启可恢复

## Phase 6 · 兜底 + 润色
- [ ] S4 Still-growing 占位(thirsty Lottie + 卡片)+ 10/30/60/120s 静默重试 + DSL 原位换入
- [ ] coach mark 一次性浮层(coachMarkSeen)
- [ ] `lib/screens/agent_sheet.dart` 迁入;dashboard 顶栏 robot icon → bottom sheet(编辑接通)
- [ ] tab root:goal 卡列表(注册表驱动,growing 态标识)+ `+ seed` 两入口接线(带 entry 语境,跳过 S1)
- [ ] S2 `+` 重入时的关闭键(✕ + 放弃确认)
- [ ] Resources tab 连接器占位卡(kMockData)
- [ ] 检查点:完整 demo 剧本 —— first-run 种 Project(求职)→ `+` 种 Area(健康)→ robot 改 UI;1 Project + 1 Area

## 挂起(等主体开发)
- [ ] dashboard 子页下钻(去掉 leaf 限制,navigate 接通)
- [ ] tab root DSL 化 + warm 预热工具链
- [ ] Home tab 首屏(first-view)
- [ ] 真实 GBrain / HealthKit 连接器
- [ ] 生长阶段专用 Lottie(plant_seed / grow_up / generating 等,见 `design-system/motion-lottie.md`)
