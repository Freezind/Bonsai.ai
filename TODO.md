# TODO

## 诚实清单:哪些是 Mock,接下来先做什么

> hackathon PoC 的边界声明。demo 里"看起来在动"的部分,按真实程度分三档。

### ✅ 今天就是真的(不是 mock)

- Onboarding 对话:追问与分类由本地 claude 实时生成(`converse`/`conclude`),含纠偏(project 入口说出 area 型目标会被纠正)
- bridge 不可达时的全链路降级(脚本问题 → 本地分类 → Still-growing 占位 + 静默重试)
- goal 注册表与状态的设备端持久化;三层缓存 + in-flight dedupe
- rfw 冻结组件池渲染(capability lock:模型只出结构,永不出代码)
- 设计系统、吉祥物五阶段、iOS I/O 规避模式

### 🎭 纯 Mock(demo 演出用,数据/行为都是假的)

- [ ] **Home 周报(periodic note)**:整屏内容来自 `DemoScenario` 硬编码(persona "Aya",`docs/demo-fake-data.md`)。没有真实活动流,没有 AI 生成链路,"While you slept" 的两个决策按钮是死的 → 真实现:夜间 cron 走 bridge 汇总各 goal 数据出 digest(PN4)
- [ ] **Day-90 世界**:长按 Home 注入的假 goal 集(2P+2A)。树的成长阶段(stage)是手工赋值的,不是靠真实 tending 攒出来的 → 真实现:stage 由使用行为推进(打卡、完成 todo、周报连续性)
- [ ] **四个 goal 详情页**(`kDemoDashboards` G1–G4):构建期写死的 rfw 模板,公司名/指标/习惯记录全部虚构 → 真实现:见下方"固定框架转向"
- [ ] **Resources tab**:连接器卡是静态假卡 —— GBrain "Connected" 并没有连,HealthKit 尚未接 → 真实现:GBrain MCP 读取 + HealthKit 授权读取
- [ ] **顶栏 "bridge connected"**:录屏用硬编码覆盖,永远显示已连接(`bridge_client.dart` DEMO OVERRIDE)→ 撤销此覆盖,恢复真实状态显示
- [ ] **当前真机 build 是录制版**:`RESET_STATE=true` 每次冷启动清空状态 —— 这是录屏行为,不是产品行为,交付前必须去掉该 dart-define 重装

### 🚧 半真(链路真实存在,但被 pivot 取代或未完成)

- [ ] **落实"固定框架"转向**(已拍板,未实现):dashboard = 构建期 rfw 模板 + `data.*` 绑定;AI 只做受限调整 —— **list 重排/增删项** + **预定义槽位内的控件形态枚举切换**(Ring↔Bar↔Stepper)。现在 bot sheet 的 edit 仍是"整屏 DSL 重写"旧路径,必须收窄为数据/配置层输出
- [ ] **conclude 顺带提取初始数据**:分类时让 AI 输出初始 dashboard 数据 JSON(next steps、阶段)填充固定框架;生长页改 2–3 秒动效(不再等整屏生成)
- [ ] **Gardener quick actions**:四条建议是写死的,应按当前屏内容生成
- [ ] **子页导航**:dashboard 目前全是叶子屏,`navigate` 是 no-op → 主体开发接通(深度 ≤3 的封闭子树)
- [ ] **数据轴**:`ScreenStore.uiData` 是中性默认值,context pack/persona 数据流未接
- [ ] **Archive tab**:占位空页
- [ ] **吉祥物动效**:11 个规格里只有 4 个 Lottie(idle/cheer/thirsty/sleep),app 内成长动画是 SVG 交叉淡化顶替 → 按 `design-system/motion-lottie.md` 补齐(plant_seed/grow_up/bloom/fruit/wither/water_revive/generating)
- [ ] **真机检查点补验**:`docs/onboarding/todo.md` 里 4 个真机检查点(今天已跑通大部分,补勾+记录)



- [ ] **写秒级分镜脚本**(Approach A"一个人生,一个活的 app",83s 预算:hook 8s → Day1 18s → Day90 24s → intent 生成 18s → 对比+收尾 15s;每镜头 = 画面 + 英文旁白词)——依据已批准的设计文档 `docs/demo-design-90s.md`,10:35 主办方公布提交规则后回填格式
- [ ] The Assignment:粗剪 Day 1 → Day 90 演化段给没看过项目的人看,让 TA 一句话复述——验证叙事是否成立

- [ ] 研究往届 c0mpiled 获奖队伍的 90 秒 demo video(结构、节奏、怎么在 90 秒内讲清 problem → demo → market)
  - 线索:主办方的往届活动 highlights 页 https://www.notion.so/melts/Transpose-x-OUVC-YC-367903bd64b8807a9bbafc9a07c50a80
  - 线索:东京场 c0mpiled-7 / San Fransokyo(2026-03-08,虎ノ门 Hills)详情页 https://melts.notion.site/Transpose-IPC-YC-2-305903bd64b88088a162e8e9ff8682cd — 规则同样是"90 秒视频、评委只看录制成果物",参考价值最直接
- [ ] 找其他国家/城市场次的 c0mpiled 获奖 90 秒 demo video(本场是 c0mpiled-12,东京是 c0mpiled-7,系列至少办过 12 场,应有海外场次的获奖作品可参考)
