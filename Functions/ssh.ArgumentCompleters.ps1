
#
# .SYNOPSIS
#
#    Complete hosts from powershell hisotry for SSH
#
function sshCompletion {
    param ( 
        $wordToComplete, 
        $commandAst
    )

    (Search-History ssh).Where{$_ -match "^ssh [a-zA-Z0-9].*?$" -and $_ -like "*$wordToComplete*"} | 
        Select-Object -Unique | Sort-Object | ForEach-Object { New-CompletionResult -CompletionText $_.Replace('ssh ','')}
}

TabExpansionPlusPlus\Register-ArgumentCompleter -CommandName 'ssh' -Native -Description 'Complete ssh host names' -ScriptBlock $function:sshCompletion