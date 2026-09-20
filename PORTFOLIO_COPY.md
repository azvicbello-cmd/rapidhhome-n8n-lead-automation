# Portfolio copy

## Title
Secure n8n Lead Automation with HMAC Verification and Idempotency

## Role
Automation Engineer / n8n Workflow Developer

## Short description
Built and tested an end-to-end n8n lead-response system for home-service businesses. The workflow accepts authenticated webhook requests, verifies HMAC-SHA256 signatures against the raw request body, normalizes and scores leads, generates deterministic idempotency keys, stores leads persistently, blocks duplicate processing, routes HOT/WARM/COLD leads, sends urgent Telegram alerts, retries failed notifications, and returns structured API responses.

## What this proves
- Authenticated webhook/API intake
- HMAC-SHA256 request verification
- Raw-body signature validation
- JavaScript data normalization and scoring
- Deterministic idempotency keys
- Persistent n8n Data Table storage
- Duplicate-safe webhook processing
- Conditional routing and branching
- Telegram integration
- Retry and failure handling
- Structured success, duplicate, authorization, and error responses

## Verified security behavior
- Missing or incorrect Header Auth is blocked before workflow processing.
- Correct Header Auth with an invalid HMAC signature is rejected with HTTP 401.
- Correct Header Auth with a valid HMAC signature reaches the workflow.
- Repeated delivery of the same valid lead returns a duplicate response and does not create a second stored record.

## Current qualification model
Lead scoring is deterministic and rule-based. The project does not claim an LLM is performing qualification. LLM-based enrichment or classification can be added as a separate layer when appropriate.
