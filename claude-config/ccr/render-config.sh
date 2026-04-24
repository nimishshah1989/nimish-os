#!/usr/bin/env bash
# Materialize config.json from config.template.json using ~/.nimish-os/.setup-inputs.
# Output is ~/.claude-code-router/config.json. Real keys never touch git (the
# generated config.json is .gitignored).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE="$REPO_DIR/claude-config/ccr/config.template.json"
OUT_REPO="$REPO_DIR/claude-config/ccr/config.json"
OUT_RUNTIME="$HOME/.claude-code-router/config.json"

if [ ! -f "$HOME/.nimish-os/.setup-inputs" ]; then
  echo "Missing ~/.nimish-os/.setup-inputs — run Phase 0 first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$HOME/.nimish-os/.setup-inputs"
set +a

: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY not set}"
: "${MOONSHOT_API_KEY:?MOONSHOT_API_KEY not set}"
: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY not set}"

CCR_API_KEY="ccr-$(openssl rand -hex 16)"

mkdir -p "$HOME/.claude-code-router"

sed \
  -e "s|__CCR_API_KEY__|$CCR_API_KEY|g" \
  -e "s|__ANTHROPIC_API_KEY__|$ANTHROPIC_API_KEY|g" \
  -e "s|__MOONSHOT_API_KEY__|$MOONSHOT_API_KEY|g" \
  -e "s|__OPENROUTER_API_KEY__|$OPENROUTER_API_KEY|g" \
  "$TEMPLATE" > "$OUT_REPO"

cp "$OUT_REPO" "$OUT_RUNTIME"
chmod 600 "$OUT_REPO" "$OUT_RUNTIME"

jq . "$OUT_RUNTIME" > /dev/null
echo "Wrote $OUT_RUNTIME (APIKEY prefix: ${CCR_API_KEY:0:8}...)"
