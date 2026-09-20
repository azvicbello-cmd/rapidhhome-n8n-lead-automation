# Victor Bello

### AI Automation Specialist · n8n Workflow Developer · API & Business Process Automation

I build practical automation systems that help businesses respond faster, reduce repetitive work, and move important data reliably between tools.

My focus is **production-minded workflow automation**: authenticated webhooks, API integrations, data normalization, routing logic, duplicate-safe processing, persistent state, notifications, retries, and clear failure handling.

---

## Featured Project

### RapidHome Lead Automation — Secure n8n Lead Intake & Routing

A production-minded lead-response workflow for home-service businesses.

**What it does**

- Accepts authenticated inbound leads through a POST webhook
- Verifies request integrity with **HMAC-SHA256**
- Uses the exact raw request body for signature validation
- Normalizes lead data with JavaScript
- Generates deterministic lead keys for **idempotency**
- Stores new leads persistently with n8n Data Tables
- Detects duplicate webhook deliveries before repeat processing
- Scores and routes leads into **HOT / WARM / COLD**
- Sends urgent Telegram alerts for HOT opportunities
- Retries failed notifications and returns structured failure responses
- Returns explicit API responses for success, duplicates, invalid signatures, and downstream failures

**Security model**

```text
Authenticated Webhook
        |
        v
HMAC-SHA256 Verification
     /         \
 valid       invalid
   |            |
   v            v
Normalize    HTTP 401
& Score
   |
   v
Duplicate Protection
   |
   v
Persistent Storage
   |
   v
HOT / WARM / COLD Routing
```

The qualification layer is intentionally deterministic and rule-based. I do not present it as LLM-powered when it is not. AI enrichment can be added as a separate layer when there is a real business reason for it.

**Repository:** [RapidHome n8n Lead Automation](https://github.com/azvicbello-cmd/rapidhhome-n8n-lead-automation)

---

## What I Build

- Lead capture and response automation
- CRM and webhook workflows
- API-to-API integrations
- Business process automation
- Data validation and transformation pipelines
- Notification and escalation systems
- Duplicate-safe / idempotent workflows
- Error handling, retries, and operational safeguards
- AI-assisted workflow layers where they add measurable value

---

## Technical Toolkit

**Automation:** n8n · Webhooks · Conditional Routing · Data Tables  
**Integration:** REST APIs · JSON · HMAC-SHA256 · Authentication  
**Logic:** JavaScript · Data Normalization · Validation · Idempotency  
**Operations:** Retry Logic · Failure Handling · Structured API Responses · Telegram Integrations

---

## Engineering Approach

I prefer automation that is:

- **Secure** — authentication and request validation are built in
- **Reliable** — retries and explicit failure paths are designed intentionally
- **Idempotent** — repeated events do not create uncontrolled duplicate actions
- **Observable** — workflows return clear structured outcomes
- **Honest** — I distinguish deterministic automation from actual AI/LLM functionality
- **Adaptable** — business-specific rules and integrations can be changed without rebuilding the whole system

---

## Current Focus

I am building automation solutions for service businesses and operational teams where faster lead response, cleaner data flow, and fewer manual handoffs can directly improve outcomes.

Open to **AI automation, workflow automation, n8n, API integration, and business process automation** opportunities.

---

### Connect

[LinkedIn](https://www.linkedin.com/in/victor-bello-az) · [RapidHome Project](https://github.com/azvicbello-cmd/rapidhhome-n8n-lead-automation)
