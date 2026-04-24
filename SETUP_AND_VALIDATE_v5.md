# Project Intelligence OS — Setup and Validation
### Version 5.0 Final | GitHub-First Architecture
### Nimish Shah | April 2026

---

## For Claude Code Reading This

This is an executable instruction set. Read it fully before starting.

**Two phases:**
- **Phase A — Core** (runs anywhere — laptop, EC2, wherever you have Claude Code). Sets up models, skills, Notion, validation. ~60 min.
- **Phase B — EC2 Extensions** (runs when Nimish is ready to deploy). SonarQube, Telegram channels, reverse proxy. ~30 min. Deferred.

Run Phase A first. Phase A ends with a validated system ready to build products. Phase B is documented here but executed later.

**Non-negotiables:**
1. Never skip verification steps
2. Never assume success — run the check
3. If a step fails, stop and report; do not improvise
4. Phase A ends only when all items in Go/No-Go checklist pass

---

## Model Roster (Decided, Do Not Change)

| Task | Model | Provider | Route |
|------|-------|----------|-------|
| Architecture, decomposition, Plan Mode | claude-opus-4-7 | Anthropic direct | `think` |
| Coding, default, long-context | kimi-k2.6 | Moonshot direct | `default`, `longContext` |
| Code review, milestone review | claude-opus-4-6 | Anthropic direct | (explicit invoke for review agents) |
| Background file scans | deepseek-chat-v3.1 | OpenRouter (paid) | `background` |
| Fallback coder | moonshotai/kimi-k2.6 | OpenRouter | (if Moonshot direct fails) |

These are written into the CCR config below. User does not configure them.

---

## Phase 0 — Input Collection (Core Only)

Stop and ask Nimish for these inputs:

```
Before I set up the Project Intelligence OS, I need the following:

── REQUIRED FOR PHASE A ──

1. GitHub username: ___
2. GitHub Personal Access Token (scopes: repo, workflow, admin:repo_hook):
   Create at https://github.com/settings/tokens → ___
3. Notion API key (create integration): https://www.notion.so/my-integrations → ___
4. Notion parent page ID (open any page, copy 32-char ID from URL): ___
5. Anthropic API key: https://console.anthropic.com/settings/keys → ___
6. Moonshot API key (top up $10 first): https://platform.moonshot.ai → ___
7. OpenRouter API key (free tier works): https://openrouter.ai/keys → ___
8. Name for setup repo (default: nimish-os): ___
9. Name for validation project repo (default: portfolio-validator): ___

── PHASE B CREDENTIALS (optional, can provide later) ──

10. EC2 IP, SSH user, SSH key path (leave blank to defer Phase B): ___
11. Telegram user ID (send /start to @userinfobot, leave blank to defer): ___

── CONFIRMATION ──

12. Should I skip Phase B for now? (yes/no) — default yes
```

**Store responses:**

```bash
mkdir -p ~/.nimish-os && cd ~/.nimish-os
cat > .setup-inputs <<'EOF'
GITHUB_USERNAME=___
GITHUB_TOKEN=___
NOTION_API_KEY=___
NOTION_PARENT_PAGE_ID=___
ANTHROPIC_API_KEY=___
MOONSHOT_API_KEY=___
OPENROUTER_API_KEY=___
SETUP_REPO_NAME=nimish-os
TEST_PROJECT_NAME=portfolio-validator
SKIP_PHASE_B=yes
EOF
chmod 600 .setup-inputs
```

Do not proceed until every Phase A field has a real value.

---

# PHASE A — CORE SETUP

## A1. Prerequisites

```bash
set -a && source ~/.nimish-os/.setup-inputs && set +a
```

### A1.1 Claude Code version
```bash
claude --version
```
**Verify:** v2.1.80 or higher. If lower: `claude update`.

### A1.2 Node, npm, jq
```bash
node --version && npm --version
jq --version 2>/dev/null || (brew install jq 2>/dev/null || sudo apt install -y jq)
```

### A1.3 GitHub CLI
```bash
gh --version 2>/dev/null || (brew install gh 2>/dev/null || sudo apt install -y gh)
echo "$GITHUB_TOKEN" | gh auth login --with-token
gh auth status
```
**Verify:** "Logged in to github.com as $GITHUB_USERNAME"

### A1.4 Git config
```bash
git config --global user.name 2>/dev/null || git config --global user.name "$GITHUB_USERNAME"
git config user.email > /dev/null 2>&1 || echo "Ask Nimish for commit email, then: git config --global user.email <email>"
```

### A1.5 Install CCR
```bash
npm install -g @musistudio/claude-code-router
ccr --version
```

**Phase A1 complete when all five checks return clean.**

---

## A2. Create Central GitHub Repo

This repo is the permanent artifact. Everything else bootstraps from here.

### A2.1 Create private repo
```bash
gh repo create "$GITHUB_USERNAME/$SETUP_REPO_NAME" \
  --private \
  --description "Nimish's Project Intelligence OS — setup, skills, configs, docs" \
  --clone
cd "$SETUP_REPO_NAME"
```

### A2.2 Scaffold directory structure
```bash
mkdir -p claude-config/{skills,github-workflows,ccr}
mkdir -p notion-setup docs prds validation
touch .gitignore README.md

cat > .gitignore <<'EOF'
.setup-inputs
.env
.env.local
*.log
__pycache__/
node_modules/
.ccr-runtime/
EOF

cat > README.md <<'EOF'
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
EOF

git add -A && git commit -m "[SETUP] chore: initial scaffold"
git push -u origin main
```

