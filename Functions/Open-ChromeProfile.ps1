<#
.SYNOPSIS
Open Google Chrome with custom profile

.DESCRIPTION
Helps opening Google Chrome browser with custo m profile by specifying profiles
Name or ID.  

.PARAMETER ProfileName
Open profile by its name. Supports autocomplete in WMF5 or with TabExpansionPlusPlus

.PARAMETER ProfileId
Open profile by its id, eg Default, Profile 1, Profile 2, etc.

.EXAMPLE
PS> Open-ChromeProfile -ProfileId Default

Will open Google Chrome with Default profile

#>
function Open-ChromeProfile {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
        [Parameter(ParameterSetName='Name', Position=0)]
        [ValidateScript({
            if (Get-ChromeProfile -ProfileName $_) {
                $true
            }
            else {
                throw "Profile with name $($_) does not exist"
            }
        })]
        [string]
        $ProfileName,

        [Parameter(ParameterSetName='Id')]
        [ValidateScript({
            if (Get-ChromeProfile -ProfileId $_) {
                $true
            }
            else {
                throw "Profile with Id $($_) does not exist"
            }
        })]
        [string]
        $ProfileId
    )

    $chrome = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(default)'

    # Select only first profile because Chrome allows creating profiles with similar names
    $profile = Get-ChromeProfile @PSBoundParameters | Select-Object -First 1

    $argument = '--profile-directory="' + $profile.Id + '"'

    Start-Process -FilePath $chrome -ArgumentList $argument
}

function Get-ChromeProfile {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
        [Parameter(ParameterSetName='Name', Mandatory=$false, Position=0)]
        [string]
        $ProfileName,

        [Parameter(ParameterSetName='Id', Mandatory=$false, Position=0)]
        [string]
        $ProfileId
    )

    # Get profile list from Chromes local state
    $statePath = "C:\Users\${env:USERNAME}\AppData\Local\Google\Chrome\User Data\Local State"
    $state = Get-Content $statePath

    # Using Serializer instead of ConvertFrom-Json because https://github.com/PowerShell/PowerShell/issues/1755
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
    $jsser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $jsser.MaxJsonLength = $jsser.MaxJsonLength * 10

    $serProfiles = $jsser.DeserializeObject($state).profile.info_cache

    $profiles = @()
    $serProfiles.Keys.ForEach{
        $profile = New-Object -TypeName psobject -Property @{
            'Id' = $_
            'Name' = $serProfiles[$_]['shortcut_name']
        }
        $profiles += $profile
    }

    if($PSBoundParameters['ProfileId']) {
        $profiles.Where{$_.Id -like "$ProfileId"}
    }
    elseif ($PSBoundParameters['ProfileName']) {
        $profiles.Where{$_.Name -like "$ProfileName"}
    }
    else {
        $profiles
    }
}

function ChromeProfileCompleter {
        param (
            $commandName, 
            $parameterName, 
            $wordToComplete, 
            $commandAst, 
            $fakeBoundParameter
        )

        Get-ChromeProfile "$wordToComplete*" |
            ForEach-Object {
                New-CompletionResult -CompletionText $_.Name
            }
    }

TabExpansionPlusPlus\Register-ArgumentCompleter -CommandName ( 'Open-ChromeProfile' ) `
                           -ParameterName ProfileName `
                           -ScriptBlock $function:ChromeProfileCompleter `
                           -Description 'Completes Chrome Profile Name'