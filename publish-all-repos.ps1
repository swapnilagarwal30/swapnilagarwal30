# ==============================================================================
# Script: publish-all-repos.ps1
# Author: Swapnil Agarwal
# Purpose: Automatically creates and publishes the 3 featured repositories to GitHub
#          using the authenticated GitHub CLI (gh).
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "PUBLISHING FEATURED DEVSECOPS AND CLOUD REPOSITORIES TO GITHUB" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Verify GitHub CLI authentication
Write-Host "`nChecking GitHub CLI authentication..." -ForegroundColor Yellow
$null = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
}
Write-Host "GitHub CLI is authenticated as swapnilagarwal30.`n" -ForegroundColor Green

$repos = @(
    [PSCustomObject]@{
        Path        = "projects\azure-enterprise-landingzone-tf"
        Name        = "azure-enterprise-landingzone-tf"
        Description = "Production-grade Azure Enterprise Landing Zone and Hub-and-Spoke Topology using Terraform (CAF Compliant)"
    },
    [PSCustomObject]@{
        Path        = "projects\devsecops-shield-pipeline"
        Name        = "devsecops-shield-pipeline"
        Description = "Multi-Stage Shift-Left DevSecOps Continuous Delivery Pipeline with SAST, Infracost and Automated Rollback"
    },
    [PSCustomObject]@{
        Path        = "projects\agentic-aiops-cloud-sentinel"
        Name        = "agentic-aiops-cloud-sentinel"
        Description = "Autonomous Multi-Agent SRE for Real-Time Telemetry RCA and GitOps Self-Healing (Azure Monitor + ArgoCD)"
    }
)

$baseDir = Get-Location

foreach ($repo in $repos) {
    $fullPath = Join-Path $baseDir $repo.Path
    $repoName = $repo.Name
    $desc = $repo.Description

    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Processing repository: $repoName" -ForegroundColor Cyan
    Write-Host "Target directory:      $fullPath" -ForegroundColor DarkGray

    Set-Location $fullPath

    # Check if remote GitHub repository already exists
    $null = gh repo view "swapnilagarwal30/$repoName" 2>&1
    $repoExists = ($LASTEXITCODE -eq 0)

    if (-not (Test-Path ".git")) {
        Write-Host "Initializing local git repository..." -ForegroundColor Yellow
        git init -b main 2>&1 | Out-Null
        git config user.name "Swapnil Agarwal"
        git config user.email "swapnilagarwal94@gmail.com"
        git add . 2>&1 | Out-Null
        git commit -m "feat: initial release of $repoName" 2>&1 | Out-Null
    } else {
        git add . 2>&1 | Out-Null
        git commit -m "feat: update $repoName production architecture" 2>&1 | Out-Null
    }

    if (-not $repoExists) {
        Write-Host "Creating public GitHub repository swapnilagarwal30/$repoName..." -ForegroundColor Yellow
        gh repo create "swapnilagarwal30/$repoName" --public --description "$desc" --source=. --remote=origin --push
        Write-Host "Created and pushed: https://github.com/swapnilagarwal30/$repoName" -ForegroundColor Green
    } else {
        Write-Host "Repository swapnilagarwal30/$repoName already exists on GitHub. Pushing updates..." -ForegroundColor Yellow
        git remote remove origin 2>&1 | Out-Null
        git remote add origin "https://github.com/swapnilagarwal30/$repoName.git"
        git push -u origin main --force
        Write-Host "Updated and pushed: https://github.com/swapnilagarwal30/$repoName" -ForegroundColor Green
    }
}

Set-Location $baseDir

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "ALL 3 REPOSITORIES SUCCESSFULLY PUBLISHED TO GITHUB!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "1. https://github.com/swapnilagarwal30/azure-enterprise-landingzone-tf" -ForegroundColor White
Write-Host "2. https://github.com/swapnilagarwal30/devsecops-shield-pipeline" -ForegroundColor White
Write-Host "3. https://github.com/swapnilagarwal30/agentic-aiops-cloud-sentinel" -ForegroundColor White
Write-Host "============================================================`n" -ForegroundColor Cyan
