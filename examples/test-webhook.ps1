param(
  [ValidateSet("valid", "invalid", "duplicate")]
  [string]$Mode = "valid"
)

$ErrorActionPreference = "Stop"

$webhookUrl = $env:RAPIDHHOME_WEBHOOK_URL
$authHeaderName = $env:RAPIDHHOME_AUTH_HEADER_NAME
$authHeaderValue = $env:RAPIDHHOME_AUTH_HEADER_VALUE
$hmacSecret = $env:RAPIDHHOME_HMAC_SECRET

$missing = @()
if (-not $webhookUrl) { $missing += "RAPIDHHOME_WEBHOOK_URL" }
if (-not $authHeaderName) { $missing += "RAPIDHHOME_AUTH_HEADER_NAME" }
if (-not $authHeaderValue) { $missing += "RAPIDHHOME_AUTH_HEADER_VALUE" }
if (-not $hmacSecret) { $missing += "RAPIDHHOME_HMAC_SECRET" }

if ($missing.Count -gt 0) {
  throw "Missing environment variable(s): $($missing -join ', ')"
}

$payload = [ordered]@{
  name = "Michael Brown"
  email = "michael@example.com"
  phone = "+1 555 018 7744"
  service = "HVAC Repair"
  description = "Our AC has completely stopped cooling and we need someone urgently today."
  preferred_date = "2026-09-22"
}

$body = $payload | ConvertTo-Json -Compress

function Get-HmacSha256Hex {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Secret
  )

  $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Secret)
  $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
  $hmac = [System.Security.Cryptography.HMACSHA256]::new($keyBytes)

  try {
    $hash = $hmac.ComputeHash($bodyBytes)
    return ([System.BitConverter]::ToString($hash)).Replace("-", "").ToLowerInvariant()
  }
  finally {
    $hmac.Dispose()
  }
}

function Send-TestRequest {
  param(
    [Parameter(Mandatory = $true)][string]$Signature
  )

  $headers = @{
    $authHeaderName = $authHeaderValue
    "x-rapidhhome-signature" = $Signature
  }

  Invoke-RestMethod -Method Post -Uri $webhookUrl -Headers $headers -ContentType "application/json" -Body $body
}

$signature = Get-HmacSha256Hex -Text $body -Secret $hmacSecret

if ($Mode -eq "invalid") {
  $signature = ("0" * 64)
}

Write-Host "Sending $Mode test to RapidHome..."

$first = Send-TestRequest -Signature $signature
$first | ConvertTo-Json -Depth 10

if ($Mode -eq "duplicate") {
  Write-Host ""
  Write-Host "Sending the same signed payload again to verify idempotency..."
  $second = Send-TestRequest -Signature $signature
  $second | ConvertTo-Json -Depth 10
}
