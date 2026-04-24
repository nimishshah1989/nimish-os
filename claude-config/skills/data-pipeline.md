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
