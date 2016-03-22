<#
.SYNOPSIS
Deletes DNS records by owner

.DESCRIPTION
Searches for non static DNS records from selected zone and scope.
Makes a lookup in DC=levi9.com,CN=MicrosoftDNS,DC=DomainDnsZones,DC=levi9,DC=com to find matching items.
Gets ACL for this records and if record is owned by itself or by provided Owner deletes corresponding DNS record.

This cmdlet is usefull when you've changed DHCP server configuration and dynamic DNS updates fail because records are owned by wrong accounts.

.PARAMETER ZoneName
Specify zone name

.PARAMETER ZoneScope
Specify part of your scope. Like '10.100.'

.PARAMETER Owner
Specify Owner name you want to delete. Like 'Administrator'

.PARAMETER Self
Set true or false to set if you want to delete self owned records or not.

.EXAMPLE
Remove-DNSRecordByOwner -ZoneName 'zone.com' -ZoneScope '10.100.' -Owner 'Administrator' -Self $false
Deletes records from zone.com zone and 10.100. scope that are owned by Administrator account, but not self owned.
#>

function Remove-DNSRecordByOwner {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$ZoneName,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$ZoneScope,
        [Parameter(Position=2, ParameterSetName="Owner")]
        [string]$Owner,
        [Parameter(Position=3, Mandatory=$false, ParameterSetName="Owner")]
        [Parameter(Position=2, Mandatory=$true, ParameterSetName="Self")]
        [bool]$Self
    )
    #prerequisites
    Import-Module -Name ActiveDirectory

    #find all records from defined scope
    $records = Get-DnsServerResourceRecord -ZoneName $ZoneName | Where-Object {$_.RecordData.IPv4Address -like "$ZoneScope*" -and $_.Timestamp -gt (Get-Date 0).Date}
    #define path for micorosftdns records
    $path = "AD:\DC=levi9.com,CN=MicrosoftDNS,DC=DomainDnsZones,DC=levi9,DC=com"

    foreach ($record in $records){
        $item = Get-ChildItem -Path $path | ?{$_.Name -like "$($record.HostName)"}
        $itemowner = (Get-Acl -Path "ActiveDirectory:://RootDSE/$($item.DistinguishedName)").Owner

        if ($Self -and $itemowner -like "*$($record.HostName)*"){
            $match = $true
        }
        if ($itemowner -like "*$Owner*"){
            $match = $true
        }

        #delete record if Owner or Self matches
        if ($match){
            Write-Verbose "Removing record: $($record.HostName). Owner : $itemowner" + "`n"
            Remove-DnsServerResourceRecord -ZoneName $ZoneName -RRType A -Name $record.HostName -Force
        }

        #reset match
        $match = $false
    }
}