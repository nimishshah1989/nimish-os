# PRD — CAS Analyzer

## Product
A backend service that ingests a CDSL/NSDL Consolidated Account Statement
(CAS) PDF and returns a normalized, computed view of the holder's mutual
fund portfolio: holdings, current value, XIRR per fund and overall,
concentration by asset class and AMC, and flagged risks.

## Users & Job-To-Be-Done
Individual mutual-fund investors and their advisors. Given a password-
protected CAS PDF, they want to know — in under ten seconds — what they
own, what it is worth as of the statement close, the actual realized
return per fund (XIRR, not headline CAGR), and whether any single fund,
AMC, or asset class breaches a concentration threshold.

## In Scope
- Upload a single CAS PDF (CDSL or NSDL, password-protected) via a
  multipart POST.
- Parse holdings per folio: ISIN, fund name, AMC, folio number, units,
  NAV-date, cost basis, and transaction history.
- Compute per-fund XIRR and portfolio-level XIRR. All monetary values
  use Python `Decimal`; no float arithmetic anywhere in the money path.
  Root-find via `scipy.optimize.brentq`.
- Categorize holdings by asset class (equity / debt / hybrid / commodity)
  and by AMC. Flag any single AMC above 25 % of portfolio value or any
  single fund above 15 %.
- Endpoints:
  - `POST /upload` — multipart PDF + password, returns `parse_id`.
  - `GET /holdings/{parse_id}`
  - `GET /xirr/{parse_id}`
  - `GET /risk/{parse_id}`
  - `GET /health` — returns 200 with Postgres reachability and scipy
    import check.
- Persist parsed CAS rows and computed metrics in Postgres. Idempotent
  on `(holder_pan_hash, statement_period)` — re-uploading the same CAS
  returns the cached result without re-parsing.
- Every external call (NAV lookup, fund metadata) wrapped in a
  try/except with named exception types and bounded retry.

## Out of Scope
- User accounts, authentication, multi-tenant isolation.
- Live NAV updates (use statement-close NAV; surface a staleness field).
- Tax report generation.
- Mobile or rich web UI — backend plus a minimal HTML upload page only.

## Quality Bar
- `pytest` coverage ≥ 70 % overall, 100 % on `xirr.py`,
  `concentration.py`, and `valuation.py`.
- XIRR regression test: one anonymized real CAS fixture with XIRR hand-
  computed in Excel; service result must match within `Decimal('0.01')`.
- Quality gate (Forge OS Four Laws) must pass:
  no hardcoded credentials, no SQL injection, no float-money, no
  divide-by-zero, every endpoint has `/health`, every external call
  wrapped in try/except with specific exception types.
- Structured JSON log per request with `parse_id`, endpoint, latency,
  and outcome.

## Acceptance Demo
```
curl -F "pdf=@fixtures/anonymized_cas.pdf" \
     -F "password=XXXX" \
     http://localhost:8000/upload
# => {"parse_id": "..."}

curl http://localhost:8000/xirr/$parse_id | jq
# => portfolio + per-fund XIRR within Decimal('0.01') of Excel reference

curl http://localhost:8000/risk/$parse_id | jq
# => flags naming the specific fund > 15 % and AMC > 25 % for the fixture
```

## Suggested Milestone Shape (guidance for decomposition, not binding)
- **M-01 FOUNDATION** — repo scaffold with FastAPI + Postgres + scipy
  pinned, `/health` endpoint, CI green, CAS PDF parser reading the
  fixture into a Pydantic model.
- **M-02 CORE** — `/upload`, `/holdings`, `/xirr`, `/risk` end-to-end on
  the fixture; XIRR and concentration computations with Decimal
  precision; idempotency; full test coverage meeting the quality bar.
