# source: https://github.com/aaronpowell/ps-nvm

if ((Get-Module -ListAvailable -Name nvm))
{
  Import-Module nvm -ErrorAction Continue
  Set-NodeVersion
}
else
{
  Write-Host "[WARN] nvm is not installed" -ForegroundColor Yellow
}