**Verify:** `gh repo view` shows the repo exists, initial commit pushed.

---

## A3. Global CLAUDE.md

### A3.1 Write the rules file into the repo
```bash
cat > claude-config/CLAUDE.md <<'EOF'
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
EOF

# Install globally
mkdir -p ~/.claude
cp claude-config/CLAUDE.md ~/.claude/CLAUDE.md
```

**Verify:** `head -3 ~/.claude/CLAUDE.md` shows "# Forge OS — Global Rules v5.0"

---

## A4. CCR Configuration (Models Baked In)

### A4.1 Write config with all model decisions
```bash
cat > claude-config/ccr/config.json <<EOF
{
  "LOG": true,
  "APIKEY": "ccr-$(openssl rand -hex 16)",
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "Providers": [
    {
      "name": "anthropic",
      "api_base_url": "https://api.anthropic.com/v1/messages",
      "api_key": "$ANTHROPIC_API_KEY",
      "models": [
        "claude-opus-4-7",
        "claude-opus-4-6",
        "claude-sonnet-4-6",
        "claude-haiku-4-5-20251001"
      ]
    },
    {
      "name": "moonshot",
      "api_base_url": "https://api.moonshot.ai/v1/chat/completions",
      "api_key": "$MOONSHOT_API_KEY",
      "models": ["kimi-k2.6", "kimi-k2-thinking"],
      "transformer": { "use": ["cleancache"] }
    },
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "$OPENROUTER_API_KEY",
      "models": [
        "deepseek/deepseek-chat-v3.1",
        "moonshotai/kimi-k2.6"
      ],
      "transformer": { "use": ["openrouter"] }
    }
  ],
  "Router": {
    "default":     "moonshot,kimi-k2.6",
    "background":  "openrouter,deepseek/deepseek-chat-v3.1",
    "think":       "anthropic,claude-opus-4-7",
    "longContext": "moonshot,kimi-k2.6",
    "longContextThreshold": 45000,
    "webSearch":   "anthropic,claude-opus-4-7",
    "image":       "moonshot,kimi-k2.6"
  }
}
EOF

# Install to CCR runtime location
mkdir -p ~/.claude-code-router
cp claude-config/ccr/config.json ~/.claude-code-router/config.json
```

### A4.2 Start CCR
```bash
pkill -f "ccr" 2>/dev/null
ccr start &
sleep 5
curl -s http://127.0.0.1:3456/health && echo " ✓ CCR up"
```

### A4.3 Test each model route

**Test Kimi (default):**
```bash
CCR_KEY=$(jq -r .APIKEY ~/.claude-code-router/config.json)
curl -s -X POST http://127.0.0.1:3456/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $CCR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"moonshot,kimi-k2.6","max_tokens":20,"messages":[{"role":"user","content":"Reply: KIMI-OK"}]}' \
  | jq -r '.content[0].text // .error.message'
```
**Verify:** Contains "KIMI-OK". If 401/402: check Moonshot balance at platform.moonshot.ai.

**Test Opus 4.7 (think):**
```bash
curl -s -X POST http://127.0.0.1:3456/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $CCR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"anthropic,claude-opus-4-7","max_tokens":20,"messages":[{"role":"user","content":"Reply: OPUS47-OK"}]}' \
  | jq -r '.content[0].text // .error.message'
```
**Verify:** Contains "OPUS47-OK".

**Test Opus 4.6 (review):**
```bash
curl -s -X POST http://127.0.0.1:3456/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $CCR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"anthropic,claude-opus-4-6","max_tokens":20,"messages":[{"role":"user","content":"Reply: OPUS46-OK"}]}' \
  | jq -r '.content[0].text // .error.message'
```
**Verify:** Contains "OPUS46-OK".

**Test DeepSeek (background):**
```bash
curl -s -X POST http://127.0.0.1:3456/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $CCR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"openrouter,deepseek/deepseek-chat-v3.1","max_tokens":20,"messages":[{"role":"user","content":"Reply: DS-OK"}]}' \
  | jq -r '.content[0].text // .error.message'
```
**Verify:** Contains "DS-OK". If 402: top up OpenRouter credits at openrouter.ai/credits.

### A4.4 Persist activation
```bash
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
grep -q 'ccr activate' "$SHELL_RC" || echo 'eval "$(ccr activate)"' >> "$SHELL_RC"
eval "$(ccr activate)"
```

**Phase A4 complete when all four model routes respond correctly.**

---

## A5. Skills Installation

### A5.1 Community skills
```bash
npx skills add garrytan/cso
npx skills add garrytan/qa-only
npx skills add garrytan/ship
npx skills add garrytan/canary
npx skills add wrsmith108/varlock-claude-skill
npx skills add kepano/obsidian-skills
npx skills list | grep -E "(cso|qa-only|ship|canary|varlock|obsidian)" | wc -l
```
**Verify:** Output is 6 (six skills present).

