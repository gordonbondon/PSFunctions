<#
.SYNOPSIS
Gets DHCP lease IP address by computer name

.DESCRIPTION
Parses DHCP database to get DHCP lease IP address by Computer name

.PARAMETER Name
Specify Computer name

.PARAMETER MAC
MAc address of a computer to find

.PARAMETER Server
Set dchp server address.
If not set function will try to detect your dhcp server

.PARAMETER Credential
Provide creadentials of DHCP admin

#>

function Get-DHCPLeaseByName {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param (
         [Parameter(Mandatory=$true,Position=0,ParameterSetName='Name')]
         [string]
         $Name,

         [Parameter(Mandatory=$true,Position=0,ParameterSetName='MAC')]
         [string]
         $MAC,

         [Parameter(Mandatory=$false,Position=2,ParameterSetName='Name')]
         [Parameter(Mandatory=$false,Position=2,ParameterSetName='MAC')]
         [string]
         $Server,

         [Parameter(Mandatory=$true,Position=1,ParameterSetName='Name')]
         [Parameter(Mandatory=$true,Position=1,ParameterSetName='MAC')]
         [PSCredential]
         [System.Management.Automation.CredentialAttribute()]
         $Credential
    )

    #Find first DHCP server
    $ipaddress = Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily 'IPv4' | Select-Object IPAddress
    $net = ($ipaddress.IPAddress.Split(".", 3) | Select-Object -Index 0,1) -join "."

    if(!($Server)) {
        $server = netsh dhcp show server | Select-String $net | ForEach-Object {$_ -split " "} | Select-Object -Index 1
        $server = $server -replace "\[", '' -replace "\]", ''
    }

    #Open simsession to dhcpserver because DHCP server cmdlets dose not support Credentail parameter
    try {
        $session = New-CimSession -ComputerName $server -Credential $Credential -ErrorAction Stop
    } catch [Microsoft.Management.Infrastructure.CimException] {
        throw "Access is denied. Use DHCP Admin credentials"
    }

    #Find scopes for this DHCP server
    $scopes = Get-DhcpServerv4Scope -CimSession $session
    #For each scope parse DHCP leases and find matching Name
    switch ($PSCmdlet.ParameterSetName) {
        'Name' {
            foreach ($scope in $scopes) {
                Get-DhcpServerv4Lease -CimSession $session -ScopeId $scope.ScopeId |
                    Where-Object {$_.HostName -match $Name} |
                    Select-Object HostName, IPAddress, ClientId, AddressState, LeaseExpiryTime
            }
        }
        'MAC' {
            foreach ($scope in $scopes) {
                Get-DhcpServerv4Lease -CimSession $session -ScopeId $scope.ScopeId |
                    Where-Object {$_.ClientID -match ($MAC -replace '[^a-zA-Z0-9]','' -replace '(..(?!$))','$1-')} |
                    Select-Object HostName, IPAddress, ClientId, AddressState, LeaseExpiryTime
            }
        }
    }
    Remove-CimSession $session
}; New-Alias -Name lease -Value Get-DHCPLeaseByname