# Operations

Daily usage patterns for the Project Intelligence OS after Phase A is complete.
See `../SETUP_AND_VALIDATE_v5.md` for the one-time setup procedure.

## Start a new project
1. Create a row in the Notion Projects DB.
2. Create the GitHub repo and copy
   `claude-config/github-workflows/quality-gate.yml` into
   `.github/workflows/`.
3. Write the PRD in `prds/<project>.md` in this repo.
4. Decompose: `claude --model anthropic,claude-opus-4-7 < prds/<project>.md`.
5. Load the produced milestones and tasks into Notion.
6. Execute first task: `claude --model moonshot,kimi-k2.6` and reference the
   task ID from Notion.
7. Auto-merge to the milestone branch on gate pass. Main only moves at
   milestone approval.

## Model routing
CCR handles routing; these flags force a specific model when needed.

| Use | Command |
|-----|---------|
| Architect / decomposition | `claude --model anthropic,claude-opus-4-7` |
| Coder (default) | `claude --model moonshot,kimi-k2.6` |
| Reviewer | `claude --model anthropic,claude-opus-4-6` |
| Background scans | `claude --model openrouter,deepseek/deepseek-chat` |

## Routine commands
- `ccr status` — router health
- `ccr restart` — after a flaky model run
- `bash claude-config/phase-a-checklist.sh` — re-run Go/No-Go (useful after
  a laptop reboot, to confirm everything still works)
- `bash claude-config/ccr/render-config.sh` — rebuild CCR config from
  `~/.nimish-os/.setup-inputs` after rotating an API key

## Files that must never be committed
- `~/.nimish-os/.setup-inputs` — user inputs, stored outside the repo
- `claude-config/ccr/config.json` — generated with real keys at setup time;
  `.gitignore` excludes it
- Anything under `.env` or matching `*.log`
