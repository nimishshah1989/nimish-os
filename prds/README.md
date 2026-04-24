# prds

Product requirements documents. One file per product
(`<project-name>.md`). Feed a PRD to Opus 4.7 for decomposition:

```
claude --model anthropic,claude-opus-4-7 < prds/<project>.md
```

The model produces milestones and tasks as JSON, which are loaded into
Notion per `../SETUP_AND_VALIDATE_v5.md` section A8.5.
