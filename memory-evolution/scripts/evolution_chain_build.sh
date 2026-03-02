#!/bin/bash
# Build chain index for similar/related evolution entries.

set -euo pipefail

LOG_JSONL="$HOME/.openclaw/00-SHARED/memory/KURO_EVOLUTION_LOG.jsonl"
OUT_MD="$HOME/.openclaw/00-SHARED/memory/KURO_EVOLUTION_CHAINS.md"

mkdir -p "$(dirname "$OUT_MD")"

python3 - <<PY > "$OUT_MD"
import json
from collections import defaultdict, Counter
from pathlib import Path

log = Path("$LOG_JSONL")
rows = []
if log.exists():
    for line in log.read_text().splitlines():
        if not line.strip():
            continue
        try:
            rows.append(json.loads(line))
        except Exception:
            continue

rows.sort(key=lambda r: r.get("ts", ""))

by_track = defaultdict(list)
fp_count = Counter()
for r in rows:
    by_track[r.get("track", "unknown")].append(r)
    fp = r.get("fingerprint")
    if fp:
        fp_count[fp] += 1

print("# Kuro Evolution Chains\n")
print(f"- total_entries: {len(rows)}")
print(f"- tracks: {len(by_track)}")
print(f"- repeated_patterns: {sum(1 for _,c in fp_count.items() if c>1)}\n")

print("## track chains")
for track, items in sorted(by_track.items(), key=lambda kv: len(kv[1]), reverse=True):
    print(f"\n### {track} ({len(items)})")
    for i in items[-8:]:
        title = i.get("title", "")
        rel = i.get("related_prev") or "none"
        fp = i.get("fingerprint", "")
        print(f"- {i.get('ts','')} | {title} | related_prev={rel} | fp={fp}")

print("\n## anti-repeat candidates")
for fp, cnt in fp_count.items():
    if cnt > 1:
        sample = next((r for r in rows if r.get("fingerprint") == fp), None)
        if sample:
            print(f"- fp={fp} repeated={cnt} track={sample.get('track','')} title={sample.get('title','')}")
PY

echo "evolution_chain_build: wrote -> $OUT_MD"