### A5.2 Write domain skills into repo
```bash
cat > claude-config/skills/financial-platform.md <<'EOF'
---
name: financial-platform
description: Rules for financial intelligence and investment platforms
---
## Calculation Rules
1. All monetary values use Python Decimal, never float
2. Percentages and ratios rounded to 2 decimal places
3. Every calculation has a test against manually-verified expected value
4. Reconciliation: computed totals match source sum within Decimal('0.01')
5. Always check denominator != 0 before dividing
6. Log input and output values for every financial calculation

## API Rules
7. Every financial endpoint validates input types before computing
8. Financial API responses include computed_at ISO timestamp
9. Batch computations report count_processed and count_failed separately

## Data Rules
10. Never use raw API values in arithmetic without type assertion
11. Missing values default to Decimal('0.00') unless explicitly documented
12. DB queries on financial tables must have an audit log entry
EOF

cat > claude-config/skills/data-pipeline.md <<'EOF'
---
name: data-pipeline
description: Rules for data ingestion and processing pipelines
---
## Structure
1. Every pipeline has clear input and output contracts
2. Every pipeline logs: start, end, records_in, records_out, errors
3. Failed records go to dead-letter table, never silently dropped
4. All pipelines idempotent: safe to re-run on same input
5. Never load into production without staging first

## Quality
6. Every pipeline has a reconciliation step
7. Schema changes require migration file before pipeline code
8. External API calls have retry with exponential backoff
9. Rate limits respected via rate limiter, never sleep()

## Financial Data
10. Market data timestamps in UTC
11. Price data carries source + retrieval timestamp
12. No pipeline overwrites historical data without explicit backfill flag
EOF

cat > claude-config/skills/api-standards.md <<'EOF'
---
name: api-standards
description: FastAPI conventions across all projects
---
## Routes
1. Every router has /health as first route
2. Route handlers call service functions — no business logic in routes
3. All routes declare explicit response_model and status_code
4. All routes have a docstring

## Errors
5. External calls wrapped in try/except with specific exception types
6. HTTP errors use HTTPException with descriptive detail
7. Validation errors return 422 with field-level details
8. Never return raw exception messages to client

## Security
9. Non-public routes use Depends(get_current_user)
10. Financial endpoints log requesting user ID
11. Request bodies validated with Pydantic models, not raw dicts
EOF

cat > claude-config/skills/restaurant-intelligence.md <<'EOF'
---
name: restaurant-intelligence
description: Rules for restaurant and F&B intelligence platforms
---
## Data
1. Menu prices in smallest currency unit (paise for INR)
2. Inventory quantities carry their unit (kg, pieces, portions)
3. Order timestamps in UTC, displayed in local timezone
4. Vendor data never modified — only annotated

## Agents
5. No customer-facing messages without confirmation step
6. WhatsApp messages logged before sending, not after
7. Recommendations based on inventory levels, not just history
8. Cost calculations show both unit and extended cost

## Integration
9. PetPooja: verify outlet ID matches before writing
10. Sales data: POS totals match computed totals daily
EOF

# Install globally
mkdir -p ~/.claude/skills
cp claude-config/skills/*.md ~/.claude/skills/
ls ~/.claude/skills/
```
**Verify:** Four domain skills present in `~/.claude/skills/`.

---

## A6. Notion Database Setup

### A6.1 Create Projects DB
```bash
PROJECTS_DB_ID=$(curl -s -X POST https://api.notion.com/v1/databases \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent":{"type":"page_id","page_id":"'$NOTION_PARENT_PAGE_ID'"},
    "title":[{"type":"text","text":{"content":"Projects"}}],
    "properties":{
      "Name":{"title":{}},
      "Status":{"select":{"options":[
        {"name":"active","color":"green"},
        {"name":"paused","color":"yellow"},
        {"name":"completed","color":"blue"},
        {"name":"archived","color":"gray"}
      ]}},
      "Type":{"select":{"options":[
        {"name":"financial","color":"purple"},
        {"name":"restaurant","color":"orange"},
        {"name":"agriculture","color":"green"},
        {"name":"other","color":"gray"}
      ]}},
      "Repo URL":{"url":{}},
      "Created":{"created_time":{}}
    }
  }' | jq -r .id)
echo "PROJECTS_DB_ID=$PROJECTS_DB_ID" >> ~/.nimish-os/.setup-inputs
```

### A6.2 Create Milestones DB (linked to Projects)
```bash
MILESTONES_DB_ID=$(curl -s -X POST https://api.notion.com/v1/databases \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent":{"type":"page_id","page_id":"'$NOTION_PARENT_PAGE_ID'"},
    "title":[{"type":"text","text":{"content":"Milestones"}}],
    "properties":{
      "Milestone ID":{"title":{}},
      "Project":{"relation":{"database_id":"'$PROJECTS_DB_ID'","single_property":{}}},
      "Status":{"select":{"options":[
        {"name":"todo","color":"gray"},
        {"name":"in-progress","color":"blue"},
        {"name":"needs-review","color":"yellow"},
        {"name":"approved","color":"green"},
        {"name":"blocked","color":"red"}
      ]}},
      "Category":{"select":{"options":[
        {"name":"FOUNDATION","color":"blue"},
        {"name":"CORE","color":"purple"},
        {"name":"FEATURE","color":"green"},
        {"name":"INTEGRATION","color":"orange"},
        {"name":"HARDENING","color":"red"}
      ]}},
      "Definition of Done":{"rich_text":{}},
      "Branch":{"rich_text":{}},
      "Review Notes":{"rich_text":{}}
    }
  }' | jq -r .id)
echo "MILESTONES_DB_ID=$MILESTONES_DB_ID" >> ~/.nimish-os/.setup-inputs
```

