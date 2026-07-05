# AGENTS.md

This file provides guidance to AI coding agents (Claude Code 等) when working with code in this repository. `CLAUDE.md` is a symlink to this file.

## Purpose

为 hackathon **c0mpiled in Japan pt.3**(2026-07-05,https://luma.com/compiled-4qzo)而建,选题是 YC RFS Summer 2026 的 **Dynamic Software Interfaces**(https://www.ycombinator.com/rfs#dynamic-software-interfaces)。项目验证的命题:开发者只交付设计好的 primitives(冻结组件池),用户用自然语言让 agent 现场组合出属于自己的界面 —— 即 RFS 所说的 "users become their own forward deployed engineers"。

这决定了取舍:这是 PoC,mock 数据(`kMockData`)是故意的,bridge 只是开发环境工具,不追求生产级健壮性和测试覆盖;但**模型只输出结构化 DSL、永不输出可执行代码**是立身之本,任何改动不得妥协。详细背景见 `docs/hackathon-compiled.md`(赛事要求)和 `docs/yc-rfs-summer-2026.md`(RFS 原文及与本项目的对应关系)。

## What this is

**Bonsai**("fed by your life, tending it back"):一个 Flutter 应用,用户输入意图 → 本地 Claude 桥接服务生成 rfw DSL(只有结构,永远不是可执行代码)→ 设备端通过冻结的组件池(frozen component pool)渲染。

> **状态(2026-07-05)**:lib/、bridge/、design-system/ 均已就位;onboarding flow(种一颗种子)Phase 0–6 已实现(路线图与任务清单见 `docs/onboarding/`),主体 tab DSL 化与 warm 预热尚未开始。demo 叙事设计文档见 `docs/demo-design-90s.md`。

三个部分:

- `lib/` — Flutter app(Dart SDK ^3.9,Flutter 3.44.4,见 `.tool-versions`)
- `bridge/` — Mac 上运行的本地 Python 桥接(`serve.py`,无第三方依赖),用 headless `claude -p` 生成 rfw 文本 DSL;不用 API key,走本地 claude 登录。DSL 的转译依托 Flutter 官方 **rfw**(Remote Flutter Widgets):设备端把结构文本实时转译成真正的原生 widget 树 —— app 因此是**完全原生**的,没有 WebView/嵌入层,模型也永远接触不到可执行代码
- `design-system/` — 纯 HTML/CSS 活风格指南(**Fresh Matcha** 设计系统:奶白纸底 + 春绿×天蓝,墨线描边 + 硬投影的绘本剪纸感,Baloo 2 × Nunito 圆体,手绘盆栽吉祥物五阶段),不参与构建;Dart 侧 token 层在 `lib/ds/aurora_tokens.dart`(类名沿用 `Aurora` 以保 API 稳定,值即 Fresh Matcha)

## Commands

```bash
flutter pub get
flutter test                          # 全部测试(test/widget_test.dart)
flutter analyze                       # lint(flutter_lints 规则)

# 运行 bridge(必须先于 app,在 Mac 上)
python3 bridge/serve.py               # 默认端口 8787;BONSAI_BRIDGE_PORT / BONSAI_BRIDGE_MODEL 等环境变量见 serve.py 头部

# 真机运行(iOS,开发)
flutter run -d <device> --dart-define=BRIDGE_URL=http://<mac-lan-ip>:8787
# 录屏/演示版:release 才能脱线从主屏图标独立启动(debug 版会闪退)
#   RESET_STATE=true    每次冷启动清空持久化状态(重录 first-run 用)
#   SKIP_ONBOARDING=true 跳过种子流程直进 shell
flutter run --release -d <device> --dart-define=BRIDGE_URL=http://<ip>:8787 \
  --dart-define=RESET_STATE=true --dart-define=SKIP_ONBOARDING=true
# Android:adb reverse tcp:8787 tcp:8787 后 BRIDGE_URL 用 http://localhost:8787
```

会场/校园 Wi-Fi 常有客户端隔离(手机永远打不到 Mac,报 Host is down)——用 iPhone 个人热点 + USB 线共享,BRIDGE_URL 指向 Mac 的热点网口 IP(172.20.10.x)。生成失败时,完整 DSL 会追加到 `bridge/dsl.log`。warm.py 预热工具链属主体开发,尚未迁入(见 TODO.md)。

## Architecture

**数据流**:intent 文本 → `BridgeClient`(`lib/bridge/bridge_client.dart`)POST 到 bridge `/generate` → bridge 拼上 `bridge/system_prompt.txt` 调 `claude -p` → 返回 rfw 文本 DSL → `applyDsl`(`lib/rfw_pool/pool_runtime.dart`)解析并渲染。DSL 解析失败要保留上一屏(降级),绝不白屏。

**能力锁(capability lock)哲学**:模型只能组合白名单组件。组件池在三处必须保持同步 —— `lib/rfw_pool/local_widgets.dart`(Dart 实现)、`bridge/system_prompt.txt`(告诉模型有哪些组件)、`lib/ds/aurora_tokens.dart`(设计 token)。改组件池时三处一起改。

**导航模型(封闭有限 app)**:`lib/app/router.dart` 用 GoRouter `StatefulShellRoute` — 5 个底部 tab 是平级(深度 0),只有 push 的子页累积深度,切 tab 重置到根。`kMaxDepth = 3`:深度 3 的屏是封闭叶子(可交互但不能再往下导航),深度上限在设备端强制执行,DSL 里混进更深的链接也无效。tab 根目前是原生 Dart 页;demo 的 goal 详情页是构建期固定 rfw 模板(`lib/rfw_pool/demo_dashboards.dart`,0 token)。warm.py 子树预生成属主体开发,尚未迁入。

**三层缓存,每个 intent 一生只生成一次**:
1. bridge 端 `bridge/cache.json` — key 是 sha1(system_prompt + intent),改 system_prompt.txt 自动失效全部旧条目;bridge 有 in-flight dedupe(重试的请求会等待正在进行的生成,不会重复跑)
2. 设备端 `ScreenStore`(`lib/screens/screen_store.dart`)— 内存 + 磁盘(documents/dsl_cache.json),含 in-flight dedupe
3. `warm.py` 的 peek 请求只查缓存不生成,保证幂等

**警告:iOS 上 await 会永久卡死(已在多个 Flutter 版本复现)** — 主 isolate 上由 socket/文件事件完成的 Future,其 awaiter 间歇性永远不恢复。已确立的规避方案,改动网络/文件 I/O 时必须遵守:
- 所有 dart:io 网络和文件 I/O 都放进 `Isolate.run`(见 `bridge_client.dart`、`screen_store.dart`)
- 跨共享 Future 取结果用 `.then` + `Timer.run` 手动交接到 Completer,不要直接 `await sharedFuture`(见 `ScreenStore.fetch`)
- `ShellScaffold` 里有 2 秒周期的 keep-alive Timer 维持事件循环唤醒
- ValueNotifier 更新可能发生在帧中,用 `SchedulerBinding` 判断相位后再通知(`setStatus`、`_DepthObserver`)

**Bridge 对 app 的协议**(`bridge/serve.py`,单文件):`POST /generate` 带 `{"intent"}`,可选 `leaf`(叶子屏,禁止 navigate intent)、`peek`(只查缓存)、`bundle`(一次生成多屏,`=== screen: <id> ===` 分隔)。空 intent 返回 400 —— app 用它做连通性 ping。

## Notes

- rfw DSL 规则见 `bridge/system_prompt.txt`:数字必须是 double(16.0),整屏包在 `Canvas(child: ...)`,`widget root = ...;` 只有一个
- 测试断言的文本来自 onboarding 文案与 `DemoScenario`/固定模板内容,改文案会影响 `test/widget_test.dart`

## Commit message conventions

- Write commit messages in English, imperative mood, present tense: "Add", not "Added" or "Adds".
- Subject line under ~70 chars. Body only when the "why" isn't obvious from the diff — skip it for small, self-explanatory changes.
- No AI co-author trailers (`Co-Authored-By: Claude ...`, `Claude-Session: ...`, etc.) and no emoji. Commits should read as if a human on the team wrote them.
- One logical change per commit. Don't bundle unrelated fixes/refactors into a single commit just because they landed in the same session.
- Reference issue/PR numbers when relevant (`Fixes #12`), but never fabricate one.
