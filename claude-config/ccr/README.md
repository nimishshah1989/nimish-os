# claude-code-router (CCR) — DEFERRED

CCR was the original multi-provider routing layer (Kimi K2.6 for coding,
DeepSeek for background scans, Anthropic for planning/review, all behind
one `claude` invocation). It is **not used** in the current Claude-only
Max-plan workflow — see `../../docs/operations.md` "Default mode".

The files in this directory are kept so the Kimi/DeepSeek mix can be
re-enabled later without redoing the work:

- `config.template.json` — provider + Router skeleton with env-var
  placeholders
- `render-config.sh` — materializes `~/.claude-code-router/config.json`
  from `~/.nimish-os/.setup-inputs`, with Max-plan-mode detection that
  strips the anthropic provider when `SKIP_ANTHROPIC_API=yes`

## Why deferred

CCR's multi-provider routing introduces an entire class of failure modes
that don't exist in single-provider mode:

- ANTHROPIC_BASE_URL leaks (shell rc, settings.json, inherited env) all
  silently re-route to CCR even when CCR is dead → 401 / ECONNREFUSED.
- Subprocess invocations like `claude --model claude-opus-4-7` inherit
  the leaked base URL and route through CCR's anthropic provider, which
  in Max-plan mode has a placeholder API key → 401.
- Routing decisions live in three places (Router map, provider model
  lists, transformer chains) that have to stay consistent across edits.

For a one-person workflow on a Max-plan subscription, the cost of those
failure modes outweighs the per-token savings from Kimi/DeepSeek. We
revisit when:

1. Sustained Max-plan quota exhaustion makes Kimi cheaper in practice, or
2. A specific workload (e.g. very-long-context code review) genuinely
   needs Kimi's 256k context window.

## Re-enabling (when the time comes)

1. Ensure `~/.nimish-os/.setup-inputs` has `MOONSHOT_API_KEY` and
   `OPENROUTER_API_KEY` set.
2. `bash claude-config/ccr/render-config.sh`
3. `ccr start &`
4. `eval "$(ccr activate)"` in shell rc — only AFTER updating
   `claude-config/CLAUDE.md` "Model Routing" to reference CCR routes
   again, and removing `claude-config/launch.sh` from the default
   workflow.