### A6.3 Create Tasks DB (linked to Milestones)
```bash
TASKS_DB_ID=$(curl -s -X POST https://api.notion.com/v1/databases \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent":{"type":"page_id","page_id":"'$NOTION_PARENT_PAGE_ID'"},
    "title":[{"type":"text","text":{"content":"Tasks"}}],
    "properties":{
      "Task ID":{"title":{}},
      "Milestone":{"relation":{"database_id":"'$MILESTONES_DB_ID'","single_property":{}}},
      "Status":{"select":{"options":[
        {"name":"todo","color":"gray"},
        {"name":"in-progress","color":"blue"},
        {"name":"auto-merged","color":"yellow"},
        {"name":"done","color":"green"},
        {"name":"blocked","color":"red"}
      ]}},
      "Agent Type":{"select":{"options":[
        {"name":"ARCHITECT","color":"purple"},
        {"name":"CODER","color":"blue"},
        {"name":"REVIEWER","color":"green"},
        {"name":"DEVOPS","color":"orange"}
      ]}},
      "Model":{"select":{"options":[
        {"name":"opus-4-7","color":"purple"},
        {"name":"opus-4-6","color":"pink"},
        {"name":"kimi-k2.6","color":"green"},
        {"name":"deepseek","color":"gray"}
      ]}},
      "Financial Precision":{"checkbox":{}},
      "Security Sensitive":{"checkbox":{}},
      "Acceptance Criteria":{"rich_text":{}},
      "Verification":{"rich_text":{}},
      "Git Commit":{"url":{}},
      "Session Log":{"rich_text":{}},
      "Quality Gate":{"select":{"options":[
        {"name":"PASSED","color":"green"},
        {"name":"FAILED","color":"red"},
        {"name":"WARN","color":"yellow"}
      ]}}
    }
  }' | jq -r .id)
echo "TASKS_DB_ID=$TASKS_DB_ID" >> ~/.nimish-os/.setup-inputs
```

### A6.4 Save DB IDs into repo
```bash
cat > notion-setup/database-ids.json <<EOF
{
  "projects_db_id": "$PROJECTS_DB_ID",
  "milestones_db_id": "$MILESTONES_DB_ID",
  "tasks_db_id": "$TASKS_DB_ID",
  "parent_page_id": "$NOTION_PARENT_PAGE_ID",
  "created_at": "$(date -u +%FT%TZ)"
}
EOF
git add notion-setup/database-ids.json
git commit -m "[SETUP] chore: Notion database IDs"
git push
```

### A6.5 Verify all three
```bash
for db in PROJECTS MILESTONES TASKS; do
  VAR="${db}_DB_ID"
  ID="${!VAR}"
  NAME=$(curl -s "https://api.notion.com/v1/databases/$ID" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: 2022-06-28" | jq -r '.title[0].text.content')
  echo "✓ $db DB ($NAME) — ${ID:0:8}..."
done
```
**Verify:** Three checkmarks with DB names.

**Phase A6 complete when Notion UI shows three linked databases.**

---

## A7. GitHub Actions Quality Workflow Template

Write the workflow template into the repo (future projects copy from here):

```bash
cat > claude-config/github-workflows/quality-gate.yml <<'EOF'
name: Quality Gate
on:
  push:
    branches: ['milestone/*', main, develop]
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip --break-system-packages
          if [ -f requirements.txt ]; then
            pip install -r requirements.txt --break-system-packages
          fi
          pip install pytest pytest-cov ruff mypy --break-system-packages
      - name: Lint
        run: ruff check . || true
      - name: Type check (if applicable)
        run: mypy . --ignore-missing-imports || true
      - name: Test with coverage
        run: |
          if [ -d tests ]; then
            pytest tests/ --cov=. --cov-report=xml --cov-report=term --tb=short -q
            # Fail if coverage below 70%
            python -c "
import xml.etree.ElementTree as ET
t = ET.parse('coverage.xml').getroot()
c = float(t.attrib.get('line-rate','0')) * 100
print(f'Coverage: {c:.1f}%')
if c < 70: exit(1)
"
          fi
EOF

git add claude-config/github-workflows/quality-gate.yml
git commit -m "[SETUP] chore: quality gate workflow template"
git push
```

---

## A8. Validation Project — Portfolio Validator

This is the acceptance test. It must produce the correct outputs before Phase A is complete.

### A8.1 Create the project in Notion
```bash
TEST_PROJECT_PAGE_ID=$(curl -s -X POST https://api.notion.com/v1/pages \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "parent":{"database_id":"'$PROJECTS_DB_ID'"},
    "properties":{
      "Name":{"title":[{"text":{"content":"Portfolio Validator (SYSTEM TEST)"}}]},
      "Status":{"select":{"name":"active"}},
      "Type":{"select":{"name":"financial"}}
    }
  }' | jq -r .id)
echo "TEST_PROJECT_PAGE_ID=$TEST_PROJECT_PAGE_ID" >> ~/.nimish-os/.setup-inputs
```

### A8.2 Create the GitHub repo
```bash
cd ~
gh repo create "$GITHUB_USERNAME/$TEST_PROJECT_NAME" \
  --private \
  --description "System validation project for Project Intelligence OS" \
  --clone
cd "$TEST_PROJECT_NAME"

# Copy the quality workflow from nimish-os
mkdir -p .github/workflows
cp ~/nimish-os/claude-config/github-workflows/quality-gate.yml .github/workflows/
```

