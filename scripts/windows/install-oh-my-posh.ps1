# Oh My Posh Installation Script for Windows
# This script installs Oh My Posh and sets up the GitHub Dark theme

# Update the dotfiles directory path to point to the parent of scripts/windows
$DOTFILES_DIR = (Get-Item $PSScriptRoot).Parent.Parent.FullName

# Define the Oh My Posh theme directory
$OhMyPoshDir = "$env:USERPROFILE\.config\oh-my-posh"
$PowerShellConfigDir = "$env:USERPROFILE\.config\powershell"

# Check if Oh My Posh is already installed
Write-Host "Checking if Oh My Posh is installed..."
$ohMyPoshInstalled = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if (-not $ohMyPoshInstalled) {
    Write-Host "Oh My Posh not found. Installing..." -ForegroundColor Yellow

    # Install Oh My Posh using winget if available
    $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    
    if ($wingetInstalled) {
        Write-Host "Installing Oh My Posh using winget..."
        winget install JanDeDobbeleer.OhMyPosh -s winget
    } else {
        # Alternative installation method using the installer script
        Write-Host "Installing Oh My Posh using the installer script..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-WebRequest https://ohmyposh.dev/install.ps1 -UseBasicParsing | Invoke-Expression
    }
    
    # Verify installation
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to install Oh My Posh. Please install it manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Oh My Posh is already installed." -ForegroundColor Green
}

# Ensure directories exist
Write-Host "Creating Oh My Posh theme directory..."
New-Item -ItemType Directory -Force -Path $OhMyPoshDir | Out-Null
New-Item -ItemType Directory -Force -Path $PowerShellConfigDir | Out-Null

# Copy GitHub Dark theme to the Oh My Posh directory
Write-Host "Copying GitHub Dark theme for Oh My Posh..."
$SourceTheme = Join-Path $DOTFILES_DIR "config\powershell\github-dark.omp.json"
$DestTheme = Join-Path $OhMyPoshDir "github-dark.omp.json"

if (Test-Path $SourceTheme) {
    Copy-Item -Path $SourceTheme -Destination $DestTheme -Force
    Write-Host "GitHub Dark theme copied successfully!" -ForegroundColor Green
} else {
    Write-Host "GitHub Dark theme file not found at $SourceTheme" -ForegroundColor Red
    exit 1
}

# Set the current theme as the GitHub Dark theme
$CurrentTheme = Join-Path $OhMyPoshDir "current-theme.omp.json"
Copy-Item -Path $DestTheme -Destination $CurrentTheme -Force

# Install recommended fonts for Oh My Posh
Write-Host "Would you like to install the FiraCode Nerd Font? (y/N)" -ForegroundColor Yellow
$installFonts = Read-Host

if ($installFonts -eq "y" -or $installFonts -eq "Y") {
    # Check if scoop is installed
    $scoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue
    
    if ($scoopInstalled) {
        Write-Host "Installing FiraCode Nerd Font using Scoop..."
        scoop bucket add nerd-fonts
        scoop install FiraCode-NF
    } else {
        # Manual font installation
        Write-Host "Downloading FiraCode Nerd Font..."
        $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"
        $fontZip = "$env:TEMP\FiraCode.zip"
        $fontExtractPath = "$env:TEMP\FiraCode"
        
        # Download and extract font
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
        Expand-Archive -Path $fontZip -DestinationPath $fontExtractPath -Force
        
        Write-Host "Installing fonts... (requires admin privileges)"
        $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
        
        foreach ($fontFile in Get-ChildItem -Path "$fontExtractPath\*" -Include "*.ttf", "*.otf") {
            Write-Host "Installing font: $($fontFile.Name)"
            $fonts.CopyHere($fontFile.FullName)
        }
        
        # Cleanup
        Remove-Item $fontZip -Force
        Remove-Item $fontExtractPath -Force -Recurse
    }
    
    Write-Host "Fonts installed!" -ForegroundColor Green
} else {
    Write-Host "Skipping font installation. Please ensure you have a Nerd Font installed for optimal experience." -ForegroundColor Yellow
}

Write-Host "Oh My Posh setup complete with GitHub Dark theme!" -ForegroundColor Green
Write-Host "Note: You may need to restart your terminal for changes to take effect." -ForegroundColor Yellow