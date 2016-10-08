$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

Write-Verbose "Importing Functions"
"$moduleRoot\functions\*.ps1" | Resolve-Path | ForEach { . $_.ProviderPath; Write-Verbose $_.ProviderPath }

Export-ModuleMember -Function * -Alias *
