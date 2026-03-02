#!/bin/bash
# Produce high-value asset keep report.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
REG="$ROOT_DIR/memory-evolution/references/high_value_asset_registry.json"
OUT="$HOME/.openclaw/00-SHARED/memory/HIGH_VALUE_ASSET_REPORT.md"

mkdir -p "$(dirname "$OUT")"

python3 - <<PY > "$OUT"
import json
from pathlib import Path
reg=Path("$REG")
obj=json.loads(reg.read_text())
root=Path("$ROOT_DIR")

print("# High Value Asset Report\n")
print(f"generated_at: {obj.get('updated_at','')}\n")

for level in ["P0","P1","P2"]:
    c=obj["classes"][level]
    print(f"## {level} - {c.get('meaning','')}\n")
    for p in c.get("assets",[]):
      ok=(root/p).exists()
      print(f"- [{'x' if ok else ' '}] {p}")
    print("")
PY

echo "Done: $OUT"
