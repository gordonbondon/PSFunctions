<#
.SYNOPSIS
Domain name WhoIs

.DESCRIPTION
Performs a domain name lookup and returns information such as
domain availability (creation and expiration date),
domain ownership, name servers, etc..

.PARAMETER Domain
Specifies the domain name (enter the domain name without http:// and www (e.g. power-shell.com))

.EXAMPLE
Get-WhoIs -Domain power-shell.com 
Returns WhoIs information about domain

.NOTES
File Name: whois.ps1
Author: Nikolay Petkov
Link: http://power-shell.com
Last Edit: 12/20/2014

.LINK
https://gallery.technet.microsoft.com/WHOIS-PowerShell-Function-ed69fde6 
#>
Function Get-WhoIs {
param (
        [Parameter(Mandatory=$True, HelpMessage='Please enter domain name')]
        [string]$Domain
        )
        
Write-Output "Connecting to Web Services URL..."

try {
    #Retrieve the data from web service WSDL
    if ($whois = New-WebServiceProxy -uri "http://www.webservicex.net/whois.asmx?WSDL") { Write-Output "Ok" }
    else { Write-Error "Can't connect to http://www.webservicex.net/" }
    Write-Output "Gathering $Domain data..."
    #Return the data
    (($whois.getwhois("=$Domain")).Split("<<<")[0])
} catch {
Write-Output "Please enter valid domain name (e.g. microsoft.com)." -ForegroundColor Red}
} ; New-Alias -Name whois -Value Get-WhoIs
