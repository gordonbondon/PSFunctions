
#
# .SYNOPSIS
#
#    Complete the -Name argument for VpnClient cmdlets
#
function VPNNameCompleter {
        param (
            $commandName, 
            $parameterName, 
            $wordToComplete, 
            $commandAst, 
            $fakeBoundParameter
        )

        Get-VpnConnection | Where-Object { $_.Name -like "$wordToComplete*" } | 
            ForEach-Object {
                New-CompletionResult -CompletionText $_.Name -ToolTip $_.Description
            }
    }

Register-ArgumentCompleter -CommandName ( 'Get-VpnConnection', 'Remove-VpnConnection', 'Set-VpnConnection' ) `
                           -ParameterName Name `
                           -ScriptBlock $function:VPNNameCompleter `
                           -Description 'Completes VpnConnection Name'
