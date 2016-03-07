#Function to search throught history
function Search-History {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Regex,
        [Parameter(Mandatory=$false)]
        [switch]$Full
    )
    $commands = Get-History -Count $MaximumHistoryCount |?{$_.commandline -match $regex}
    if ($full) {
        $commands |ft *
    }
    else {
        foreach ($command in ($commands | select -ExpandProperty commandline)) {
            # This ensures that only the first line is shown of a multiline command
            # You can always get the full command using get-history or you can fork and remove this from the gist
            if ($command -match '\r\n') {
                ($command -split '\r\n')[0] + " ..."
            }
            else {
                $command
            }
        }
    }
} ; New-Alias -Name hgrep -Value Search-History