### A8.3 Write the mini PRD
```bash
cat > PRD.md <<'EOF'
# Portfolio Validator — PRD

## Purpose
A FastAPI service that reconciles a mock portfolio CSV against computed totals.
Exists to validate that the Project Intelligence OS catches financial calculation
errors, quality violations, and missing observability.

## Requirements
1. Accept CSV upload: columns symbol, quantity, price
2. Compute total = sum(quantity * price)
3. Compute same total by separate loop as reconciliation check
4. Expose GET /health → {"status":"ok","timestamp":<iso_utc>}
5. Expose POST /reconcile → {"total_value":<str>, "reconciliation_match":<bool>, "rows_processed":<int>, "computed_at":<iso>}
6. All monetary values use Decimal, 2 decimal places
7. Write audit log entry for every /reconcile call
8. Return 422 on malformed CSV

## Quality Requirements
- Test coverage >= 70%
- Zero blocker/critical violations
- Zero hardcoded credentials
- Dependencies pinned

## Definition of Done
- curl -F "file=@test.csv" http://localhost:8000/reconcile returns correct total with match=true
- Quality gate PASSED in GitHub Actions
- All 5 acceptance tests pass
EOF

git add PRD.md .github/workflows/
git commit -m "[SYSTEM-TEST] chore: initial PRD and quality workflow"
git push -u origin main
```

### A8.4 Decompose via Opus 4.7
```bash
# Route this prompt to Opus 4.7 via CCR think route
claude --model anthropic,claude-opus-4-7 <<'PROMPT'
Read PRD.md in the current directory. Decompose into exactly 2 milestones:
- M-01 FOUNDATION: project scaffold, /health endpoint, CI working
- M-02 CORE: /reconcile endpoint with Decimal math and full tests

For each milestone, produce 3 atomic tasks. Output as JSON:

/tmp/milestones.json:
[{"id":"M-01","title":"","category":"FOUNDATION","definition_of_done":""}, ...]

/tmp/tasks.json:
[{"id":"T-M01-001","milestone_id":"M-01","title":"","agent_type":"CODER",
  "acceptance_criteria":"","verification":""}, ...]

Load both files when done. Confirm they parse as valid JSON.
PROMPT
```

**Verify:**
```bash
jq -r '.[].id' /tmp/milestones.json
jq -r '.[].id' /tmp/tasks.json
# Expect 2 milestone IDs and 6 task IDs
```

### A8.5 Load tasks into Notion
```bash
# Create milestones
jq -c '.[]' /tmp/milestones.json | while read milestone; do
  MID=$(echo "$milestone" | jq -r .id)
  TITLE=$(echo "$milestone" | jq -r .title)
  CAT=$(echo "$milestone" | jq -r .category)
  DOD=$(echo "$milestone" | jq -r .definition_of_done)
  curl -s -X POST https://api.notion.com/v1/pages \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d "{
      \"parent\":{\"database_id\":\"$MILESTONES_DB_ID\"},
      \"properties\":{
        \"Milestone ID\":{\"title\":[{\"text\":{\"content\":\"$MID\"}}]},
        \"Status\":{\"select\":{\"name\":\"todo\"}},
        \"Category\":{\"select\":{\"name\":\"$CAT\"}},
        \"Definition of Done\":{\"rich_text\":[{\"text\":{\"content\":\"$DOD\"}}]}
      }
    }" > /dev/null
done

# Create tasks
jq -c '.[]' /tmp/tasks.json | while read task; do
  TID=$(echo "$task" | jq -r .id)
  TITLE=$(echo "$task" | jq -r .title)
  curl -s -X POST https://api.notion.com/v1/pages \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d "{
      \"parent\":{\"database_id\":\"$TASKS_DB_ID\"},
      \"properties\":{
        \"Task ID\":{\"title\":[{\"text\":{\"content\":\"$TID\"}}]},
        \"Status\":{\"select\":{\"name\":\"todo\"}},
        \"Agent Type\":{\"select\":{\"name\":\"CODER\"}},
        \"Model\":{\"select\":{\"name\":\"kimi-k2.6\"}},
        \"Financial Precision\":{\"checkbox\":true}
      }
    }" > /dev/null
done

echo "✓ Milestones and tasks loaded to Notion"
```

**Verify:** Open Notion in browser, check Milestones and Tasks DBs for new rows.

### A8.6 Execute M-01 with Kimi
```bash
git checkout -b milestone/M-01

claude --model moonshot,kimi-k2.6 <<'PROMPT'
Task T-M01-001: Create the Portfolio Validator project scaffold.
Load skills: financial-platform, api-standards.

Create:
- src/main.py — FastAPI app, /health returning {"status":"ok","timestamp":<iso_utc>}
- requirements.txt — fastapi==0.115.0, uvicorn==0.30.0, pytest==8.3.0,
  pytest-cov==5.0.0, python-multipart==0.0.9
- tests/test_health.py — verifies /health returns 200 with status key
- README.md — run instructions

Commit: [T-M01-001] feat: initial FastAPI scaffold with /health
PROMPT

git push origin milestone/M-01
```

