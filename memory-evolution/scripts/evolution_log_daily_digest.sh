#!/bin/bash
# Build daily digest from Kuro evolution JSONL log.

set -euo pipefail

LOG_JSONL="$HOME/.openclaw/00-SHARED/memory/KURO_EVOLUTION_LOG.jsonl"
OUT_MD="$HOME/.openclaw/00-SHARED/memory/KURO_EVOLUTION_DAILY.md"
TODAY=$(date +"%Y-%m-%d")

mkdir -p "$(dirname "$OUT_MD")"

python3 - <<PY > "$OUT_MD"
import json
from collections import Counter
from pathlib import Path
from datetime import datetime, timezone, timedelta

log=Path("$LOG_JSONL")
today="$TODAY"
cn_tz=timezone(timedelta(hours=8))
rows=[]
if log.exists():
    for line in log.read_text().splitlines():
        if not line.strip():
            continue
        try:
            obj=json.loads(line)
        except Exception:
            continue
        ts=obj.get("ts","")
        try:
            dt=datetime.fromisoformat(ts.replace('Z','+00:00')).astimezone(cn_tz)
            if dt.strftime('%Y-%m-%d')==today:
                rows.append(obj)
        except Exception:
            continue

tracks=Counter(r.get("track","unknown") for r in rows)
print(f"# Kuro Evolution Daily Digest - {today}\n")
print(f"- entries: {len(rows)}")
for k,v in tracks.most_common():
    print(f"- {k}: {v}")
print("\n## highlights")
for r in rows[-5:]:
    print(f"- [{r.get('track','unknown')}] {r.get('title','')} -> {r.get('action','')}")
PY

echo "evolution_log_daily_digest: wrote -> $OUT_MD"
