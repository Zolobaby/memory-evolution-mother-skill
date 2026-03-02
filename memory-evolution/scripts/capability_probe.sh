#!/bin/bash
# Probe installer-side capability profile (non-secret).
set -euo pipefail
OUT="${1:-$HOME/.openclaw/00-SHARED/memory/installer_capability_profile.json}"
mkdir -p "$(dirname "$OUT")"

has_bin(){ command -v "$1" >/dev/null 2>&1 && echo true || echo false; }

GH_AUTH=false
if command -v gh >/dev/null 2>&1; then
  gh auth status -h github.com >/dev/null 2>&1 && GH_AUTH=true || GH_AUTH=false
fi

OPENCLAW_OK=false
if command -v openclaw >/dev/null 2>&1; then
  openclaw gateway status >/dev/null 2>&1 && OPENCLAW_OK=true || OPENCLAW_OK=false
fi

cat > "$OUT" <<JSON
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "host": "$(hostname)",
  "capabilities": {
    "openclaw": {"installed": $(has_bin openclaw), "healthy": $OPENCLAW_OK},
    "python3": {"installed": $(has_bin python3)},
    "gh": {"installed": $(has_bin gh), "authed": $GH_AUTH},
    "obsidian_cli": {"installed": $(has_bin obsidian-cli)},
    "remindctl": {"installed": $(has_bin remindctl)}
  },
  "note": "No secrets included. This profile is for routing and feature gating only."
}
JSON

echo "capability_probe: wrote $OUT"
cat "$OUT"
