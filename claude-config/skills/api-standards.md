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
