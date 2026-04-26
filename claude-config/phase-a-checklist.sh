#!/usr/bin/env bash
# Phase A Go/No-Go checklist (Claude-only Max-plan mode).
# Phase A is complete only when this prints "PHASE A COMPLETE".
# Sourced from SETUP_AND_VALIDATE_v5.md section A9.

set -a
# shellcheck disable=SC1090
source "$HOME/.nimish-os/.setup-inputs"
set +a

PASS=0
FAIL=0

check() {
  if eval "$2"; then
    echo "✓ $1"; PASS=$((PASS+1))
  else
    echo "✗ FAIL: $1"; FAIL=$((FAIL+1))
  fi
}

CLEAN_ENV="env -u ANTHROPIC_BASE_URL -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN"

echo "── Phase A Go/No-Go (Claude-only Max-plan mode) ──"

# Repo
check "nimish-os repo exists" \
  "gh repo view $GITHUB_USERNAME/$SETUP_REPO_NAME > /dev/null 2>&1"

# Config
check "Global CLAUDE.md exists" "[ -f $HOME/.claude/CLAUDE.md ]"
check "Max-plan credentials present" "[ -f $HOME/.claude/.credentials.json ]"
check "Launcher script exists and is executable" \
  "[ -x $HOME/nimish-os/claude-config/launch.sh ]"

# Models — all via Max-plan native auth (no CCR)
check "Opus 4.7 accessible via Max plan" \
  "echo 'Reply: OPUS47-OK' | $CLEAN_ENV claude --model claude-opus-4-7 --print 2>/dev/null | grep -q 'OPUS47-OK'"
check "Opus 4.6 accessible via Max plan" \
  "echo 'Reply: OPUS46-OK' | $CLEAN_ENV claude --model claude-opus-4-6 --print 2>/dev/null | grep -q 'OPUS46-OK'"
check "Sonnet 4.6 accessible via Max plan" \
  "echo 'Reply: SONNET-OK' | $CLEAN_ENV claude --model claude-sonnet-4-6 --print 2>/dev/null | grep -q 'SONNET-OK'"
check "Haiku 4.5 accessible via Max plan" \
  "echo 'Reply: HAIKU-OK' | $CLEAN_ENV claude --model claude-haiku-4-5-20251001 --print 2>/dev/null | grep -q 'HAIKU-OK'"

# Skills
check "Community skills installed (6)" \
  "[ \$(npx skills list 2>/dev/null | grep -E '(cso|qa-only|ship|canary|varlock|obsidian)' | wc -l) -ge 6 ]"
check "Karpathy skills plugin installed" \
  "npx skills list 2>/dev/null | grep -qi karpathy || ls $HOME/.claude/plugins/ 2>/dev/null | grep -qi karpathy"
check "financial-platform skill exists" \
  "[ -f $HOME/.claude/skills/financial-platform.md ]"
check "restaurant-intelligence skill exists" \
  "[ -f $HOME/.claude/skills/restaurant-intelligence.md ]"

# Notion
check "Projects DB accessible" \
  "curl -s https://api.notion.com/v1/databases/$PROJECTS_DB_ID -H 'Authorization: Bearer $NOTION_API_KEY' -H 'Notion-Version: 2022-06-28' | jq -e '.object == \"database\"' > /dev/null"
check "Milestones DB accessible" \
  "curl -s https://api.notion.com/v1/databases/$MILESTONES_DB_ID -H 'Authorization: Bearer $NOTION_API_KEY' -H 'Notion-Version: 2022-06-28' | jq -e '.object == \"database\"' > /dev/null"
check "Tasks DB accessible" \
  "curl -s https://api.notion.com/v1/databases/$TASKS_DB_ID -H 'Authorization: Bearer $NOTION_API_KEY' -H 'Notion-Version: 2022-06-28' | jq -e '.object == \"database\"' > /dev/null"

# Validation project
check "Validation repo exists" \
  "gh repo view $GITHUB_USERNAME/$TEST_PROJECT_NAME > /dev/null 2>&1"
check "Quality gate caught violations" \
  "gh run list --repo $GITHUB_USERNAME/$TEST_PROJECT_NAME --limit 20 --json conclusion --jq '.[] | select(.conclusion==\"failure\")' | head -1 | grep -q failure"
check "Quality gate passes after cleanup" \
  "gh run list --repo $GITHUB_USERNAME/$TEST_PROJECT_NAME --branch milestone/M-01 --limit 1 --json conclusion --jq '.[0].conclusion' | grep -q success"

echo ""
echo "Passed: $PASS  Failed: $FAIL"
if [ $FAIL -eq 0 ]; then
  echo "✅ PHASE A COMPLETE — READY FOR PRD EXECUTION"
else
  exit 1
fi
