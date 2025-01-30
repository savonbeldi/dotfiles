# source: https://gist.github.com/bsdayo/7ae3aaa41c80c1f7d2eade76854ea035

# Add this snippet to your $PROFILE to make Bash's autocompletion available to PowerShell on Linux.
# Warning: adds ~500ms initialization time.
# References: https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
#             https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter

# Find all commands
$commands = bash -c 'source /usr/share/bash-completion/bash_completion && complete' | awk '{ print $NF }'
$commands += ls /usr/share/bash-completion/completions

$commands | ForEach-Object {
  $command = $_

  Register-ArgumentCompleter -CommandName $command -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $line = $commandAst.Extent.Text
    $words = $line -split '\s+'
    $wordIndex = $words.IndexOf($wordToComplete)
    
    # Bash script to get completions
    $script = @"
source /usr/share/bash-completion/bash_completion

record=`$(complete -p $command 2> /dev/null)
if [ `$? -ne 0 ]; then
    _completion_loader $command
    record=`$(complete -p $command 2> /dev/null)
fi

if (echo `$record | grep -- -F) &> /dev/null; then
    func=`$(echo `$record | awk '{ print `$(NF-1) }')

    COMP_WORDS=('$($words -replace "'","'\''" -join "' '")')
    COMP_CWORD=$($wordIndex -ge 0 ? $wordIndex : $words.Length)
    COMP_LINE='$($line -replace "'","'\''")'
    COMP_POINT=$cursorPosition
    COMPREPLY=()
    "`$func" $command

    echo `${COMPREPLY[@]}
else
    eval "`$(echo `${record/complete/compgen} | awk '{ NF--; print `$0 }')" $wordToComplete
fi
"@
    return $(bash -c $script) -split ' ' | Sort-Object
  }.GetNewClosure() # Important, otherwise the script block will not capture variables ($command) in each loop
}