<#
.SYNOPSIS
Lists vCenter Sessions.

.DESCRIPTION
Lists all connected vCenter Sessions.

.EXAMPLE
PS C:\> Get-VISession

.EXAMPLE
PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 5 }

.NOTES
Stolen from here http://blogs.vmware.com/PowerCLI/2011/09/list-and-disconnect-vcenter-sessions.html
#>
function Get-VISession {
    $SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
    $AllSessions = @()
    $SessionMgr.SessionList | Foreach {
        $Session = New-Object -TypeName PSObject -Property @{
            Key = $_.Key
            UserName = $_.UserName
            FullName = $_.FullName
            LoginTime = ($_.LoginTime).ToLocalTime()
            LastActiveTime = ($_.LastActiveTime).ToLocalTime()
        }
        if ($_.Key -eq $SessionMgr.CurrentSession.Key) {
            $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Current Session"
        } else {
            $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Idle"
        }
        $Session | Add-Member -MemberType NoteProperty -Name IdleMinutes -Value ([Math]::Round(((Get-Date) - ($_.LastActiveTime).ToLocalTime()).TotalMinutes))
        $AllSessions += $Session
    }
    $AllSessions
}
