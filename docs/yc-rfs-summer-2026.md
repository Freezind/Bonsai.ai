# YC Requests for Startups — Summer 2026

> Source: https://www.ycombinator.com/rfs (captured 2026-07-04)
> This project's chosen topic is **Dynamic Software Interfaces**, quoted in full below; the other two hackathon-eligible directions are appended at the end.

## Dynamic Software Interfaces (this project's topic)

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

### How this project maps to it

The RFS's core theses → Bonsai's answers:

- **"software companies will ship these shared primitives"** → frozen component pool (`lib/rfw_pool/local_widgets.dart`): what the developer ships is a set of designed primitives, not the final interface
- **"users become their own forward deployed engineers"** → users express intents in natural language and let the agent generate the interface (rfw DSL), no code required
- **"How will a developer make software that can be accessed by the user's coding agents?"** → the deliverable is a DSL-composable component whitelist + system prompt (capability lock); the agent only emits structure, never executable code; rendering always happens on-device

## The other two hackathon-eligible directions (for reference)

### Company Brain

By Tom Blomfield — https://www.ycombinator.com/rfs#company-brain

Company knowledge is scattered across people's heads, email, Slack, tickets, and databases. The bottleneck for AI automation is no longer the model but domain knowledge. A new primitive is needed, the "company brain": extract fragmented knowledge, structure it, keep it up to date, and turn it into AI-executable skills files -- the missing layer between raw company data and reliable AI automation.

### Software for Agents

By Aaron Epstein — https://www.ycombinator.com/rfs#software-for-agents

The internet's next trillion-scale users are AI agents. "Make Something Agents Want": what agents need is not forms, buttons, or dashboards, but machine-readable interfaces (API, MCP, CLI) and thorough documentation, so agents can discover, sign up, and get going without human intervention. Every major software category needs to be rebuilt for agents.

## Complete Summer 2026 topic list (index only)

AI for Low-Pesticide Agriculture · AI-Native Discovery Engines · AI-Native Service Companies · AI Personalized Medicine · Company Brain · Counter-Swarm Defense · **Dynamic Software Interfaces** · Electronics in Space · Hardware Supply Chain · Industrial Capabilities in Space · Inference Chips for Agent Workflows · SaaS Challengers · Software for Agents · Startups That Want to Sell to Huge Companies · Supply Chain 2.0 for Semiconductors · The AI Operating System for Companies
