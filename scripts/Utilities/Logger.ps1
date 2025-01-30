function Write-Ok
{
  param(
    [Parameter(Mandatory)]
    [string]$Message,

    [switch]$NewLine = $false
  )

  if ($NewLine) { Write-Host }
  
  Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warning
{
  param(
    [Parameter(Mandatory)]
    [string]$Message,
    [switch]$NewLine = $false
  )

  if ($NewLine) { Write-Host }
  
  Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error
{
  param(
    [Parameter(Mandatory)]
    [string]$Message,
    [switch]$NewLine = $false
  )

  if ($NewLine) { Write-Host }
  Write-Host "[ERROR] $Message" -ForegroundColor Red
}