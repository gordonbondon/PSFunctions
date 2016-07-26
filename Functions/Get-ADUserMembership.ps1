function Get-ADUserMembership {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [String]
        $SamAccountName
    )

    Begin {
        $result = @()
    }    
    
    Process {
        
            #dsquery returns last additional empty string, remove it
            $groups = dsquery user -samid $Samaccountname | dsget user -memberof | select -Skip 1 -Last 1000
            #Remove quotations
            $groups = $groups | % {$_ -replace '"', ""}
            foreach ($group in $groups)
            {
                $group = Get-ADGroup -Filter * -SearchBase $group | select SamAccountName, distinguishedName
                $result+= $group
            } 
        
    }

    End {
        $result | sort SamAccountName
    }
}