### A8.7 Deliberately trigger quality failure
```bash
cat > src/bad_code.py <<'EOF'
# INTENTIONALLY BAD — to verify quality gate catches violations
def compute_bad_total(holdings):
    total = 0.0  # VIOLATION: float for money
    for h in holdings:
        total += h['quantity'] * h['price']
    avg = total / len(holdings)  # VIOLATION: no divide-by-zero check
    return total, avg

API_KEY = "sk-1234567890abcdef"  # VIOLATION: hardcoded credential

def execute_query(user_input):
    query = "SELECT * FROM trades WHERE user = '" + user_input + "'"  # VIOLATION: SQL injection
    return query
EOF

git add src/bad_code.py
git commit -m "[SYSTEM-TEST] chore: deliberate violations for gate test"
git push origin milestone/M-01
```

### A8.8 Verify gate FAILS
```bash
echo "Waiting 90s for CI to run..."
sleep 90
CONCLUSION=$(gh run list --branch milestone/M-01 --limit 1 --json conclusion --jq '.[0].conclusion')
echo "Conclusion: $CONCLUSION"
```
**Verify:** `conclusion` is `failure`. If `success`, the quality gate is broken — STOP and fix.

### A8.9 Remove bad code, verify gate PASSES
```bash
git rm src/bad_code.py
git commit -m "[SYSTEM-TEST] chore: remove deliberate violations"
git push origin milestone/M-01

sleep 90
CONCLUSION=$(gh run list --branch milestone/M-01 --limit 1 --json conclusion --jq '.[0].conclusion')
echo "After cleanup: $CONCLUSION"
```
**Verify:** Now `success`.

### A8.10 Complete M-02 with Kimi
```bash
claude --model moonshot,kimi-k2.6 <<'PROMPT'
Task T-M02-001/002/003: Implement POST /reconcile.
Load skills: financial-platform, api-standards, data-pipeline.

Implement:
- Accept CSV upload with columns symbol, quantity, price
- Use Decimal for all monetary math
- Compute total via sum() AND via separate loop for reconciliation
- Return JSON with total_value (str), reconciliation_match (bool),
  rows_processed (int), computed_at (iso)
- Write audit log to logs/audit.log
- 422 on malformed CSV
- Round monetary output to 2 decimals

Tests (tests/test_reconcile.py):
- test_valid_csv_reconciles
- test_empty_csv_returns_422
- test_zero_price_handled
- test_decimal_precision_preserved
- test_audit_log_written

Target 70%+ coverage.
Commit: [T-M02-001] feat: /reconcile endpoint with Decimal math
PROMPT

git push origin milestone/M-01
sleep 90
FINAL=$(gh run list --branch milestone/M-01 --limit 1 --json conclusion --jq '.[0].conclusion')
echo "Final: $FINAL"
```
**Verify:** `success`.

### A8.11 Route review to Opus 4.6
```bash
claude --model anthropic,claude-opus-4-6 <<'PROMPT'
Review the Portfolio Validator implementation on milestone/M-01 branch.
Check:
1. Decimal used throughout — no float anywhere in financial paths
2. Error handling covers all external call sites
3. Test coverage on analysis-critical paths
4. Any financial-platform skill violations

Output a review report. If approved, say APPROVED. If issues found,
list them as blocking issues to fix before merge.
PROMPT
```
**Verify:** Opus 4.6 responds with a review. If APPROVED, proceed. If issues listed, they must be fixed.

### A8.12 End-to-end functional test
```bash
cd ~/$TEST_PROJECT_NAME
uvicorn src.main:app --host 127.0.0.1 --port 8000 &
SERVER_PID=$!
sleep 3

# Test /health
HEALTH=$(curl -s http://localhost:8000/health)
echo "$HEALTH" | jq -e '.status == "ok"' && echo "✓ /health"

# Test /reconcile with known CSV
cat > /tmp/test_portfolio.csv <<'EOF'
symbol,quantity,price
AAPL,10,150.00
MSFT,5,380.00
GOOGL,2,2800.00
EOF

RECONCILE=$(curl -s -F "file=@/tmp/test_portfolio.csv" http://localhost:8000/reconcile)
# Expected: 10*150 + 5*380 + 2*2800 = 1500 + 1900 + 5600 = 9000.00
echo "$RECONCILE" | jq -e '.total_value == "9000.00"' && echo "✓ total correct"
echo "$RECONCILE" | jq -e '.reconciliation_match == true' && echo "✓ reconciliation"
echo "$RECONCILE" | jq -e '.rows_processed == 3' && echo "✓ row count"

kill $SERVER_PID
```
**Verify:** All three checkmarks appear.

**Phase A8 complete when all 12 sub-steps pass.**

---

## A9. Go/No-Go Checklist (Phase A)

