#!/bin/bash
# Build scoreboard from effect receipts.

set -euo pipefail
JSONL="$HOME/.openclaw/00-SHARED/memory/KURO_EFFECT_RECEIPTS.jsonl"
OUT="$HOME/.openclaw/00-SHARED/memory/KURO_EFFECT_SCOREBOARD.md"

python3 - <<PY > "$OUT"
import json
from collections import defaultdict
from pathlib import Path

p=Path("$JSONL")
rows=[]
if p.exists():
    for line in p.read_text().splitlines():
        if not line.strip():
            continue
        try:
            rows.append(json.loads(line))
        except:
            pass

agg=defaultdict(lambda:{"n":0,"success":0,"time":0.0,"repeat":0})
for r in rows:
    k=r.get("capability_id","unknown")
    a=agg[k]
    a["n"]+=1
    if r.get("outcome")=="success":
        a["success"]+=1
    m=r.get("metrics",{})
    a["time"]+=float(m.get("time_saved_min",0) or 0)
    a["repeat"]+=int(m.get("repeat_avoided",0) or 0)

print("# Kuro Effect Scoreboard\n")
print(f"- receipts: {len(rows)}\n")
print("| capability | runs | success_rate | total_time_saved_min | total_repeat_avoided |")
print("|---|---:|---:|---:|---:|")
for k,v in sorted(agg.items(), key=lambda kv: kv[1]["time"], reverse=True):
    sr=(v["success"]/v["n"]*100) if v["n"] else 0
    print(f"| {k} | {v['n']} | {sr:.1f}% | {v['time']:.1f} | {v['repeat']} |")
PY

echo "effect_receipt_scoreboard: wrote $OUT"
