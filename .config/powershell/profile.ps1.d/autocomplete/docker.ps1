# source: https://github.com/matt9ucci/DockerCompletion

if ((Get-Module -ListAvailable -Name DockerCompletion))
{
  Import-Module DockerCompletion -ErrorAction Continue
}
else
{
  Write-ost "[WARN] DockerCompletion is not installed" -ForegroundColor Yellow
}