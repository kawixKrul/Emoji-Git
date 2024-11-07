Import-Module PWSHEmojiExplorer

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-GitBranch {
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) {
            Write-Output "($branch)...> "
        }
    }
    catch {
        Write-Output ""
    }
}

function Get-MyGitStats {
    param(
        [string]$Author = "name@email.com" 
    )

    $insertions = 0
    $deletions = 0

    git log --author="$Author" --pretty=format:"%H" | ForEach-Object {
        $commitHash = $_
        $output = git show --stat $commitHash

        Write-Output "For commit hash: $commitHash"
        foreach ($line in $output) {
            if ($line -match "(\d+)\s+insertions?") {
                Write-Output $Matches.0
                $insertions += $Matches.1
            }
            if ($line -match "(\d+)\s+deletions?") {
                Write-Output $Matches.0
                $deletions += $Matches.1
            }
        }
    }

    Write-Host "Total Insertions: $insertions"
    Write-Host "Total Deletions: $deletions"
}

function Git-NewBranch {
    param (
        [string]$Name
    )
    if (-not $Name) {
        Write-Host "Did not provided branch name, aborting ... "
        return
    }

    $emoji_branch = Add-EmojiToText -Text $Name -Replace
    $emoji_branch = $emoji_branch -replace ' ', '-'
    Write-Host "Generated branch name: $emoji_branch"
    
    $confirmation = Read-Host "Do you want to proceed with this branch name? (Y/N)"
    if ($confirmation -eq 'Y') {
        git checkout -b $emoji_branch
        Write-Host "Branch creation successful!"
    }
    else {
        Write-Host "Branch creation aborted."
    }
}

function Git-Commit {
    param (
        [string]$Message,
        [string]$Emoji,
        [switch]$Personal
    )
    if (-not $Message) {
        Write-Host "Did not provided commit message, aborting ... "
        return
    }

    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if (-not $branch) {
        Write-Output "Did not find git branch, aborting ... "
    }

    $commit_msg = ""
    if (-not $Personal) {
        $n = 7
        $commit_msg = $branch.Substring(0, $n) 
    }
    
    if ($Emoji) {
        $commit_msg += " $Emoji "
    } else {
        # your default emojis
        $location = Get-Location
        if ($location.Path.Contains("ProjectName")) {
            $commit_msg += " 📈 "
        }
        else {
            $commit_msg += " 🔥 "
        }
    }
    
    $commit_msg += $Message
    $emoji_commit = Add-EmojiToText -Text $commit_msg -Replace

    Write-Host "Generated commit message: $emoji_commit"
    
    $confirmation = Read-Host "Do you want to proceed with this commit message? (Y/N)"
    if ($confirmation -eq 'Y') {
        git commit -m $emoji_commit
        Write-Host "Commit successful!"
    }
    else {
        Write-Host "Commit aborted."
    }
}

function prompt {
    $GitBranch = Get-GitBranch
    "$env:USERNAME $pwd $GitBranch "
}
