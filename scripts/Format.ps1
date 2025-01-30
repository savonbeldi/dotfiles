# TODO: WIP

if ((Get-Module -ListAvailable -Name PSScriptAnalyzer))
{
  Import-Module PSScriptAnalyzer -ErrorAction Stop
}
else
{
  Write-Error "PSScriptAnalyzer is not installed"

  Write-Host "Installing PSScriptAnalyzer"
  Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
}

Write-Host "`nFormatting scripts..."
Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\.scriptanalyzer.psd1