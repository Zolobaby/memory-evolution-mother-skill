---
name: memory-evolution
description: Coordinate and evolve a three-layer memory stack (L1 local anchors, L2 Memos API, L3 JSONL distill/LanceDB). 用于优化记忆流、减少重复学习、串联相近进化事件、接入新记忆容器，并执行跨层健康检查与迁移切换。
---

# Memory Evolution (Mother Skill)

A compact evolution kernel for agents: **capture → chain → verify → upgrade**.

## 中文简介

这是一个“进化母 Skill”，把分散的经验变成可复用能力：

- 能力层（Capability）：沉淀稳定策略与路由规则
- 工具层（Tool）：用脚本保证可重复、可审计执行
- 技能层（Skill）：定义触发条件与编排策略

目标不是做一次任务，而是减少重复学习、提升进化效率。

## Core workflow

1. Run triad guard:
   - `scripts/memory_triad_guard.sh`
2. Read status artifact:
   - `~/.openclaw/00-SHARED/memory/memory_triad_status.json`
3. Classify mode:
   - `full` / `core-only` / `degraded`
4. Apply one smallest safe fix
5. Re-run guard and verify mode change

## Anti-repeat evolution loop

1. Append structured evolution event:
   - `scripts/evolution_log_append.sh --source ... --track ... --title ... --insight ... --action ...`
2. Build chain index:
   - `scripts/evolution_chain_build.sh`
3. Read anti-repeat candidates:
   - `~/.openclaw/00-SHARED/memory/KURO_EVOLUTION_CHAINS.md`
4. Reuse nearest baseline before starting new exploration

## Installer capability capture

Shared skill can reuse installer capability, but only within installer-permitted environment.

Run installer probe first:
- `scripts/capability_probe.sh`

Output profile:
- `~/.openclaw/00-SHARED/memory/installer_capability_profile.json`

Use profile for feature gating:
- If capability exists + authorized -> enable route
- If missing/unauthed -> fallback route, do not force execution

## Routing rules

- Write path default: L1 -> L2 -> L3
- Read path default: L3 -> L2 -> L1
- If L2 is down, keep `core-only` mode (no blocking)

## Container acceptance contract

For any new memory backend, require:

- ops: `store`, `recall`, `delete`, `health`, `export`
- max item length: 500 chars
- fields: `category`, `importance`, `text`, `timestamp`
- migration: 7-day shadow write -> pass-rate >=99% -> cutover

Reference:
- `references/memory_container_registry.yaml`
- `references/evolution_log_sources.yaml`

## Effect receipts (verification layer)

Record measurable outcomes after each shared capability run:

- Append receipt: `scripts/effect_receipt_append.sh`
- Build scoreboard: `scripts/effect_receipt_scoreboard.sh`
- Schema: `references/effect_receipt_schema.json`

Minimum metrics:
- time_saved_min
- repeat_avoided
- outcome (success/partial/fail)

Use receipts to prioritize high-impact capabilities and avoid repeating low-yield paths.

## High-value asset retention

Use registry-driven retention to preserve long-term value:

- Registry: `references/high_value_asset_registry.json`
- Curate report: `scripts/high_value_curate.sh`

Policy:
- P0 keep always
- P1 keep by default
- P2 archive if low usage

## Guardrails

- Prefer incremental processing, avoid full-history scans unless requested
- Keep memory entries atomic and reusable
- Skip routine chatter and long tool dumps
- Change one scheduling parameter at a time
