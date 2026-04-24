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
