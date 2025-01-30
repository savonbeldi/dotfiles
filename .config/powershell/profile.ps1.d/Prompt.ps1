# Prompt

Write-Host "Hello Prompt!" -ForegroundColor Blue

# UI
Invoke-Expression (&starship init powershell)

# Keyboard shortcuts
## Enable bash-like completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

## Enable predictive IntelliSense
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

## Enable history search with arrow keys
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

## Enable ctrl+arrow functionality
# Set-PSReadLineOption -EditMode Windows # Not needed anymore
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function NextWord
