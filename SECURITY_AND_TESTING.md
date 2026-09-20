# Security and Testing

## Security model

RapidHome uses layered webhook protection.

### 1. Header authentication
The n8n Webhook node requires a private header credential before a request can enter the workflow.

### 2. HMAC-SHA256 payload verification
For authenticated requests, the workflow computes an HMAC-SHA256 signature over the raw HTTP request body and compares it with the caller-supplied signature.

Using the raw body avoids false mismatches caused by JSON parsing or re-serialization.

### 3. Early rejection
If the HMAC signature does not match, the workflow exits through a dedicated response node:

```json
{
  "status": "unauthorized",
  "message": "Invalid webhook signature"
}
```

HTTP response code: `401`.

### 4. Idempotent processing
After successful authentication and signature validation, the lead is normalized and assigned a deterministic `lead_key`.

The workflow checks persistent n8n Data Table storage before downstream processing. Existing keys return a duplicate response rather than storing or processing the same lead again.

## Verified test matrix

| Test | Result |
| --- | --- |
| No valid Header Auth | HTTP 403 |
| Valid Header Auth, invalid HMAC | HTTP 401 with invalid-signature response |
| Valid Header Auth, valid HMAC | Request proceeds |
| First valid lead | One row stored |
| Same valid lead repeated | Duplicate response, stored row count remains unchanged |
| HOT lead | Alert path executes |
| WARM lead | Follow-up path executes |
| COLD lead | Nurture path executes |

## Secret handling

This repository intentionally excludes all real secrets and private identifiers.

Do not commit:
- Header Auth values
- HMAC secrets
- Telegram bot tokens
- Telegram chat IDs
- n8n credential IDs
- production table IDs
- client data

If a secret appears in a screenshot, log, issue, commit, or public artifact, rotate it before continuing.
