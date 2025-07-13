# Build script for Discord Movie Announcement Generator
# This script compiles the PowerShell script to an EXE using PS2EXE

param(
    [string]$Version = "1.0.1"
)

Write-Host "Building Discord Movie Announcement Generator v$Version..." -ForegroundColor Green

# Ensure build directory exists
if (!(Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" | Out-Null
}

# Compile the PowerShell script to EXE
try {
    ps2exe -inputFile "MovieAnnouncementGenerator.ps1" `
           -outputFile "build/MovieAnnouncementGenerator.exe" `
           -title "Discord Movie Announcement Generator" `
           -description "Generate Discord movie announcements from IMDB data" `
           -company "WACOMalt" `
           -version $Version `
           -copyright "2025" `
           -iconFile $null `
           -noConsole:$false `
           -noOutput:$false `
           -noError:$false `
           -noVisualStyles:$false `
           -requireAdmin:$false `
           -supportOS:$false `
           -virtualize:$false `
           -longPaths:$false

    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host "📁 EXE saved to: build/MovieAnnouncementGenerator.exe" -ForegroundColor Cyan
    
    # Show file info
    $exe = Get-Item "build/MovieAnnouncementGenerator.exe"
    Write-Host "📊 File size: $([math]::Round($exe.Length / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "📅 Built: $($exe.LastWriteTime)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "To create a release package, run:" -ForegroundColor Yellow
Write-Host "  .\release.ps1 -Version `"$Version`"" -ForegroundColor White
