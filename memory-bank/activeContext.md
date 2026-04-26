# Active Context

Single source of truth for "where are we right now?" Read at session start,
update before session end. Keep terse — this is a working-memory file, not a
log. Historical entries belong in `progress.md`.

## Project
nimish-os — Project Intelligence OS (Claude-only Max-plan dev workflow,
Notion-backed task/decision log, PRD-driven product delivery).

## Current Milestone
Phase A — per-machine setup & validation (`SETUP_AND_VALIDATE_v5.md`).
Now running in v5.1 Claude-only mode (CCR deferred).

## Last Completed Task
Switched nimish-os to Claude-only Max-plan mode and integrated the Karpathy
behavioral principles into global CLAUDE.md. CCR moved to deferred status
with rationale documented in `claude-config/ccr/README.md`. New
`claude-config/launch.sh` provides a sterile-env Claude Code launcher that
eliminates ANTHROPIC_* leakage from shell rc / settings.json / inherited
process env (the entire 401 / ECONNREFUSED class of failures we hit
during the cas-analyzer attempt).

## In Progress
- First real product run (`prds/cas-analyzer.md`) pending: paste the build
  prompt into a fresh `bash claude-config/launch.sh` session.

## Blockers
None.

## Next Action
1. Pull latest main on laptop.
2. `bash claude-config/launch.sh`
3. Paste the cas-analyzer build prompt; let the Daily Usage loop run
   through M-01 → milestone-boundary check-in.
