# RapidHome Lead Automation – n8n

A portfolio-ready n8n workflow for qualifying and routing inbound home-service leads.

## What it does

- Receives leads through a POST webhook.
- Normalizes incoming lead data with JavaScript.
- Scores leads using contact completeness and urgency keywords.
- Routes leads into **HOT**, **WARM**, and **COLD** paths.
- Sends an immediate Telegram alert for HOT leads.
- Retries Telegram delivery on transient failures.
- Captures notification failures and returns a structured error response.
- Returns structured JSON responses for each lead route.

> **Important:** the current public demo uses deterministic rules/keyword scoring. It does **not** call an LLM. An AI/LLM qualification step can be added later when a client requires it.

## Workflow architecture

![RapidHome workflow architecture](assets/workflow-architecture.svg)

## Tested behavior

The workflow was tested end-to-end with HOT, WARM, and COLD sample leads.

- **HOT:** urgent HVAC-style lead → high-priority route → Telegram alert → structured success response.
- **WARM:** routine service request → normal follow-up route → structured success response.
- **COLD:** general inquiry → nurture route → structured success response.
- **Failure handling:** Telegram notification errors are retried; after retry exhaustion the workflow captures the failure and returns HTTP 502.
- **External access:** the webhook was also tested through a public HTTPS tunnel during development.

## Import into n8n

1. Download `RapidHome_n8n_Public_Demo.json`.
2. In n8n, create or open a workflow and import the JSON file.
3. Open **Send Telegram Alert** and attach your own Telegram credential.
4. Replace `YOUR_TELEGRAM_CHAT_ID` with your own chat ID.
5. Review the webhook path and lead-scoring rules for your use case.
6. Test HOT, WARM, and COLD examples before publishing.

## Example request

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

## Example HOT response

```json
{
  "success": true,
  "qualification": "hot",
  "message": "Hot lead received and urgent notification sent successfully."
}
```

## Security

This public version intentionally excludes:

- Telegram bot tokens / API credentials
- the original Telegram chat ID
- n8n credential references
- n8n instance/workflow identifiers
- generated webhook IDs

Never commit real API keys, bot tokens, or client credentials to a public repository.

## Skills demonstrated

n8n · Workflow Automation · JavaScript · Webhooks · API Integration · Conditional Routing · Error Handling · Retry Logic · Telegram Integration
