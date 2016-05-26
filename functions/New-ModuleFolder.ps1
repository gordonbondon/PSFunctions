<#
.SYNOPSIS
Creates function file from template.

.DESCRIPTION
Creates function file from templates. Popultates it with comment based help and basic function structure

.PARAMETER FUNCTIONNAME
FunctionName will be used to name a file and function itself

.PARAMETER PATH
Path where new file will be created

.EXAMPLE
New-FunctionFile -FunctionName Get-File -Path D:\Scripts

This will create new function file using ..\templates\New-FunctionFile.template\##FunctionName##.ps1.template and place it to D:\Scripts

#>
function New-FunctionFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if ((Get-Verb -verb $_.Split('-')[0]) -ne $null) {
                $true
            }
            else {
                throw "$_ uses not a valid Verb. Find a valid verb with Get-Verb and use it"
            }
        })]
        [string]$FunctionName,
        [ValidateScript({Test-Path $_})]
        [string]$Path = $pwd      
    )

    #get template file
    $templatefolder = (Get-Item $PSScriptRoot).Parent.FullName + '\templates'
    $template = Get-Item -Path "$templatefolder\New-FunctionFile.template\##FunctionName##.ps1.template"

    #copy template to destination path
    Copy-Item -Path $template.FullName -Destination $Path

    #capitalize function name and rename copied tamplate
    $TextInfo = (Get-Culture).TextInfo
    $FunctionName = $TextInfo.ToTitleCase($FunctionName)
    $functionfile = Rename-Item -Path ("$Path" + "\$($template.Name)") -NewName $template.Name.Replace('##FunctionName##', "$FunctionName").Replace('.template', '') -PassThru
    (Get-Content $functionfile).Replace('##FunctionName##', "$FunctionName") | Set-Content -Path $functionfile
        
}