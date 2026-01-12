# GitHub Secrets Setup Script for PrivatePDF
# This script sets up Vercel deployment secrets for GitHub Actions

Write-Host "=== GitHub Secrets Setup for PrivatePDF ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Step 1: Create a Vercel Token" -ForegroundColor Yellow
Write-Host "  1. Visit: https://vercel.com/account/tokens"
Write-Host "  2. Click Create Token"
Write-Host "  3. Name: GitHub Actions CI/CD"
Write-Host "  4. Scope: Full Account"
Write-Host "  5. Click Create and copy the token"
Write-Host ""

# Prompt for Vercel token
$VERCEL_TOKEN = Read-Host "Paste your Vercel token here"

if ([string]::IsNullOrWhiteSpace($VERCEL_TOKEN)) {
    Write-Host "Error: No token provided!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Setting GitHub Secrets..." -ForegroundColor Yellow

$VERCEL_ORG_ID = "team_KZboy51Dn2pe1TrlwyoP2AW7"
$VERCEL_PROJECT_ID = "prj_wig57kQnh2ngs0Dy7An324JYYQYQ"
$GH_PATH = "C:\Program Files\GitHub CLI\gh.exe"

# Set VERCEL_TOKEN
Write-Host "  Setting VERCEL_TOKEN..." -NoNewline
$VERCEL_TOKEN | & $GH_PATH secret set VERCEL_TOKEN
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    exit 1
}

# Set VERCEL_ORG_ID
Write-Host "  Setting VERCEL_ORG_ID..." -NoNewline
$VERCEL_ORG_ID | & $GH_PATH secret set VERCEL_ORG_ID
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    exit 1
}

# Set VERCEL_PROJECT_ID
Write-Host "  Setting VERCEL_PROJECT_ID..." -NoNewline
$VERCEL_PROJECT_ID | & $GH_PATH secret set VERCEL_PROJECT_ID
if ($LASTEXITCODE -eq 0) {
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Verifying secrets..." -ForegroundColor Yellow
& $GH_PATH secret list

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host "All GitHub secrets have been configured successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Make a code change and commit it"
Write-Host "  2. Push to main branch: git push"
Write-Host "  3. GitHub Actions will automatically build and deploy to Vercel"
Write-Host ""
