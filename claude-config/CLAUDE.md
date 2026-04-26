# Forge OS — Global Rules v5.2

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

## Session Boundary Protocol

A single Claude Code session must not run forever. Long-lived sessions
accumulate irrelevant context, get expensive, make failures harder to
isolate, and erode the Karpathy "surgical changes" discipline. **Rotate
the session at the FIRST of these triggers — don't wait for milestone
boundary alone:**

1. **Milestone boundary** — at every milestone-end check-in.
2. **Five completed tasks** since the last rotation, even mid-milestone.
3. **Context heaviness** — when you've read >25 files, run >50 Bash
   commands, or otherwise judge the working context to be >60% full.
4. **Mode shift** — switching from architecture/planning to coding,
   or from coding to debugging/review. Each mode wants a clean slate.
5. **Three-strike failure** — after three consecutive failed attempts
   at the same goal (test won't pass, build broken, same error
   recurring). The accumulated wrong-direction context is hurting you.

**Rotation procedure:**
1. Update `memory-bank/activeContext.md` with current state in ≤15
   lines: project, milestone, last completed task, in-progress,
   blockers, next concrete action. Be terse — the next session reads
   this cold.
2. Append a one-line entry to `memory-bank/progress.md` if a milestone
   completed.
3. Tell the user: *"Session-rotate point. Run `bash claude-config/launch.sh`
   in a new terminal to continue. Next session resumes at: <next action>."*
4. Stop. Do not continue in this session.

The new session reads `memory-bank/` per the Session Start Protocol
and picks up exactly where the rotation left off.

## Design Protocol (for any product with a UI)

If a PRD has any client-facing UI — web, mobile, internal dashboard,
admin panel — the visual design is decided in **claude.ai Artifacts**
*before* the Claude Code build of that UI starts. Backend-only
products (API services, batch jobs, infra) skip this protocol.

**Sequence:**
1. After Opus 4.7 decomposes the PRD, before any frontend code is
   written, the user opens claude.ai in a browser and prompts Claude
   to render the UI as an Artifact (single-page React + Tailwind, mock
   JSON data, live preview pane).
2. User iterates visually until the design is approved. Artifact is
   saved (publish to a URL or copy the source code).
3. The PRD must contain an explicit `M-XX FRONTEND` milestone whose
   Definition of Done references the saved Artifact: *"implements the
   design at <Artifact URL or source path> exactly."* Tasks under
   this milestone reference Artifact sections.
4. The Claude Code agent in the M-XX session ports the Artifact into
   the project's actual stack. Layout, copy, and interaction behavior
   are preserved verbatim; the agent adapts only what the chosen stack
   forces (e.g. Vue instead of React, Chakra instead of Tailwind).
   When the Artifact is ambiguous on any point, the agent asks — it
   does not invent UI choices.

**Why:** LLM agents writing UI from a text spec produce generic,
ugly-by-default interfaces and waste cycles on visual decisions that
should be human-made. Artifacts give a fast visual loop with a human
in it. Once the design is locked, porting is mechanical and the agent
does it well.

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
