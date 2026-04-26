#!/usr/bin/env bash
# Launch Claude Code in a sterile environment for Claude-only Max-plan mode.
#
# Why this exists: when CCR is (or has been) installed, ANTHROPIC_BASE_URL,
# ANTHROPIC_API_KEY, and ANTHROPIC_AUTH_TOKEN can leak into a Claude Code
# session via three independent mechanisms — shell rc files, ~/.claude/
# settings.json, and inherited process env. Any one of them silently routes
# requests through CCR (or worse, a dead CCR), producing 401 / ECONNREFUSED.
#
# This launcher kills CCR, scrubs settings.json, then execs Claude Code with
# `env -i` (no inherited vars) and `bash --noprofile --norc` (no shell rc
# sourcing). The session talks directly to api.anthropic.com using Max-plan
# credentials at ~/.claude/.credentials.json.
#
# Usage:
#   bash claude-config/launch.sh                  # cwd defaults to ~/nimish-os
#   bash claude-config/launch.sh ~/some/repo      # explicit cwd

set -euo pipefail

WORKDIR="${1:-$HOME/nimish-os}"

if [ ! -d "$WORKDIR" ]; then
  echo "Working directory not found: $WORKDIR" >&2
  exit 1
fi

if [ ! -f "$HOME/.claude/.credentials.json" ]; then
  echo "Max-plan credentials not found at ~/.claude/.credentials.json." >&2
  echo "Run: claude login" >&2
  exit 1
fi

pkill -9 -f 'claude-code-router' 2>/dev/null || true
pkill -9 -f '^ccr' 2>/dev/null || true

for f in "$HOME/.claude/settings.json" "$HOME/.claude/settings.local.json"; do
  if [ -f "$f" ] && grep -q ANTHROPIC_BASE_URL "$f" 2>/dev/null; then
    cp "$f" "$f.bak.$(date +%s)"
    tmp="$(mktemp)"
    jq 'if .env then .env |= del(.ANTHROPIC_BASE_URL, .ANTHROPIC_API_KEY, .ANTHROPIC_AUTH_TOKEN) else . end' \
      "$f" > "$tmp" && mv "$tmp" "$f"
    echo "Scrubbed ANTHROPIC_* env overrides from $f (backup saved)."
  fi
done

exec env -i \
  HOME="$HOME" \
  PATH="$PATH" \
  TERM="${TERM:-xterm-256color}" \
  USER="${USER:-$(whoami)}" \
  SHELL="${SHELL:-/bin/bash}" \
  bash --noprofile --norc -c "cd '$WORKDIR' && claude"
