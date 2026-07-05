# YC Requests for Startups — Summer 2026

> 来源:https://www.ycombinator.com/rfs(抓取于 2026-07-04)
> 本项目选题为 **Dynamic Software Interfaces**,全文如下;hackathon 可选的另外两个方向附在文末。

## Dynamic Software Interfaces(本项目选题)

By [Ankit Gupta](https://www.ycombinator.com/people/ankit-gupta) — https://www.ycombinator.com/rfs#dynamic-software-interfaces

> Before AI, users of a piece of software all interacted with the same interface. There were only light customizations like a few different views or theme and color options. When users think about "personalization" like on Netflix, it still has the same layout for everyone, just different imagery. As a result, most software has a one-sized-fits-all feel rather than being hypercustomized to a user.
>
> As an example: the way I use an email is very different from how most college students use email, yet all email clients look basically the same. The exception is in enterprise software, where forward deployed engineers customize software for each customer to make it a great experience for them.
>
> We think that coding agents have now gotten good enough to allow users to become their own forward deployed engineers and more radically customize the software they consume. I'm imagining users designing widely different interfaces for their use cases — perhaps my email client looks more like a task list, and a students' looks more like an events calendar. But these two interfaces likely share some underlying primitives and design decisions that a software team can build and ship.
>
> We think that in the future, software companies will ship these shared primitives with full intention that users will heavily modify the final interfaces. To enable this future, we will have to rethink the whole stack of software delivery. How will a developer make software that can be accessed by the user's coding agents? Do they have to deliver source code rather than packaged binaries? Can they only modify front-end visual elements, or are there ways for them to modify middleware on the fly to enable more interesting use-cases?
>
> If you're a radical thinker looking to define the future of software, we'd love to hear from you.

### 与本项目的对应关系

RFS 的核心命题 → Bonsai 的回答:

- **"software companies will ship these shared primitives"** → 冻结组件池(frozen component pool,`lib/rfw_pool/local_widgets.dart`):开发者交付的是设计好的 primitives,不是最终界面
- **"users become their own forward deployed engineers"** → 用户用自然语言 intent 让 agent 生成界面(rfw DSL),无需写代码
- **"How will a developer make software that can be accessed by the user's coding agents?"** → 交付物是 DSL 可组合的组件白名单 + 系统提示词(capability lock),agent 只输出结构、永不输出可执行代码;渲染始终在设备端

## Hackathon 的另外两个可选方向(参考)

### Company Brain

By Tom Blomfield — https://www.ycombinator.com/rfs#company-brain

公司知识散落在人脑、邮件、Slack、工单、数据库里。AI 自动化的瓶颈已不是模型而是领域知识。需要一个新原语 "company brain":把碎片化知识抽取、结构化、保持最新,变成 AI 可执行的 skills 文件——原始公司数据与可靠 AI 自动化之间缺失的那一层。

### Software for Agents

By Aaron Epstein — https://www.ycombinator.com/rfs#software-for-agents

互联网下一个万亿级用户是 AI agent。"Make Something Agents Want":agent 需要的不是表单、按钮、仪表盘,而是机器可读接口(API、MCP、CLI)和详尽文档,让 agent 无需人介入即可发现、注册、上手使用。每个主流软件品类都需要为 agent 重建。

## Summer 2026 完整主题列表(仅目录)

AI for Low-Pesticide Agriculture · AI-Native Discovery Engines · AI-Native Service Companies · AI Personalized Medicine · Company Brain · Counter-Swarm Defense · **Dynamic Software Interfaces** · Electronics in Space · Hardware Supply Chain · Industrial Capabilities in Space · Inference Chips for Agent Workflows · SaaS Challengers · Software for Agents · Startups That Want to Sell to Huge Companies · Supply Chain 2.0 for Semiconductors · The AI Operating System for Companies
