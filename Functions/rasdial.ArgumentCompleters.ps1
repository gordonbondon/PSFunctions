#
# .SYNOPSIS
#
#    Complete vpn connection names for rasdial
#
function rasdialCompletion {
    param (
        $wordToComplete,
        $commandAst
    )

    (Get-VpnConnection).Where{$_.Name -like "$wordToComplete*"} |
        ForEach-Object { New-CompletionResult -CompletionText $_.Name }
}

TabExpansionPlusPlus\Register-ArgumentCompleter -CommandName 'rasdial' -Native -Description 'Complete rasdial connections' -ScriptBlock $function:rasdialCompletion