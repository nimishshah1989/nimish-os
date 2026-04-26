# prds

Product requirements documents. One file per product
(`<project-name>.md`). Feed a PRD to Opus 4.7 for decomposition:

```
claude --model claude-opus-4-7 < prds/<project>.md
```

(Run from a sterile Claude Code session — see
`../docs/operations.md` "Default mode".)

The model produces milestones and tasks as JSON, which are loaded into
Notion per `../SETUP_AND_VALIDATE_v5.md` section A8.5.
