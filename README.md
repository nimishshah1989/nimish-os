# nimish-os

Nimish Shah's Project Intelligence OS — setup artifacts, CLAUDE.md rules,
skills, CCR configuration, Notion schemas, and product PRDs.

## Structure
- `claude-config/` — Global CLAUDE.md, skills, CCR config, workflow templates
- `notion-setup/` — Notion DB creation scripts and schema
- `prds/` — Product requirements documents
- `validation/` — Validation project reference
- `docs/` — Architecture notes, decisions, operational docs

## Operation
See `docs/operations.md` for daily usage patterns. Default mode is
**Claude-only via Max plan** — launch Claude Code through
`claude-config/launch.sh` so no stale CCR env can leak in.

## Setup
The authoritative setup procedure is `SETUP_AND_VALIDATE_v5.md` at the repo
root. Phase A is run once per machine and expects the seven credentials
listed in its Phase 0 input block. Phase B (SonarQube, Telegram, wiki,
MCP servers) is deferred until deployment time. CCR (multi-provider
routing) is also deferred — see `claude-config/ccr/README.md`.
