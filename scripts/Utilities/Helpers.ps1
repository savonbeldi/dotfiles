function Resolve-Exception
{
  param(
    [Parameter(Mandatory)]
    [string]$Message,

    [Parameter(Mandatory)]
    [ValidateSet("Exit", "Warn", "Throw")]
    [string]$ExceptionAction
  )

  if(!$Message)
  {
    $Message = "An error occurred."
  }

  if ($ExceptionAction -eq "Exit")
  {
    Exit-Error $message
  }
  elseif ($ExceptionAction -eq "Warn")
  {
    Write-Warning $message
  }
  else
  {
    throw $message
  }
}

function Confirm-Action
{
  param(
    [Parameter(Mandatory)]
    [string]$Message,

    [ValidateSet("Y", "N")]
    [string]$Default = "Y",

    [ValidateSet("Exit", "Warn", "Throw")]
    [string]$ExceptionAction = "Throw"
  )

  try
  {
    Write-Host "$Message ($($Default -eq "Y" ? "Y/n" : "y/N")): " -ForegroundColor Blue -NoNewline

    $confirmation = Read-Host

    if ($confirmation -notmatch "^[yYnN]?$")
    {
      throw "Invalid input. Aborted."
    }

    # Handle empty input
    if ($confirmation -eq "")
    {
      return $Default -eq "Y"
    }
    # Handle positive input
    elseif ($confirmation -match "^[yY]")
    {
      return $true
    }
    # Handle negative input
    elseif ($confirmation -match "^[nN]")
    {
      return $false
    }
    else
    {   
      throw "Invalid input. Aborted."
    }
  }
  catch
  {
    Resolve-Exception `
      -Message "Failed to receive input: $($_.Exception.Message)" `
      -ExceptionAction $ExceptionAction
  }
}

function Symlink-Files
{
  param (
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Target
  )

  Get-ChildItem -File -Recurse -Force -Path $Source | ForEach-Object {
    $targetPath = $_.FullName.Replace($Source, $Target)
    $sourcePath = $_.FullName
    
    $command = "New-Item -ItemType SymbolicLink -Force -Verbose -ErrorAction Stop -Path $targetPath -Value $sourcePath | Out-Null"

    if ($Target.Contains("root"))
    {
      sudo pwsh -c $command
    }
    else
    {
      Invoke-Expression $command
    }
  }
}