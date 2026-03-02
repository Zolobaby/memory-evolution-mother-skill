#!/bin/bash
# Memory triad guard: L1(local docs) + L2(Memos API) + L3(JSONL distill/LanceDB)
# This script links the three layers and writes a single health/status artifact.

set -euo pipefail

STATUS_PATH="$HOME/.openclaw/00-SHARED/memory/memory_triad_status.json"
DISTILL_SCRIPT="$HOME/.openclaw/extensions/memory-lancedb-pro/scripts/jsonl_distill.py"
ALLOWED_AGENTS="main,atlas,nexus,ecom"
TS=$(date +%s)
ISO_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$(dirname "$STATUS_PATH")"

# L1: lightweight local anchors (existence only; no content read)
L1_MEMORY_EXISTS=false
L1_CAPS_EXISTS=false
[[ -f "$HOME/.openclaw/workspace/MEMORY.md" ]] && L1_MEMORY_EXISTS=true
[[ -f "$HOME/.openclaw/workspace/CAPABILITIES.md" ]] && L1_CAPS_EXISTS=true

# L2: memos connectivity readiness
L2_ENV_READY=false
L2_HTTP_OK=false
if [[ -n "${MEMOS_API_KEY:-}" && -n "${MEMOS_BASE_URL:-}" ]]; then
  L2_ENV_READY=true
  if curl -fsS --max-time 8 "$MEMOS_BASE_URL" >/dev/null 2>&1; then
    L2_HTTP_OK=true
  fi
fi

# L3: incremental distill run and optional commit
L3_ACTION="unknown"
L3_BATCH_FILE=""
L3_OK=false
L3_COMMIT_OK=false

if [[ -f "$DISTILL_SCRIPT" ]]; then
  RUN_JSON=$(OPENCLAW_JSONL_DISTILL_ALLOWED_AGENT_IDS="$ALLOWED_AGENTS" \
    python3 "$DISTILL_SCRIPT" run 2>/dev/null || echo '{"ok":false,"action":"error"}')

  L3_ACTION=$(echo "$RUN_JSON" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("action","unknown"))' 2>/dev/null || echo "unknown")
  L3_BATCH_FILE=$(echo "$RUN_JSON" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("batchFile") or (d.get("batchFiles") or [""])[0])' 2>/dev/null || echo "")

  if [[ "$L3_ACTION" == "noop" ]]; then
    L3_OK=true
    L3_COMMIT_OK=true
  elif [[ ("$L3_ACTION" == "created" || "$L3_ACTION" == "pending") && -n "$L3_BATCH_FILE" ]]; then
    L3_OK=true
    COMMIT_JSON=$(python3 "$DISTILL_SCRIPT" commit --batch-file "$L3_BATCH_FILE" 2>/dev/null || echo '{"ok":false}')
    COMMIT_OK=$(echo "$COMMIT_JSON" | python3 -c 'import sys,json;print(str(json.load(sys.stdin).get("ok",False)).lower())' 2>/dev/null || echo "false")
    [[ "$COMMIT_OK" == "true" ]] && L3_COMMIT_OK=true
  fi
fi

# Cross-layer verdict
TRIAD_OK=false
TRIAD_MODE="degraded"
if [[ "$L1_MEMORY_EXISTS" == "true" && "$L1_CAPS_EXISTS" == "true" && "$L3_OK" == "true" && "$L3_COMMIT_OK" == "true" ]]; then
  TRIAD_OK=true
  if [[ "$L2_ENV_READY" == "true" && "$L2_HTTP_OK" == "true" ]]; then
    TRIAD_MODE="full"
  else
    TRIAD_MODE="core-only"
  fi
fi

cat > "$STATUS_PATH" <<EOF
{
  "timestamp": $TS,
  "iso": "$ISO_TS",
  "triad_ok": $TRIAD_OK,
  "triad_mode": "$TRIAD_MODE",
  "l1": {
    "memory_md_exists": $L1_MEMORY_EXISTS,
    "capabilities_md_exists": $L1_CAPS_EXISTS
  },
  "l2": {
    "env_ready": $L2_ENV_READY,
    "http_ok": $L2_HTTP_OK
  },
  "l3": {
    "action": "$L3_ACTION",
    "batch_file": "$L3_BATCH_FILE",
    "run_ok": $L3_OK,
    "commit_ok": $L3_COMMIT_OK,
    "allowlist": "$ALLOWED_AGENTS"
  }
}
EOF

echo "memory_triad_guard: status written -> $STATUS_PATH"
cat "$STATUS_PATH"
