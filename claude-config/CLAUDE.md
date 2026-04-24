# Forge OS — Global Rules v5.0

## The Four Laws (Non-Negotiable)
1. PROVE NEVER CLAIM — Every claim must be verifiable. Run it. Show output.
2. NO SYNTHETIC DATA — Never fabricate test data. Use real or documented fixtures.
3. BACKEND FIRST ALWAYS — Data integrity before UI. Schema before code.
4. SEE WHAT YOU BUILD — Every feature must be observable via log, metric, or health endpoint.

## Model Routing (for Reference, CCR Handles)
- Architecture / decomposition → Opus 4.7
- Coding → Kimi K2.6
- Review → Opus 4.6
- Background → DeepSeek free

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
