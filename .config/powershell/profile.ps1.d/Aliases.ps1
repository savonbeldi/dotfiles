# Aliases

Write-Host "Hello Aliases!" -ForegroundColor Red

## File system
Set-Alias -Name open -Value Open-Item
Set-Alias -Name ls -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItemForce
Set-Alias -Name cp -Value Copy-Item
Set-Alias -Name mv -Value Move-Item
Set-Alias -Name rm -Value Remove-Item
Set-Alias -Name cat -Value Get-Content

## Utilities
Set-Alias -Name reload -Value Import-PSProfile
Set-Alias -Name sc -Value Select-String
Set-Alias -Name so -Value Select-Object
Set-Alias -Name wo -Value Where-Object
Set-Alias -Name jp -Value Join-Path

## Terminal
Set-Alias -Name wh -Value Write-Host
Set-Alias -Name x -Value Clear-Host
Set-Alias -Name ch -Value Clear-AllHistory

# DevOps
# Set-Alias -Name k -Value kubectl # TODO fix autocomplete for aliases...
# Set-Alias -Name h -Value helm
# Set-Alias -Name a -Value az


## Functions
function Get-ChildItemForce { Get-ChildItem -Force @args }

function Clear-AllHistory { Clear-History; [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory(); Remove-Item (Get-PSReadlineOption).HistorySavePath }

function Import-PSProfile { . "$(Join-Path $DOTFILES '.config/powershell/profile.ps1')" } # TODO: doenst work

function Open-Item
{
  param(
    [string]$Path = "."
  )
  if ([bool]$env:WSL_DISTRO_NAME)
  {
    Start-Process -FilePath "explorer.exe" -ArgumentList $Path
  }
  else
  {
    Start-Process -FilePath "xdg-open" -ArgumentList $Path
  }
}

function Find-Item
{
  param(
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string]$Name,

    [ValidateSet($null, 'File', 'Directory')]
    [string] $Type = $null
  )

  $params = @{
    ErrorAction = "SilentlyContinue"
    Recurse     = $true
    Force       = $true
    Path        = $Path
    Filter      = "*$Name*"
  }
  
  switch ($Type)
  {
    'File' { $params.Add("File", $true) }
    'Directory' { $params.Add("Directory", $true) }
  }

  Get-ChildItem @params
}