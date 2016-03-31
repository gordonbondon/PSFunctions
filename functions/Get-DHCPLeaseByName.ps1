<#
.SYNOPSIS
Gets DHCP lease IP address by computer name

.DESCRIPTION
Parses DHCP database to get DHCP lease IP address by Computer name

.PARAMETER Name
Specify Computer name

#>

function Get-DHCPLeaseByName {
    [CmdletBinding()]
    param (
         [string]
         $Name,
         [System.Management.Automation.CredentialAttribute()]
         $Credential
    )

    #Find first DHCP server
    $ipaddress = Get-NetIPAddress -InterfaceAlias 'Ethernet' -AddressFamily 'IPv4' | select IPAddress
    $net = ($ipaddress.IPAddress.Split(".", 3) | select -Index 0,1) -join "."

    $server = netsh dhcp show server | Select-String $net | ForEach-Object {$_ -split " "} | Select-Object -Index 1
    $server = $server -replace "\[", '' -replace "\]", ''
    #Open simsession to dhcpserver because DHCP server cmdlets dose not support Credentail parameter
    try {
        $session = New-CimSession -ComputerName $server -Credential $Credential -ErrorAction Stop
    } catch [Microsoft.Management.Infrastructure.CimException] {
        throw "Access is denied. Use DHCP Admin credentials"
    }
    #Find scopes for this DHCP server
    $scopes = Get-DhcpServerv4Scope -CimSession $session
    #For each scope parse DHCP leases and find matching Name
    foreach ($scope in $scopes) {
        Get-DhcpServerv4Lease -CimSession $session -ScopeId $scope.ScopeId | where {$_.HostName -match $Name} | select HostName, IPAddress, AddressState, LeaseExpiryTime
    }
    Remove-CimSession $session
}; New-Alias -Name lease -Value Get-DHCPLeaseByname