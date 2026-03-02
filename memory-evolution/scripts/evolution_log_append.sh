#!/bin/bash
# Append one structured evolution log entry for Kuro with dedupe + chaining.
# Usage:
# evolution_log_append.sh --source evomap --track evomap-growth --title "..." --insight "..." --action "..." [--confidence 0.85]

set -euo pipefail

LOG_MD="$HOME/.openclaw/00-SHARED/memory/KURO_EVOLUTION_LOG.md"
LOG_JSONL="$HOME/.openclaw/00-SHARED/memory/KURO_EVOLUTION_LOG.jsonl"

SOURCE=""
TRACK=""
TITLE=""
INSIGHT=""
ACTION=""
CONFIDENCE="0.80"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --track) TRACK="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --insight) INSIGHT="$2"; shift 2 ;;
    --action) ACTION="$2"; shift 2 ;;
    --confidence) CONFIDENCE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$SOURCE" || -z "$TRACK" || -z "$TITLE" || -z "$INSIGHT" || -z "$ACTION" ]]; then
  echo "Missing required args. Need: --source --track --title --insight --action"
  exit 1
fi

mkdir -p "$(dirname "$LOG_MD")"

if [[ ! -f "$LOG_MD" ]]; then
  cat > "$LOG_MD" << 'EOF'
# Kuro Evolution Log

> Purpose: keep a durable evolution journal as an "organ" for capability growth.
> Sources: EvoMap growth / AI usage patterns / Moltbook reflection / system decisions.

EOF
fi

TS_LOCAL=$(date +"%Y-%m-%d %H:%M:%S %z")
TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

ANALYSIS=$(python3 - <<PY
import hashlib, json, os
from pathlib import Path

log_path = Path("$LOG_JSONL")
track = "$TRACK"
title = "$TITLE"
insight = "$INSIGHT"
action = "$ACTION"

def norm(s: str) -> str:
    return " ".join(s.strip().lower().split())

fingerprint_src = f"{norm(track)}|{norm(title)}|{norm(insight)}"
fingerprint = hashlib.sha256(fingerprint_src.encode("utf-8")).hexdigest()[:16]

duplicate = False
related_prev = ""

if log_path.exists():
    rows = []
    for line in log_path.read_text().splitlines():
        if not line.strip():
            continue
        try:
            rows.append(json.loads(line))
        except Exception:
            continue

    # duplicate rule: same fingerprint already exists
    for r in rows:
        if r.get("fingerprint") == fingerprint:
            duplicate = True
            break

    # chaining rule: most recent same-track item (different fingerprint)
    for r in reversed(rows):
        if r.get("track") == track and r.get("fingerprint") != fingerprint:
            related_prev = r.get("title", "")
            break

print(json.dumps({
    "fingerprint": fingerprint,
    "duplicate": duplicate,
    "related_prev": related_prev
}, ensure_ascii=False))
PY
)

FINGERPRINT=$(echo "$ANALYSIS" | python3 -c 'import sys,json;print(json.load(sys.stdin)["fingerprint"])')
DUPLICATE=$(echo "$ANALYSIS" | python3 -c 'import sys,json;print(str(json.load(sys.stdin)["duplicate"]).lower())')
RELATED_PREV=$(echo "$ANALYSIS" | python3 -c 'import sys,json;print(json.load(sys.stdin)["related_prev"])')

if [[ "$DUPLICATE" == "true" ]]; then
  echo "evolution_log_append: duplicate fingerprint=$FINGERPRINT, skip append"
  exit 0
fi

cat >> "$LOG_MD" <<EOF
## [$TS_LOCAL] $TITLE
- source: $SOURCE
- track: $TRACK
- related_prev: ${RELATED_PREV:-none}
- fingerprint: $FINGERPRINT
- insight: $INSIGHT
- action: $ACTION
- confidence: $CONFIDENCE

EOF

python3 - <<PY >> "$LOG_JSONL"
import json
print(json.dumps({
  "ts": "$TS_ISO",
  "source": "$SOURCE",
  "track": "$TRACK",
  "title": "$TITLE",
  "related_prev": "$RELATED_PREV",
  "fingerprint": "$FINGERPRINT",
  "insight": "$INSIGHT",
  "action": "$ACTION",
  "confidence": "$CONFIDENCE"
}, ensure_ascii=False))
PY

echo "evolution_log_append: appended -> $LOG_MD (fingerprint=$FINGERPRINT)"