```bash
cat > /tmp/phase-a-checklist.sh <<'CHECK'
#!/bin/bash
set -a && source ~/.nimish-os/.setup-inputs && set +a
PASS=0
FAIL=0

check() {
  if eval "$2"; then
    echo "✓ $1"; PASS=$((PASS+1))
  else
    echo "✗ FAIL: $1"; FAIL=$((FAIL+1))
  fi
}

echo "── Phase A Go/No-Go ──"

# Repo
check "nimish-os repo exists" "gh repo view $GITHUB_USERNAME/$SETUP_REPO_NAME > /dev/null 2>&1"

# Config
check "Global CLAUDE.md exists" "[ -f ~/.claude/CLAUDE.md ]"
check "CCR config valid JSON" "jq . ~/.claude-code-router/config.json > /dev/null 2>&1"
check "CCR service listening" "curl -sf http://127.0.0.1:3456/health > /dev/null"

# Models
CCR_KEY=$(jq -r .APIKEY ~/.claude-code-router/config.json)
check "Kimi K2.6 responds" \
  "curl -s -X POST http://127.0.0.1:3456/v1/messages -H 'x-api-key: $CCR_KEY' -H 'anthropic-version: 2023-06-01' -H 'Content-Type: application/json' -d '{\"model\":\"moonshot,kimi-k2.6\",\"max_tokens\":10,\"messages\":[{\"role\":\"user\",\"content\":\"ok\"}]}' | jq -e '.content' > /dev/null"
check "Opus 4.7 responds" \
  "curl -s -X POST http://127.0.0.1:3456/v1/messages -H 'x-api-key: $CCR_KEY' -H 'anthropic-version: 2023-06-01' -H 'Content-Type: application/json' -d '{\"model\":\"anthropic,claude-opus-4-7\",\"max_tokens\":10,\"messages\":[{\"role\":\"user\",\"content\":\"ok\"}]}' | jq -e '.content' > /dev/null"
check "Opus 4.6 responds" \
  "curl -s -X POST http://127.0.0.1:3456/v1/messages -H 'x-api-key: $CCR_KEY' -H 'anthropic-version: 2023-06-01' -H 'Content-Type: application/json' -d '{\"model\":\"anthropic,claude-opus-4-6\",\"max_tokens\":10,\"messages\":[{\"role\":\"user\",\"content\":\"ok\"}]}' | jq -e '.content' > /dev/null"

# Skills
check "Community skills installed (6)" "[ \$(npx skills list 2>/dev/null | grep -E '(cso|qa-only|ship|canary|varlock|obsidian)' | wc -l) -ge 6 ]"
check "financial-platform skill exists" "[ -f ~/.claude/skills/financial-platform.md ]"
check "restaurant-intelligence skill exists" "[ -f ~/.claude/skills/restaurant-intelligence.md ]"

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
[ $FAIL -eq 0 ] && echo "✅ PHASE A COMPLETE — READY FOR PRD EXECUTION" || exit 1
CHECK
chmod +x /tmp/phase-a-checklist.sh
bash /tmp/phase-a-checklist.sh
```

**Phase A is complete only when this script prints "PHASE A COMPLETE".**

If any check fails, see "Failure Recovery" at the end of this document.

---

## A10. Phase A Complete — Tell the User

```
✅ Project Intelligence OS — Phase A (Core) is operational.

What works right now:
- nimish-os repo on GitHub with all configs and skills version-controlled
- Opus 4.7 handles architecture and decomposition
- Kimi K2.6 handles coding (Moonshot direct API)
- Opus 4.6 handles review
- DeepSeek handles background (OpenRouter free)
- Notion databases (Projects, Milestones, Tasks) live and linked
- 10 skills installed (6 community + 4 domain)
- Validation project proved quality gates work end-to-end

What's deferred to Phase B (run when ready):
- SonarQube container on EC2 (for deeper code analysis beyond GitHub Actions)
- Telegram bots for phone control
- Karpathy wiki on EC2
- MCP integrations for SonarQube and Notion

Ready for product work:
- Feed any PRD to Opus 4.7 for decomposition
- Tasks flow to Notion automatically
- Kimi executes, Opus reviews
- GitHub Actions quality gates enforce standards
- You approve at milestone boundaries

First PRD ready to go: prds/cas-analyzer.md (in nimish-os repo)
```

---

# PHASE B — EC2 EXTENSIONS (Deferred)

Run when Nimish is ready to deploy services and enable phone control.
All Phase B credentials required in .setup-inputs: EC2_IP, EC2_USER, EC2_KEY_PATH, TELEGRAM_USER_ID.

## B1. SonarQube on EC2

### B1.1 Docker install and container start
```bash
ssh -i $EC2_KEY_PATH $EC2_USER@$EC2_IP \
  "docker --version 2>/dev/null || (curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker \$USER)"

SONAR_PASSWORD=$(openssl rand -base64 16)
echo "SONAR_PASSWORD=$SONAR_PASSWORD" >> ~/.nimish-os/.setup-inputs

ssh -i $EC2_KEY_PATH $EC2_USER@$EC2_IP <<REMOTE
docker rm -f sonarqube 2>/dev/null || true
sudo sysctl -w vm.max_map_count=262144
docker run -d --name sonarqube --restart unless-stopped \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:community
REMOTE
```

### B1.2 Wait for UP status
```bash
for i in 1 2 3 4 5 6; do
  sleep 30
  STATUS=$(ssh -i $EC2_KEY_PATH $EC2_USER@$EC2_IP \
    "curl -s http://localhost:9000/api/system/status" | jq -r .status 2>/dev/null)
  echo "Attempt $i: $STATUS"
  [ "$STATUS" = "UP" ] && break
done
[ "$STATUS" = "UP" ] || { echo "❌ SonarQube failed to start"; exit 1; }
```

### B1.3 Change admin password and generate token
```bash
curl -s -u admin:admin -X POST \
  "http://$EC2_IP:9000/api/users/change_password" \
  -d "login=admin&previousPassword=admin&password=$SONAR_PASSWORD"

SONAR_TOKEN=$(curl -s -u "admin:$SONAR_PASSWORD" -X POST \
  "http://$EC2_IP:9000/api/user_tokens/generate" \
  -d "name=claude-code-$(date +%s)" | jq -r .token)
echo "SONAR_TOKEN=$SONAR_TOKEN" >> ~/.nimish-os/.setup-inputs
echo "SONAR_HOST_URL=http://$EC2_IP:9000" >> ~/.nimish-os/.setup-inputs
```

