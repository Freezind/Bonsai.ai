# Worklog — c0mpiled-12(2026-07-05)

比赛日工作记录。叙事与差异化的完整论证见 `docs/demo-design-90s.md`(Status: APPROVED),任务清单见 `TODO.md`。

## 已定决策

- **定名 Bonsai**:"apps you tend, not apps you build"——活物、生长、主人修剪(AI 生长 / 人做决策),日本主场,西方认知度高
- **叙事锁定 Approach A**"一个人生,一个活的 app":时间轴叙事,83s 预算留 7s 余量(hook 8s → Day1 18s → Day90 24s → intent 生成 18s → 对比+收尾 15s)
- **视频只讲一条主线,评审无追问**:其余差异化(capability lock / goal-native / 真 native)+ 护城河论证全部落书面提交材料,与视频同等优先级
- **护城河原则**:与模型厂商保持 20 度以上夹角,做垂直层(goal-context 组织 + shipped primitives + 积累的个人化状态),模型是供应商不是对手
- **默认方案**(到点自动生效):旁白 TTS(14:00 前有真人则替换);Day 90 措辞 "Fast-forward 90 days into her job hunt.";商业模式 = 消费者订阅 + primitives 平台第二曲线;全球市场句 = "generated, not translated — ships to every language on day one";intent 延迟呈现 = 加速播放 + 角落真实秒表

## 待办与时间线

1. **10:35** 听 Demo & Submission Instructions:确认视频格式/上传方式,并**确认赛前 PoC 验证 + 赛内 AI 重建的合规边界**(向主办方申报概念验证史)
2. 若走赛内重建:12:00–15:00 在本 repo 用 AI 从 spec 重建 → 15:00–16:00 录制 → 16:00–16:45 剪辑提交(时间线待 10:35 后定稿)
3. 秒级分镜脚本(每镜头 = 画面 + 英文旁白词)
4. 书面提交材料(英文):课题设定 + 产品/技术/商业模式概要 + 全球市场视角
5. **16:30 前提交**,留 30 分钟事故余量

## 验证动作(The Assignment)

粗剪 Day 1 → Day 90 演化段,给一个没看过项目的人看,让 TA 一句话复述看到了什么。如果说不出"app 自己变了/长了",叙事不成立——在投入完整剪辑前就能发现。

## 备忘

- 真机运行一律 `--profile`(debug 模式有 JIT 断点问题);预生成保持串行
- 网络/文件 I/O 的平台注意事项见 `AGENTS.md`(iOS 上的 await 恢复问题及既定规避方案)
- 往届东京场(c0mpiled-7)Garry Tan 未出席,本场是他首次参加此系列
