Write-Host "Hello Variables!" -ForegroundColor Cyan

$env:USER_HOME = $env:HOME
$env:ROOT_HOME = Join-Path / root
$env:DOTFILES = Join-Path $env:USER_HOME dotfiles
$env:IsWSL = [bool]$env:WSL_DISTRO_NAME
$env:K9S_LOGS = Join-Path $env:HOME .local state k9s "screen-dumps"

if ($IsWSL)
{
  $currentLocation = $PWD
  Push-Location -Path /mnt/c/Windows/System32
  $env:WIN_HOME = Join-Path / mnt c Users (cmd.exe /c echo %USERNAME%).Trim()
  Push-Location -Path $currentLocation
}