### B1.4 Create JIP Financial Quality Gate
```bash
GATE_ID=$(curl -s -u "admin:$SONAR_PASSWORD" -X POST \
  "http://$EC2_IP:9000/api/qualitygates/create" \
  -d "name=JIP-Financial-Gate" | jq -r .id)

for condition in \
  "coverage:LT:70" \
  "duplicated_lines_density:GT:10" \
  "new_security_hotspots_reviewed:LT:100" \
  "new_blocker_violations:GT:0" \
  "new_critical_violations:GT:0"; do
  IFS=: read -r metric op threshold <<< "$condition"
  curl -s -u "admin:$SONAR_PASSWORD" -X POST \
    "http://$EC2_IP:9000/api/qualitygates/create_condition" \
    -d "gateId=$GATE_ID&metric=$metric&op=$op&error=$threshold" > /dev/null
done

curl -s -u "admin:$SONAR_PASSWORD" -X POST \
  "http://$EC2_IP:9000/api/qualitygates/set_as_default" -d "id=$GATE_ID"
```

## B2. Telegram Channels

Three bots via @BotFather, then pair to Claude Code:
```
Bot 1: JIP Main Bot → EC2
Bot 2: Local Dev Bot → laptop
Bot 3: Cloud Kitchen Bot → future CK project
```

Install plugin:
```bash
claude -c "/plugin marketplace add anthropics/claude-plugins-official"
claude -c "/plugin install telegram@claude-plugins-official"
```

Configure local:
```bash
mkdir -p ~/.claude/channels/telegram
echo "TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_LOCAL" > ~/.claude/channels/telegram/.env
```

Configure EC2:
```bash
ssh -i $EC2_KEY_PATH $EC2_USER@$EC2_IP \
  "mkdir -p ~/.claude/channels/telegram && echo 'TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_JIP' > ~/.claude/channels/telegram/.env"
```

## B3. Karpathy Wiki
```bash
git clone https://github.com/Ar9av/obsidian-wiki.git ~/obsidian-wiki-framework
cd ~/obsidian-wiki-framework && bash setup.sh
mkdir -p ~/nimish-wiki/{raw/{jip,ytip,cloud-kitchen,cas-analyzer,research},wiki/{architecture,financial,restaurant-tech,data-pipelines,api-patterns,decisions,post-mortems},inbox}
echo "OBSIDIAN_VAULT=$HOME/nimish-wiki" >> ~/.claude/.env
```

## B4. MCP Integrations
```bash
cat > ~/.claude/mcp-servers.json <<EOF
{
  "mcpServers": {
    "sonarqube": {
      "command": "npx",
      "args": ["-y", "@sonarsource/mcp-server-sonarqube"],
      "env": { "SONAR_URL": "$SONAR_HOST_URL", "SONAR_TOKEN": "$SONAR_TOKEN" }
    },
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/mcp-server-notion"],
      "env": { "NOTION_API_KEY": "$NOTION_API_KEY" }
    }
  }
}
EOF
```

## B5. Phase B Go/No-Go

Verify SonarQube UI accessible, Telegram bots respond to DM, Karpathy wiki has directories, MCP config is valid JSON. Full checklist template available at `claude-config/phase-b-checklist.sh`.

---

# FAILURE RECOVERY

**CCR won't start:**
```bash
pkill -f "ccr"; rm -rf ~/.claude-code-router/logs/; ccr start
```

**Kimi API 401/402:**
Check balance at platform.moonshot.ai. Minimum top-up $1.

**Notion API 401:**
Integration needs page access. Open parent page → Share → Add integration.

**Quality gate doesn't fail on bad code:**
- Check sonar-project.properties is in repo root
- Verify GitHub Actions logs for scan errors
- Confirm SONAR_TOKEN secret set on repo

**SonarQube won't start on EC2:**
- Need 4GB+ RAM free
- Run `sudo sysctl -w vm.max_map_count=262144`
- Check `docker logs sonarqube`

**GitHub Actions coverage gate always fails:**
Coverage script expects `coverage.xml` in repo root. Verify pytest-cov produces it.

---

# DAILY USAGE (Post-Setup)

**Start a new project:**
1. Create Notion project entry
2. Create GitHub repo, copy `claude-config/github-workflows/quality-gate.yml`
3. Write PRD in `prds/` in `nimish-os` repo
4. Feed PRD to Opus 4.7: `claude --model anthropic,claude-opus-4-7 < prds/my-project.md`
5. Opus produces milestones + tasks; load to Notion
6. Start first task: `claude --model moonshot,kimi-k2.6` and reference task ID
7. Auto-merge to milestone branch on gate pass
8. Approve milestone via Notion or Telegram (after Phase B)

**Routine commands:**
- `ccr status` — check router health
- `ccr restart` — if models flaky
- `claude --model anthropic,claude-opus-4-7` — force architect mode
- `claude --model moonshot,kimi-k2.6` — force coder mode
- `claude --model anthropic,claude-opus-4-6` — force reviewer mode

---

# END OF DOCUMENT

Claude Code: execute Phase A top to bottom. Report phase-by-phase.
Do not declare Phase A complete until Go/No-Go script prints ✅.
