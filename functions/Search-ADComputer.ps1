#stolen from here https://gist.github.com/anonymous/41c983754cfd18df8f6b via https://www.reddit.com/user/Taylor_Script
function Search-ADComputer {
    param(
        [String]$SearchString
    )

    $Match = Get-ADComputer -Filter "samaccountname -like '*$($SearchString)*' -or name -like '*$($SearchString)*'"

    if($Match -eq $null) {
        # Nothing was found
        Write-Error "No matching accounts were found."
    } else {
        $Match
    }
}