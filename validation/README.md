# validation

Reference material for the acceptance test described in
`../SETUP_AND_VALIDATE_v5.md` section A8 — the Portfolio Validator project
(`$GITHUB_USERNAME/$TEST_PROJECT_NAME`). The test proves, end-to-end, that:

1. Opus 4.7 can decompose a PRD into milestones and tasks.
2. Kimi K2.6 can execute tasks against those milestones.
3. The GitHub Actions quality gate fails on known-bad code
   (hardcoded credentials, SQL injection, float-money, divide-by-zero).
4. The same gate passes after the violations are removed.
5. Opus 4.6 can review the finished milestone.
6. `/reconcile` returns the manually-verified total for a known CSV.

Phase A is not complete until all twelve sub-steps of A8 and the Go/No-Go
checklist pass.
