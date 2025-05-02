#!/usr/bin/env pwsh
# windows-healer.ps1 - Heal common dotfiles/chezmoi issues on Windows

. "$PSScriptRoot/functions.ps1"

Write-Host "[Healer] Starting dotfiles healing process..." -ForegroundColor Cyan

# 1. Ensure chezmoi is installed
$chezmoiPath = "$PSScriptRoot\..\bin\chezmoi.exe"
if (-not (Test-Path $chezmoiPath)) {
    Write-Host "[Healer] chezmoi.exe not found. Run setup-chezmoi.ps1 first!" -ForegroundColor Red
} else {
    Write-Host "[Healer] chezmoi.exe found." -ForegroundColor Green
}

# 2. Ensure PowerShell profile is symlinked
$profilePath = $PROFILE
$dotfilesProfile = "$PSScriptRoot\..\config\powershell\user_profile.ps1"
if ((Test-Path $profilePath) -and ((Get-Item $profilePath).LinkType -eq 'SymbolicLink')) {
    Write-Host "[Healer] PowerShell profile is symlinked." -ForegroundColor Green
} else {
    Write-Host "[Healer] Symlinking PowerShell profile..." -ForegroundColor Yellow
    if (Test-Path $profilePath) { Remove-Item $profilePath -Force }
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir }
    Create-SymLink -SourcePath $dotfilesProfile -DestPath $profilePath
}

# 3. Set execution policy
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -ne 'RemoteSigned') {
    Write-Host "[Healer] Setting execution policy to RemoteSigned..." -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
} else {
    Write-Host "[Healer] Execution policy is RemoteSigned." -ForegroundColor Green
}

# 4. Unblock all scripts in dotfiles
Write-Host "[Healer] Unblocking all .ps1 scripts in dotfiles..." -ForegroundColor Yellow
Get-ChildItem -Path "$PSScriptRoot\.." -Recurse -Filter *.ps1 | Unblock-File

Write-Host "[Healer] Healing complete! Restart PowerShell to apply all changes." -ForegroundColor Cyan 