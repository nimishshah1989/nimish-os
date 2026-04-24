# Active Context

Single source of truth for "where are we right now?" Read at session start,
update before session end. Keep terse — this is a working-memory file, not a
log. Historical entries belong in `progress.md`.

## Project
nimish-os — Project Intelligence OS (CCR-routed Claude Code workflow,
Notion-backed task/decision log, PRD-driven product delivery).

## Current Milestone
Phase A — per-machine setup & validation (`SETUP_AND_VALIDATE_v5.md`).

## Last Completed Task
[CCR] fix: cap DeepSeek max_tokens and divert long context (PR #2, merged
`00ed312`). Background route swapped from `deepseek/deepseek-chat` (64k ctx)
to `deepseek/deepseek-chat-v3.1` (~164k ctx, paid); `longContextThreshold=45000`
added as safety net to Kimi (256k).

## In Progress
- Phase A validation run (pending on local machine):
  `bash claude-config/ccr/render-config.sh && ccr restart` → Phase A smoke
  tests (§A4.3) → `bash claude-config/phase-a-checklist.sh`.

## Blockers
None.

## Next Action
1. Render + restart CCR to pick up the merged DeepSeek fix.
2. Run Phase A smoke tests; expect `KIMI-OK`, `OPUS47-OK`, `OPUS46-OK`, `DS-OK`.
3. Green checklist → move to Phase B (SonarQube, Telegram, wiki, MCP).
