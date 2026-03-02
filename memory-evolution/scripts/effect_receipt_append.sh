#!/bin/bash
# Append one effect receipt (JSONL + Markdown) for capability verification.
# Example:
# effect_receipt_append.sh --capability memory-evolution/anti-repeat-chain --version 0.1.2 --installer node_xxx --scenario "evomap learning" --outcome success --time-saved 18 --repeat-avoided 2 --error-reduction 0.4 --quality-delta 0.2 --notes "less duplicate exploration"

set -euo pipefail

JSONL="$HOME/.openclaw/00-SHARED/memory/KURO_EFFECT_RECEIPTS.jsonl"
MD="$HOME/.openclaw/00-SHARED/memory/KURO_EFFECT_RECEIPTS.md"

CAPABILITY=""
VERSION=""
INSTALLER=""
SCENARIO=""
OUTCOME=""
TIME_SAVED="0"
REPEAT_AVOIDED="0"
ERROR_REDUCTION="0"
QUALITY_DELTA="0"
NOTES=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --capability) CAPABILITY="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --installer) INSTALLER="$2"; shift 2 ;;
    --scenario) SCENARIO="$2"; shift 2 ;;
    --outcome) OUTCOME="$2"; shift 2 ;;
    --time-saved) TIME_SAVED="$2"; shift 2 ;;
    --repeat-avoided) REPEAT_AVOIDED="$2"; shift 2 ;;
    --error-reduction) ERROR_REDUCTION="$2"; shift 2 ;;
    --quality-delta) QUALITY_DELTA="$2"; shift 2 ;;
    --notes) NOTES="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$CAPABILITY" || -z "$VERSION" || -z "$INSTALLER" || -z "$SCENARIO" || -z "$OUTCOME" ]]; then
  echo "Missing required args"; exit 1
fi

mkdir -p "$(dirname "$JSONL")"

if [[ ! -f "$MD" ]]; then
  cat > "$MD" << 'DOC'
# Kuro Effect Receipts

> Verifiable outcomes for shared evolution capabilities.
DOC
fi

TS_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TS_LOCAL=$(date +"%Y-%m-%d %H:%M:%S %z")

python3 - <<PY >> "$JSONL"
import json
print(json.dumps({
  "ts": "$TS_ISO",
  "capability_id": "$CAPABILITY",
  "version": "$VERSION",
  "installer": "$INSTALLER",
  "scenario": "$SCENARIO",
  "outcome": "$OUTCOME",
  "metrics": {
    "time_saved_min": float("$TIME_SAVED"),
    "repeat_avoided": int(float("$REPEAT_AVOIDED")),
    "error_reduction": float("$ERROR_REDUCTION"),
    "quality_delta": float("$QUALITY_DELTA")
  },
  "notes": "$NOTES",
  "privacy": {"contains_secret": False, "share_level": "team"}
}, ensure_ascii=False))
PY

cat >> "$MD" <<DOC

## [$TS_LOCAL] $CAPABILITY@$VERSION
- installer: $INSTALLER
- scenario: $SCENARIO
- outcome: $OUTCOME
- time_saved_min: $TIME_SAVED
- repeat_avoided: $REPEAT_AVOIDED
- error_reduction: $ERROR_REDUCTION
- quality_delta: $QUALITY_DELTA
- notes: $NOTES
DOC

echo "effect_receipt_append: appended"
