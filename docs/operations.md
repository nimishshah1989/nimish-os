# Operations

Daily usage patterns for the Project Intelligence OS after Phase A is complete.
See `../SETUP_AND_VALIDATE_v5.md` for the one-time setup procedure.

## Default mode: Claude-only via Max plan

All routing is through Anthropic on the Max-plan subscription. CCR
(multi-provider routing through Kimi/DeepSeek) is **deferred** —
keep `claude-config/ccr/` for the day we re-enable it, but it is not
used in the current workflow. See `claude-config/ccr/README.md`.

**Always launch Claude Code via the launcher**, never `claude` bare:

```bash
bash claude-config/launch.sh                # cwd = ~/nimish-os
bash claude-config/launch.sh ~/some/repo    # explicit cwd
```

The launcher kills any stale CCR process, scrubs ANTHROPIC_* overrides
out of `~/.claude/settings.json`, and execs Claude Code with `env -i`
so no shell-rc state can leak in. This eliminates the entire class of
401 / ECONNREFUSED errors caused by env pollution.

## Start a new project
1. Create a row in the Notion Projects DB.
2. Create the GitHub repo and copy
   `claude-config/github-workflows/quality-gate.yml` into
   `.github/workflows/`.
3. Write the PRD in `prds/<project>.md` in this repo.
4. Decompose: from the launched session, shell out with
   `claude --model claude-opus-4-7 < prds/<project>.md`.
5. Load the produced milestones and tasks into Notion.
6. Execute first task in the default session (Sonnet 4.6); reference the
   task ID from Notion.
7. Auto-merge to the milestone branch on gate pass. Main only moves at
   milestone approval.

## Model routing

| Use | Model | Invocation |
|---|---|---|
| Architecture / decomposition / planning | Opus 4.7 | `claude --model claude-opus-4-7` |
| Coding (default session) | Sonnet 4.6 | `claude` (no flag) |
| Code / milestone review | Opus 4.6 | `claude --model claude-opus-4-6` |
| Background scans / cheap tasks | Haiku 4.5 | `claude --model claude-haiku-4-5-20251001` |

## Routine commands
- `bash claude-config/launch.sh` — sterile-env Claude Code launch
- `bash claude-config/phase-a-checklist.sh` — re-run Go/No-Go (useful after
  a laptop reboot, to confirm everything still works)
- `claude login` — refresh Max-plan credentials if `phase-a-checklist.sh`
  reports the credentials file missing or any model check 401s

## One-time skills setup
Inside any Claude Code session, install the Karpathy behavioral-rules
plugin once per machine:

```
/plugin marketplace add forrestchang/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills
```

The principles themselves are also encoded in `claude-config/CLAUDE.md`
so every session reads them at start; the plugin adds skill-level
invocations on top.

## Files that must never be committed
- `~/.nimish-os/.setup-inputs` — user inputs, stored outside the repo
- `claude-config/ccr/config.json` — generated with real keys at setup time;
  `.gitignore` excludes it
- Anything under `.env` or matching `*.log`
