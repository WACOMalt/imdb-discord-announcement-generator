# Release script for Discord Movie Announcement Generator
# This script creates a versioned release package

param(
    [string]$Version = "1.0.1"
)

Write-Host "Creating release package v$Version..." -ForegroundColor Green

# Ensure directories exist
if (!(Test-Path "releases")) {
    New-Item -ItemType Directory -Path "releases" | Out-Null
}

# Check if build exists
if (!(Test-Path "build/MovieAnnouncementGenerator.exe")) {
    Write-Host "❌ Build not found. Run .\build.ps1 first." -ForegroundColor Red
    exit 1
}

# Create release directory structure
$releaseDir = "releases/v$Version"
if (Test-Path $releaseDir) {
    Remove-Item $releaseDir -Recurse -Force
}
New-Item -ItemType Directory -Path $releaseDir | Out-Null

# Copy files to release directory
Copy-Item "build/MovieAnnouncementGenerator.exe" "$releaseDir/"
Copy-Item "README.md" "$releaseDir/"

# Create versioned zip file
$zipFile = "releases/MovieAnnouncementGenerator-v$Version.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Compress-Archive -Path "$releaseDir/*" -DestinationPath $zipFile -CompressionLevel Optimal

Write-Host "✅ Release package created!" -ForegroundColor Green
Write-Host "📁 Release directory: $releaseDir" -ForegroundColor Cyan
Write-Host "📦 Zip file: $zipFile" -ForegroundColor Cyan

# Show file info
$zip = Get-Item $zipFile
Write-Host "📊 Package size: $([math]::Round($zip.Length / 1KB, 2)) KB" -ForegroundColor Gray
Write-Host "📅 Created: $($zip.LastWriteTime)" -ForegroundColor Gray

Write-Host ""
Write-Host "Files in release package:" -ForegroundColor Yellow
Get-ChildItem $releaseDir | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}
