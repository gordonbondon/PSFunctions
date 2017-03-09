<#
.SYNOPSIS
Syncs GitHubFork with it's upstream

.DESCRIPTION
Detects if local repo is a fork. Receives upstream from github API and
performs commands form https://help.github.com/articles/syncing-a-fork/

.PARAMETER Path
Path to repo folder

.EXAMPLE
Sync-GitHubFork

This will sync repo from local path if repo is present and if it is a fork

.NOTES
Inspired by https://github.com/imagentleman/github-sync-fork-script/blob/master/gsync.py

#>
function Sync-GitHubFork {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param ()
    $Path = $PWD.Path

    if (-not (Test-Path "$Path\.git")) {
        throw "$Path does not contain Git repository"
    }

    Write-Verbose 'Getting current repo URL'
    $remote = invokeGit -Commands config, --get, remote.origin.url
    Write-Verbose "Current repo URL is: $remote"

    if ($remote -notlike '*github.com*') {
        throw "$remote is not a GitHub repo"
    }

    #Get repo name and user name from SSH or HTTPS remote
    $repo = $remote.Split(":/.")[-2]
    $user = $remote.Split(":/.")[-3]

    Write-Verbose 'Get GitHub upstream repo'
    $apiuri = "https://api.github.com/repos/{0}/{1}" -f $user, $repo
    try {
        $repoinfo = Invoke-RestMethod -Method Get -Uri $apiuri
    } catch [System.Net.WebException] {
        throw "Error while requesting GitHub API"
    }

    if (-not $repoinfo.parent) {
        throw "$remote is not a fork"
    }

    $upstream = $repoinfo.parent.clone_url
    Write-Verbose "Upstream repo is: $upstream"
    $branch = $repoinfo.parent.default_branch
    Write-Verbose "Default upstream branch is: $branch"

    Write-Verbose "Adding 'upstream' remote $upstream"
    if ($PSCmdlet.ShouldProcess("Adding 'upstream' remote $upstream")) {
        invokeGit -Commands remote, add, upstream, $upstream
    }

    Write-Verbose "Fetching from 'upstream'"
    if ($PSCmdlet.ShouldProcess("Fetching from 'upstream'")) {
        invokeGit -Commands fetch, upstream
    }

    Write-Verbose "Cehckout defaul branch $branch"
    if ($PSCmdlet.ShouldProcess("Cehckout defaul branch $branch")) {
        invokeGit -Commands checkout, $branch
    }

    Write-Verbose "Rebasing $branch branch"
    if ($PSCmdlet.ShouldProcess("Rebasing $branch branch")) {
        invokeGit -Commands rebase, "upstream/$branch"
    }

    Write-Output "Perform 'git push origin $branch --force' after you've fixed all conflicts"
}

function invokeGit {
    param(
        [string[]]
        $Commands = @()
    )

    & git $Commands
}
