# RapidHome Lead Automation - n8n

A production-minded n8n lead intake and response workflow for home-service businesses. RapidHome accepts authenticated inbound leads, validates request integrity, prevents duplicate processing, scores and routes leads, alerts on urgent opportunities, and returns structured API responses.

## Highlights

- Authenticated POST webhook using n8n Header Auth.
- Raw-body HMAC-SHA256 signature verification before lead processing.
- Explicit rejection of invalid signatures with HTTP 401.
- Deterministic `lead_key` generation for idempotency.
- Persistent lead storage with n8n Data Tables.
- Duplicate detection so repeated webhook deliveries do not create duplicate records or trigger repeat processing.
- JavaScript normalization and deterministic lead scoring.
- HOT / WARM / COLD routing.
- Immediate Telegram alerting for HOT leads.
- Retry and failure handling for notification delivery.
- Structured responses for success, duplicates, authorization failure, and downstream notification failure.

> The qualification logic is deterministic and rule-based. This project does not claim that an LLM performs lead qualification. AI enrichment or classification can be added as a separate layer when the business case requires it.

## Current architecture

![RapidHome workflow architecture](assets/workflow-architecture.svg)

The current exported workflow uses this exact logical flow:

```text
Webhook
  |
  v
Compute HMAC Signature
  |
  v
Validate HMAC Signature
  | valid                         | invalid
  v                               v
Normalize & Score Lead       Reject Invalid Signature (401)
  |
  +--------------------+
  |                    |
  v                    v
Check Duplicate Lead   Check New Lead
  | duplicate               | new
  v                         v
Respond Duplicate       Insert New Lead
Lead                         |
                             v
                     Restore Lead Payload
                             |
                             v
                   Route by Qualification
                    /        |         \
                  HOT       WARM       COLD
```

The HOT branch sends a Telegram alert and has separate success and failure handling. WARM and COLD leads follow their own structured response paths.

## Verified behavior

| Scenario | Expected result | Verified |
| --- | --- | --- |
| Missing/incorrect Header Auth | Request blocked before workflow processing | Yes - HTTP 403 |
| Correct Header Auth + invalid HMAC | Request rejected before lead processing | Yes - HTTP 401 |
| Correct Header Auth + valid HMAC | Request allowed into the workflow | Yes |
| First valid lead | Stored once and routed | Yes |
| Same valid lead submitted again | Duplicate response, no second data-table row | Yes |
| HOT lead | Priority Telegram alert path | Yes |
| WARM lead | Standard follow-up path | Yes |
| COLD lead | Nurture path | Yes |
| Telegram delivery failure | Retry/failure path and structured error response | Yes |

## Idempotency

RapidHome derives a deterministic `lead_key` from normalized lead attributes. If the source provides a stable external lead ID, that ID can be used. Otherwise the workflow builds a key from normalized contact/service fields.

Before downstream processing, the workflow checks persistent n8n Data Table storage. Existing keys return a duplicate response rather than storing or processing the same lead again.

Example duplicate response:

```json
{
  "status": "duplicate",
  "message": "Lead has already been processed",
  "lead_key": "lead:example@example.com|15550123456|example customer|hvac maintenance|2026-09-25"
}
```

## Webhook security

RapidHome uses two separate controls:

1. **Header authentication** gates access to the webhook.
2. **HMAC-SHA256 payload verification** validates that the raw request body matches the signature supplied by the sender.

Invalid signatures exit early through a dedicated HTTP 401 response and never reach lead normalization or routing.

See [SECURITY_AND_TESTING.md](SECURITY_AND_TESTING.md) for the verification matrix.

## Example lead payload

```json
{
  "name": "Michael Brown",
  "email": "michael@example.com",
  "phone": "+1 555 018 7744",
  "service": "HVAC Repair",
  "description": "Our AC has completely stopped cooling and we need someone urgently today.",
  "preferred_date": "2026-09-22"
}
```

## Public workflow export

[`RapidHome_n8n_Public_Demo.json`](RapidHome_n8n_Public_Demo.json) is the sanitized advanced workflow export that matches the current architecture.

Before importing it into your own n8n instance:

1. Create and attach your own Header Auth credential to **Webhook**.
2. Create and attach your own Crypto credential with an HMAC secret to **Compute HMAC Signature**.
3. Create a Data Table with the fields expected by the lead-storage nodes, then select it in **Check Duplicate Lead**, **Check New Lead**, and **Insert New Lead**.
4. Attach your own Telegram credential and replace `YOUR_TELEGRAM_CHAT_ID`.
5. Keep secrets in n8n credentials or another secure secret store. Do not hard-code them into a public workflow export.
6. Test valid-signature, invalid-signature, new-lead, duplicate-lead, HOT, WARM, COLD, and notification-failure paths before production use.

The public JSON intentionally removes credentials, chat IDs, private table IDs, webhook/runtime IDs, workflow IDs, version IDs, and instance metadata.

## Security hygiene

Never commit:

- Header Auth secrets
- HMAC signing secrets
- Telegram bot tokens
- Telegram chat IDs
- n8n credential references
- private Data Table identifiers
- private n8n instance or workflow identifiers
- production client data

## Skills demonstrated

n8n · Workflow Automation · JavaScript · Webhooks · HMAC-SHA256 · API Security · Idempotency · Persistent State · Data Tables · Conditional Routing · Error Handling · Retry Logic · Telegram Integration · Structured API Responses

## Portfolio

Built by **Victor Bello**.

LinkedIn: https://www.linkedin.com/in/victor-bello-az
