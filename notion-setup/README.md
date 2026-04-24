# notion-setup

Notion database schemas for the Project Intelligence OS. The creation steps
live in `../SETUP_AND_VALIDATE_v5.md` sections A6.1–A6.4 and must be run
with a valid `NOTION_API_KEY` and `NOTION_PARENT_PAGE_ID`.

Once created, the three database IDs (Projects, Milestones, Tasks) are
written to `database-ids.json` in this directory and committed.

The three databases are:

- **Projects** — one row per product. Status, Type, Repo URL, Created.
- **Milestones** — one row per milestone, linked to a Project. Status,
  Category (FOUNDATION/CORE/FEATURE/INTEGRATION/HARDENING), Definition of
  Done, Branch, Review Notes.
- **Tasks** — one row per atomic task, linked to a Milestone. Status, Agent
  Type, Model, Financial Precision flag, Security Sensitive flag, Acceptance
  Criteria, Verification, Git Commit URL, Session Log, Quality Gate result.

`database-ids.json` is generated at setup time — it is not checked in until
Phase A runs end to end.
