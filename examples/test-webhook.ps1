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
  service = "HVAC Maintenance"
  description = "We would like to schedule a routine HVAC maintenance visit."
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

  $headers = @{}
  $headers[$authHeaderName] = $authHeaderValue
  $headers["x-rapidhhome-signature"] = $Signature

  try {
    $response = Invoke-RestMethod -Method Post -Uri $webhookUrl -Headers $headers -ContentType "application/json" -Body $body
    return $response
  }
  catch {
    $statusCode = $null
    $responseBody = $null

    if ($_.Exception.Response) {
      try { $statusCode = [int]$_.Exception.Response.StatusCode } catch {}

      try {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
          $reader = [System.IO.StreamReader]::new($stream)
          try { $responseBody = $reader.ReadToEnd() } finally { $reader.Dispose() }
        }
      }
      catch {}
    }

    if ($statusCode) {
      Write-Host "HTTP $statusCode"
    }

    if ($responseBody) {
      Write-Host $responseBody
      return
    }

    throw
  }
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
