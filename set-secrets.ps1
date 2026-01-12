param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

$VERCEL_ORG_ID = "team_KZboy51Dn2pe1TrlwyoP2AW7"
$VERCEL_PROJECT_ID = "prj_wig57kQnh2ngs0Dy7An324JYYQYQ"
$GH_PATH = "C:\Program Files\GitHub CLI\gh.exe"

Write-Host "Setting GitHub secrets..." -ForegroundColor Cyan

Write-Host "  VERCEL_TOKEN..." -NoNewline
$Token | & $GH_PATH secret set VERCEL_TOKEN
if ($LASTEXITCODE -eq 0) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [FAILED]" -ForegroundColor Red; exit 1 }

Write-Host "  VERCEL_ORG_ID..." -NoNewline
$VERCEL_ORG_ID | & $GH_PATH secret set VERCEL_ORG_ID
if ($LASTEXITCODE -eq 0) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [FAILED]" -ForegroundColor Red; exit 1 }

Write-Host "  VERCEL_PROJECT_ID..." -NoNewline
$VERCEL_PROJECT_ID | & $GH_PATH secret set VERCEL_PROJECT_ID
if ($LASTEXITCODE -eq 0) { Write-Host " [OK]" -ForegroundColor Green } else { Write-Host " [FAILED]" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "Verifying secrets:" -ForegroundColor Yellow
& $GH_PATH secret list

Write-Host ""
Write-Host "Done! Next push to main will auto-deploy to Vercel." -ForegroundColor Green
