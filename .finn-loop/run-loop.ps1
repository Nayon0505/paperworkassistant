param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("build", "review")][string]$Mode,
  [string]$Repo = (Get-Location).Path,
  [int]$IntervalMinutes = 10,
  [switch]$Once,
  [switch]$Unattended
)

$ErrorActionPreference = "Stop"
$repoPath = (Resolve-Path -LiteralPath $Repo).Path
$envFile = Join-Path $repoPath ".env"

if (Test-Path -LiteralPath $envFile) {
  foreach ($line in Get-Content -LiteralPath $envFile) {
    if ($line -match '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<value>.*)$') {
      $name = $Matches.name
      $value = $Matches.value.Trim().Trim('"').Trim("'")
      if (-not [Environment]::GetEnvironmentVariable($name, "Process")) {
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
      }
    }
  }
}

if (-not $env:LINEAR_API_KEY) { throw "LINEAR_API_KEY is missing in $envFile" }
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) { throw "Codex CLI is not installed" }
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI is not installed" }
if (-not $Once -and -not $Unattended) {
  throw "Persistent loops require explicit -Unattended because they need Git and network access without approval prompts."
}

$skill = if ($Mode -eq "build") { '$finn-build' } else { '$finn-review' }
$prompt = "Use $skill for exactly one Finn-loop pass. Follow the installed skill and repository safety rules. Do not ask interactive questions; record blockers in Linear or GitHub as instructed."

do {
  $started = Get-Date
  Write-Host "[$started] Starting fresh $Mode pass in $repoPath"
  if ($Unattended) {
    & codex exec --cd $repoPath --sandbox danger-full-access --ephemeral `
      --config 'approval_policy="never"' $prompt
  }
  else {
    & codex exec --cd $repoPath --sandbox workspace-write --ephemeral `
      --config 'sandbox_workspace_write.network_access=true' $prompt
  }
  $exitCode = $LASTEXITCODE
  Write-Host "Pass finished with exit code $exitCode"
  if ($Once) { break }
  Start-Sleep -Seconds ([Math]::Max(60, $IntervalMinutes * 60))
} while ($true)
