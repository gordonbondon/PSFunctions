#helpre function
function _createMenu {
    param (
        [string]$Title,
        [string]$Message,
        [Microsoft.ActiveDirectory.Management.ADComputer[]]$Computers,
        [Microsoft.ActiveDirectory.Management.ADUser]$User,
        [PSCredential]$Credential
    )

    $choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]
    $choicedesc.Add((New-Object -TypeName System.Management.Automation.Host.ChoiceDescription "&Cancel", "Cancle and add user to manual list"))
    $Computers | foreach { $choicedesc.Add((New-Object -TypeName System.Management.Automation.Host.ChoiceDescription "$($_.Name)", "Add $($User.SamAccountName) as ManagedBy to $($_.Name)"))}
    
    $menu = $Host.UI.PromptForChoice($Title, $Message, $choicedesc, 1)

    if ($menu -eq 0) {
        $User.SamAccountName | Out-File -FilePath $FilePath -Append -Encoding utf8
    }
    else {
        Set-ADComputer -Identity $choicedesc[$menu].Label -ManagedBy $User.SamAccountName -Credential $Credential
    }
}
#main function
function Set-ADComputerManagedBy {
<#
.SYNOPSIS
Find computers by username and set user in managedBy field

.DESCRIPTION
Find computers with names matching usernames from specified OU and proposes to set matching user in managedby field of this computer.
If no computer was found and all matches were declined output username to file specified. 

.PARAMETER SearchBase
Specify OU containing users

.PARAMETER FilePath
Specify file path to store usernames

.EXAMPLE
Set-ADComputerManagedBy -SearchBase "OU=Users,DC=domain,DC=com" -FilePath C:\users.txt
#>
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, HelpMessage="Specify OU containing users")]
        [ValidateNotNullOrEmpty()]
        [string]$UsersOU,
        [Parameter(Position=1, Mandatory=$true, HelpMessage="Specify OU containing computers")]
        [ValidateNotNullOrEmpty()]
        [string]$ComputersOU,
        [Parameter(Position=2, Mandatory=$true, HelpMessage="Specify path to file")]
        [string]$FilePath,
        [PSCredential]$Credential
    )

    #create or clean output file
    if (!(Test-Path $FilePath)) {
        New-Item -Path $FilePath -ItemType File
    }
    else {
        Out-File -FilePath $FilePath -Encoding utf8
    }
    #get all users from cepcified OU
    $users = Get-ADUser -Filter * -SearchBase $UsersOU

    foreach ($user in $users)
    {
        #foreach users find PCs with matching name and store to variable
        $match = ($user.SamAccountName).Replace('.', '') + '*'

        $computers = Get-ADComputer -Filter 'Name -like $match'

        #if no PCs found output username to file and to console to be added manually
        if ($computers -eq $null) {
            Write-Output "No PCs with matching $($user.SamAccountname) were found. users was added to manual list"
            Write-Output "Press any button to continue..."
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            $user.SamAccountName | Out-File -FilePath $FilePath -Append -Encoding utf8
        }
        #if one or more PCs found ask to confirm or decline setting user as managedby. If declined output user to manual file
        else {
            _createMenu -Title "Choose computer" -Message "Choose computer to set $($user.SamAccountname) as ManagedBy or Cancel" -Computers $computers -User $user -Credential $Credential
        }        
    }
}