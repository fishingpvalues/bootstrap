#!/usr/bin/env pwsh
# Script to update and repatch Oh My Posh for PowerShell
# This script handles both installation and updates

# Stop on errors
$ErrorActionPreference = "Stop"

# Import chezmoi data for configuration
$chezmoiData = chezmoi data --format json | ConvertFrom-Json

function Update-OhMyPosh {
    Write-Host "Updating Oh My Posh..."
    
    # Check if winget is available (preferred method)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Using winget to update Oh My Posh..."
        winget upgrade JanDeDobbeleer.OhMyPosh -s winget
    }
    # Fallback to scoop if available
    elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Using scoop to update Oh My Posh..."
        scoop update oh-my-posh
    }
    else {
        # Manual installation/update using the official installer
        Write-Host "Using the official installer to update Oh My Posh..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-WebRequest -Uri 'https://ohmyposh.dev/install.ps1' | Invoke-Expression
    }
    
    # Verify installation
    $ohMyPoshVersion = (oh-my-posh version) 2>&1
    Write-Host "Oh My Posh version: $ohMyPoshVersion"
}

function Update-PowerShellProfile {
    Write-Host "Updating PowerShell profile..."
    
    # Define profile paths
    $profilePaths = @(
        $PROFILE.CurrentUserCurrentHost,  # Current user, current host
        $PROFILE.CurrentUserAllHosts,     # Current user, all hosts
        $PROFILE.AllUsersCurrentHost,     # All users, current host
        $PROFILE.AllUsersAllHosts        # All users, all hosts
    )
    
    # Ensure profile directory exists
    $profileDir = Split-Path -Parent $PROFILE.CurrentUserCurrentHost
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    # Check each profile path
    foreach ($profilePath in $profilePaths) {
        if (Test-Path $profilePath) {
            Write-Host "Found profile at: $profilePath"
            
            # Backup existing profile
            $backupPath = "${profilePath}.backup"
            Copy-Item -Path $profilePath -Destination $backupPath -Force
            Write-Host "Created backup at: $backupPath"
            
            # Update Oh My Posh initialization in profile
            $profileContent = Get-Content -Path $profilePath -Raw
            
            # Remove existing Oh My Posh initialization
            $profileContent = $profileContent -replace "(?ms)# Oh My Posh configuration.*?oh-my-posh init.*?\n", ""
            
            # Add new Oh My Posh initialization
            $newInit = @"

# Oh My Posh configuration
`$env:POSH_GIT_ENABLED = `$true
oh-my-posh init pwsh --config "$($chezmoiData.color_scheme).omp.json" | Invoke-Expression

"@
            $profileContent = $profileContent + $newInit
            
            # Save updated profile
            $profileContent | Set-Content -Path $profilePath -Force
            Write-Host "Updated profile at: $profilePath"
        }
    }
}

function Install-Theme {
    Write-Host "Installing Oh My Posh theme..."
    
    # Get theme name from chezmoi data or use default
    $themeName = if ($chezmoiData.color_scheme) { $chezmoiData.color_scheme } else { "catppuccin-mocha" }
    
    # Define theme paths
    $themePaths = @(
        "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",  # Windows default
        "$HOME/.poshthemes",                             # Unix-like systems
        "$HOME/.config/oh-my-posh/themes"                # Alternative Unix-like location
    )
    
    # Find existing theme directory
    $themeDir = $themePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if (-not $themeDir) {
        # Create default theme directory if none exists
        $themeDir = $themePaths[0]
        New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
    }
    
    # Download theme if it doesn't exist
    $themePath = Join-Path $themeDir "$themeName.omp.json"
    if (-not (Test-Path $themePath)) {
        Write-Host "Downloading theme: $themeName"
        $themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$themeName.omp.json"
        Invoke-WebRequest -Uri $themeUrl -OutFile $themePath
    }
    
    Write-Host "Theme installed at: $themePath"
}

function Test-OhMyPosh {
    Write-Host "Testing Oh My Posh configuration..."
    
    try {
        # Test Oh My Posh command
        $null = oh-my-posh --version
        
        # Test theme rendering
        $null = oh-my-posh print primary --config "$($chezmoiData.color_scheme).omp.json"
        
        Write-Host "Oh My Posh is working correctly!"
        return $true
    }
    catch {
        Write-Warning "Oh My Posh test failed: $_"
        return $false
    }
}

# Main execution
try {
    Write-Host "Starting Oh My Posh update process..."
    
    # Update Oh My Posh
    Update-OhMyPosh
    
    # Install/Update theme
    Install-Theme
    
    # Update PowerShell profile
    Update-PowerShellProfile
    
    # Test configuration
    if (Test-OhMyPosh) {
        Write-Host "`nOh My Posh has been successfully updated and configured!"
        Write-Host "Please restart your PowerShell session for changes to take effect."
    } else {
        Write-Warning "`nOh My Posh update completed with warnings. Please check the output above."
    }
    
} catch {
    Write-Error "An error occurred during the update process: $_"
    exit 1
} 