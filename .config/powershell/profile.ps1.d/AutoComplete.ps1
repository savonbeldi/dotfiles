# Auto complete

Write-Host "Hello AutoComplete!" -ForegroundColor Green

## Load auto completions
$configs = Get-ChildItem -File -Filter *.ps1 -Path $(Join-Path $PSScriptRoot autocomplete)
$configs | ForEach-Object { . $_.FullName }