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

# Moonshot + OpenRouter are required — CCR routes coding/background through them.
: "${MOONSHOT_API_KEY:?MOONSHOT_API_KEY not set}"
: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY not set}"

# ANTHROPIC_API_KEY is optional: when SKIP_ANTHROPIC_API=yes (Max-plan native
# routing), the anthropic provider stays in the config as a structural
# placeholder but its api_key field is left as __ANTHROPIC_API_KEY__. Do not
# route `think` / `webSearch` through CCR in that mode; invoke Opus directly
# via the `claude` CLI (Max plan handles auth).
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
SKIP_ANTHROPIC_API="${SKIP_ANTHROPIC_API:-no}"

# Strip stray whitespace that paste artifacts sometimes introduce.
MOONSHOT_API_KEY="${MOONSHOT_API_KEY// /}"
OPENROUTER_API_KEY="${OPENROUTER_API_KEY// /}"
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY// /}"

CCR_API_KEY="ccr-$(openssl rand -hex 16)"

mkdir -p "$HOME/.claude-code-router"

SED_ARGS=(
  -e "s|__CCR_API_KEY__|$CCR_API_KEY|g"
  -e "s|__MOONSHOT_API_KEY__|$MOONSHOT_API_KEY|g"
  -e "s|__OPENROUTER_API_KEY__|$OPENROUTER_API_KEY|g"
)

MAX_PLAN_MODE=no
if [ -n "$ANTHROPIC_API_KEY" ] && [ "$SKIP_ANTHROPIC_API" != "yes" ]; then
  SED_ARGS+=( -e "s|__ANTHROPIC_API_KEY__|$ANTHROPIC_API_KEY|g" )
else
  MAX_PLAN_MODE=yes
  echo "Note: ANTHROPIC_API_KEY unset or SKIP_ANTHROPIC_API=yes — leaving" \
       "__ANTHROPIC_API_KEY__ placeholder in config. Invoke Opus outside CCR" \
       "(Max-plan native routing)."
fi

sed "${SED_ARGS[@]}" "$TEMPLATE" > "$OUT_REPO"

# In Max-plan mode CCR cannot authenticate to Anthropic, so any route
# pointed at an anthropic,* model 401s. Strip those routes from the
# rendered config so they fall back to `default`. Opus is still
# reachable by shelling out with `env -u ANTHROPIC_* claude --model ...`,
# which bypasses CCR entirely.
if [ "$MAX_PLAN_MODE" = "yes" ]; then
  tmp=$(mktemp)
  jq 'del(.Router.think, .Router.webSearch)' "$OUT_REPO" > "$tmp" \
    && mv "$tmp" "$OUT_REPO"
  echo "Max-plan mode: stripped .Router.think and .Router.webSearch."
fi

cp "$OUT_REPO" "$OUT_RUNTIME"
chmod 600 "$OUT_REPO" "$OUT_RUNTIME"

jq . "$OUT_RUNTIME" > /dev/null
echo "Wrote $OUT_RUNTIME (APIKEY prefix: ${CCR_API_KEY:0:8}...)"
