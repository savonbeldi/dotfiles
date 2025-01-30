# source: https://github.com/dahlbyk/posh-git

if ((Get-Module -ListAvailable -Name posh-git))
{
  Import-Module posh-git -ErrorAction Continue
  $GitPromptSettings.EnablePromptStatus = $false
}
else
{
  Write-Host "[WARN] posh-git is not installed" -ForegroundColor Yellow
}