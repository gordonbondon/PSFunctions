function Get-ADUserMembership {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [String[]]$SamAccountName
    )
    Begin {
        $result = @()    
    }    
    
    Process {
        foreach ($user in $SamAccountName) {
            #dsquery returns last additional empty string, remove it
            $groups = dsquery user -samid $user | dsget user -memberof | select -Skip 1 -Last 1000
            #Remove quotations
            $groups = $groups | % {$_ -replace '"', ""}
            foreach ($group in $groups)
            {
                Get-ADGroup -Filter * -SearchBase $group | select SamAccountName, distinguishedName
            }
        }
    }
}