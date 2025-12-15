# Script to create GitHub repository and push code
# Usage: .\create-github-repo.ps1 -RepoName "PlaneSniperAndroid" -GitHubToken "your_token_here" -IsPrivate $false

param(
    [string]$RepoName = "PlaneSniperAndroid",
    [string]$GitHubToken = "",
    [bool]$IsPrivate = $false
)

$username = "usamasaeedmayo786"

if ([string]::IsNullOrEmpty($GitHubToken)) {
    Write-Host "GitHub Personal Access Token not provided." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To create the repository manually:" -ForegroundColor Cyan
    Write-Host "1. Go to https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: $RepoName" -ForegroundColor White
    Write-Host "3. Choose Public or Private" -ForegroundColor White
    Write-Host "4. DO NOT initialize with README, .gitignore, or license" -ForegroundColor White
    Write-Host "5. Click 'Create repository'" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run these commands:" -ForegroundColor Cyan
    Write-Host "  git remote add origin https://github.com/$username/$RepoName.git" -ForegroundColor Green
    Write-Host "  git branch -M main" -ForegroundColor Green
    Write-Host "  git push -u origin main" -ForegroundColor Green
    exit
}

# Create repository using GitHub API
$body = @{
    name = $RepoName
    private = $IsPrivate
    auto_init = $false
} | ConvertTo-Json

$headers = @{
    "Authorization" = "token $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}

try {
    Write-Host "Creating repository '$RepoName' on GitHub..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    
    Write-Host "Repository created successfully!" -ForegroundColor Green
    Write-Host "Repository URL: $($response.html_url)" -ForegroundColor Green
    
    # Add remote and push
    Write-Host ""
    Write-Host "Adding remote and pushing code..." -ForegroundColor Cyan
    
    git remote remove origin 2>$null
    git remote add origin "https://github.com/$username/$RepoName.git"
    git branch -M main
    git push -u origin main
    
    Write-Host ""
    Write-Host "Done! Your code has been pushed to GitHub." -ForegroundColor Green
    Write-Host "Repository: $($response.html_url)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create the repository manually at https://github.com/new" -ForegroundColor Yellow
}

