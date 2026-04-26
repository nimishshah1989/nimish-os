# Forge OS — Global Rules v5.1

## The Four Laws (Non-Negotiable)
1. PROVE NEVER CLAIM — Every claim must be verifiable. Run it. Show output.
2. NO SYNTHETIC DATA — Never fabricate test data. Use real or documented fixtures.
3. BACKEND FIRST ALWAYS — Data integrity before UI. Schema before code.
4. SEE WHAT YOU BUILD — Every feature must be observable via log, metric, or health endpoint.

## Behavioral Rules (Karpathy Principles)

Behavioral guidelines for HOW to think and act while coding, sourced
verbatim from [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills).
The Four Laws above govern WHAT to build and to what standard; these
govern execution. **Where any rule below conflicts with the Four Laws,
the Four Laws win.**

**Tradeoff:** these guidelines bias toward caution over speed. For trivial
tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Model Routing (Claude-only Max-plan mode)

All routing is on Claude via Max-plan native auth. CCR (multi-provider
routing through Kimi/DeepSeek) is **deferred** — see
`claude-config/ccr/README.md` for the legacy setup. To launch a clean
session, always use:

```bash
bash claude-config/launch.sh
```

| Use | Model | Invocation |
|---|---|---|
| Architecture / decomposition / planning | Opus 4.7 | `claude --model claude-opus-4-7` |
| Coding (default session) | Sonnet 4.6 | `claude` (no flag) |
| Code / milestone review | Opus 4.6 | `claude --model claude-opus-4-6` |
| Background scans / cheap tasks | Haiku 4.5 | `claude --model claude-haiku-4-5-20251001` |

## Session Start Protocol
1. Read memory-bank/activeContext.md if it exists
2. Read memory-bank/progress.md if it exists
3. State: current project, milestone, last completed task
4. Ask: "Continue or new direction?"

## Commit Protocol
- Run tests before every commit
- Commit format: [TASK-ID] verb: description (max 72 chars)
- After passing tests, auto-merge to milestone branch
- Update Notion task to auto-merged with git hash
- Main branch only touched by milestone approval

## Financial Precision
- All monetary values: Python Decimal, never float
- Round to 2 decimal places for display
- Every financial calc has a test against manually-verified expected value
- Reconciliation totals must match within Decimal('0.01')
- Check denominator != 0 before dividing

## What I Will Never Do
- Fabricate test data
- Skip error handling to ship faster
- Make a breaking DB change without a migration
- Store credentials in code
- Write a function > 50 lines without flagging for review

## Quality Gates
- Coverage >= 70% overall, 100% on financial calculation modules
- Zero blocker or critical violations
- All endpoints have /health route
- All external calls wrapped in try/except with specific exception types
