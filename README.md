# 🧬 Memory Evolution Mother Skill

A reusable **evolution operating system** for AI agents.
It turns scattered learning into a structured loop: **capture → chain → verify → upgrade**.

---

## 中文介绍（精简版）

这是一个给 AI Agent 用的“**进化母 Skill**”。
它不是只做一次任务，而是把每次经验沉淀成可复用能力，并持续优化：

- 进化日志：记录 EvoMap 成长、AI 用法、Moltbook 反思
- 相近串联：把相似进化事件自动串成链路
- 防重复学习：通过 fingerprint 自动去重
- 效果回执：用数据验证能力是否真有价值
- 容器接纳：支持未来记忆后端平滑迁移

一句话：**把“会做事”升级成“会持续进化”。**

---

## What this repo provides

- `memory-evolution/SKILL.md`  
  The mother skill spec and routing policy

- `memory-evolution/scripts/`  
  Deterministic operational scripts
  - triad health guard
  - installer capability probe
  - evolution log append + daily digest
  - anti-repeat chain builder
  - effect receipt append + scoreboard

- `memory-evolution/references/`  
  Contracts and schemas
  - memory container registry
  - evolution source definitions
  - effect receipt schema

---

## Core architecture

- **L1** local anchors (fast, durable context)
- **L2** Memos/API semantic layer (optional, feature-gated)
- **L3** JSONL distill/LanceDB (incremental long-term memory)

Write path: `L1 -> L2 -> L3`  
Read path: `L3 -> L2 -> L1`

If L2 is unavailable, the system stays in `core-only` mode and keeps running.

---

## Why this matters

Most agents can execute.
Few can **evolve without repeating themselves**.

This mother skill adds:

1. **Continuity**: every meaningful evolution event becomes reusable context
2. **Anti-repeat**: similar events are chained and deduplicated
3. **Verification**: capabilities are ranked by measurable effect receipts
4. **Portability**: backend/container can be swapped with contract-based migration

---

## Security stance

- No hardcoded secrets in the repo
- Capability probe is local-first and auditable
- Feature-gating only, no privilege escalation
- Contract + schema based evolution governance

---

## License

MIT (recommended for sharing)

---

## Public Chinese Brief

- 中文对外传播版：`README_CN_PUBLIC.md`
