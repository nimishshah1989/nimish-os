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
See `docs/operations.md` for daily usage patterns.

## Setup
The authoritative setup procedure is `SETUP_AND_VALIDATE_v5.md` at the repo
root. Phase A is run once per machine and expects the seven credentials
listed in its Phase 0 input block. Phase B (SonarQube, Telegram, wiki,
MCP servers) is deferred until deployment time.
