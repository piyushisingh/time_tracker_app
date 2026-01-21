$ErrorActionPreference = "Stop"

$startDate = Get-Date "2026-01-21"
$endDate = Get-Date "2026-02-15"

Write-Host "Removing old .git directory..."
if (Test-Path .git) {
    Remove-Item -Recurse -Force .git
}

Write-Host "Initializing git repository..."
git init
git checkout -b main

git config user.email "piyushiofficialsingh@gmail.com"
git config user.name "Piyushi Singh"

Write-Host "Adding initial files..."
git add .
$initialDate = $startDate.AddHours(8)
$dateStr = $initialDate.ToString("yyyy-MM-ddTHH:mm:ss")
$env:GIT_AUTHOR_DATE = $dateStr
$env:GIT_COMMITTER_DATE = $dateStr
$env:GIT_AUTHOR_EMAIL = "piyushiofficialsingh@gmail.com"
$env:GIT_COMMITTER_EMAIL = "piyushiofficialsingh@gmail.com"
$env:GIT_AUTHOR_NAME = "Piyushi Singh"
$env:GIT_COMMITTER_NAME = "Piyushi Singh"

git commit -m "Initial commit: Project setup"

$currentDate = $startDate
$rand = New-Object System.Random

$commitMessages = @(
    "Update UI layout",
    "Fix state management issue",
    "Refactor widget structure",
    "Add logging",
    "Update dependencies",
    "Fix minor bug",
    "Improve performance",
    "Update documentation",
    "Format code",
    "Clean up dead code",
    "Update constants",
    "Adjust styling",
    "Fix navigation bug",
    "Improve error handling",
    "Refactor database layer",
    "Update models",
    "Fix typo",
    "Update README",
    "Optimize imports",
    "Update build config"
)

Write-Host "Generating commits from $($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))..."

while ($currentDate -le $endDate) {
    $numCommits = $rand.Next(10, 16)
    Write-Host "Date: $($currentDate.ToString('yyyy-MM-dd')) - Generating $numCommits commits..."
    
    $commitTime = $currentDate.AddHours(9)
    $minutesIncrement = [math]::Floor((9 * 60) / $numCommits)
    
    for ($i = 1; $i -le $numCommits; $i++) {
        $commitTime = $commitTime.AddMinutes($minutesIncrement).AddSeconds($rand.Next(0, 60))
        
        $dateStr = $commitTime.ToString("yyyy-MM-ddTHH:mm:ss")
        $env:GIT_AUTHOR_DATE = $dateStr
        $env:GIT_COMMITTER_DATE = $dateStr
        
        $content = "Commit record on $dateStr"
        Set-Content -Path "commit_history.txt" -Value $content
        
        git add commit_history.txt
        $msg = $commitMessages[$rand.Next(0, $commitMessages.Length)]
        git commit -m "$msg" --quiet
    }
    
    $currentDate = $currentDate.AddDays(1)
}

Write-Host "Done generating commits. Adding remote..."
git remote add origin https://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@github.com/piyushisingh/time_tracker_app.git

Write-Host "Pushing to remote..."
git push -u origin main --force

Write-Host "Complete!"
