#helper function
function Show-SubOUs {
    param (
        [Microsoft.ActiveDirectory.Management.ADOrganizationalUnit]
        $OU,

        [int]
        $Indentation
    )

    $count = $Indentation
    Write-Output ($OU.Name + ' - "' + $OU.DistinguishedName + '"' + "`n").PadLeft( ($OU.Name + ' - "' + $OU.DistinguishedName).Length + (4 * $count) )
    $count++
    $subous = Get-ADOrganizationalUnit -Filter * -SearchBase $($OU.DistinguishedName) -SearchScope OneLevel
    if ($subous -ne $null) {
        foreach ($subou in $subous) {
        Show-SubOUs -OU $subou -Indentation $count
        }
    }
}

#main function
function Get-OUs {
<#
.SYNOPSIS
Get sub OUs

.DESCRIPTION
Specify parent OUname and get its sub-OUs Disinguishedname parameters in hierarchial display

.PARAMETER OUName
Specify parent OU name

.EXAMPLE
Get-OUs Kiev
Displays all sub-ous for Kiev OU if there is only one OU with this name
#>
    [CmdletBinding()]
    param (
         [Parameter(Mandatory = $true)]
         [string]$OUName
    )

    #Get parent OU
    $parentou = Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'"

    #Validate parent OU
    if ($parentou -eq $null) {
        throw "No OU matching this name found"
    } elseif (($parentou.gettype()).Name -ne 'ADOrganizationalUnit') {
        throw "More than one OU with this name"
    }

    #Get sub OUs
    Show-SubOUs -OU $parentou -Indentation 1
}; New-Alias -Name gou -Value Get-OUs