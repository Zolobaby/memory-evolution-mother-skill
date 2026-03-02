---
name: memory-evolution
description: Coordinate and evolve a three-layer memory stack (L1 local anchors, L2 Memos API, L3 JSONL distill/LanceDB). Use when optimizing memory flow, reducing repeated learning, chaining similar evolution events, adding new memory containers, or running cross-layer health checks and migration cutovers.
---

# Memory Evolution (Mother Skill)

Use one integrated architecture:

- Capability: reusable decision patterns and routing rules
- Tool: deterministic scripts for checks/logging/chaining
- Skill: trigger policy for when to use capability + tool

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

## Guardrails

- Prefer incremental processing, avoid full-history scans unless requested
- Keep memory entries atomic and reusable
- Skip routine chatter and long tool dumps
- Change one scheduling parameter at a time
