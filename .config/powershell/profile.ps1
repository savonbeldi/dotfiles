$executionTime = Measure-Command {
  Write-Host "Hello Profile!" -ForegroundColor Magenta

  # Load profile.ps1.d
  $profiles = Get-ChildItem -File -Filter *.ps1 -Path $(Join-Path $env:HOME dotfiles .config powershell profile.ps1.d)
  $profiles | ForEach-Object { . $_.FullName }
}

Write-Host "`nProfile took $($executionTime.TotalMilliseconds)ms to load" -ForegroundColor Gray