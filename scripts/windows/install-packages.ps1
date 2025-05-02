# Windows package installation script
# Run this script as administrator

# Check if script is running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

# Ensure execution policy allows script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Install Winget if not already installed
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget not found. Installing App Installer from the Microsoft Store..."
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
    Write-Host "Please install App Installer from the Microsoft Store and run this script again."
    exit 1
}

# Install Scoop if not already installed
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop package manager..."
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    
    # Add extra buckets
    scoop bucket add extras
    scoop bucket add nerd-fonts
    scoop bucket add versions
    scoop update
}

# Define packages to install
$wingetPackages = @(
    # Development Tools
    @{Name = "Microsoft.VisualStudioCode"; Source = "winget" },
    @{Name = "Microsoft.PowerShell"; Source = "winget" },
    @{Name = "Microsoft.WindowsTerminal"; Source = "winget" },
    @{Name = "Git.Git"; Source = "winget" },
    
    # Terminal & Shell Enhancements
    @{Name = "JanDeDobbeleer.OhMyPosh"; Source = "winget" },
    @{Name = "Alacritty.Alacritty"; Source = "winget" },
    
    # Utilities
    @{Name = "Mozilla.Firefox"; Source = "winget" },
    @{Name = "7zip.7zip"; Source = "winget" },
    @{Name = "voidtools.Everything"; Source = "winget" },
    @{Name = "Microsoft.PowerToys"; Source = "winget" },
    @{Name = "Notepad++.Notepad++"; Source = "winget" }
)

$scoopPackages = @(
    # CLI Tools
    "sudo",
    "curl",
    "wget",
    "ripgrep",
    "fd",
    "fzf",
    "jq",
    "neovim",
    "delta",
    "bat",
    "less",
    "make",
    
    # Fonts
    "nerd-fonts/CascadiaCode",
    
    # Additional tools
    "starship",
    "gcc"
)

# Chocolatey packages if you want to use Chocolatey as well
$chocoPackages = @(
    "ripgrep",
    "fd",
    "fzf",
    "neovim",
    "git-delta",
    "bat",
    "starship"
)

# Install Winget packages
Write-Host "`nInstalling Winget packages..." -ForegroundColor Cyan
foreach ($package in $wingetPackages) {
    $packageId = $package.Name
    $source = $package.Source
    Write-Host "Installing $packageId..." -ForegroundColor Yellow
    & winget install --id $packageId --source $source --accept-source-agreements --accept-package-agreements
}

# Install Scoop packages
Write-Host "`nInstalling Scoop packages..." -ForegroundColor Cyan
foreach ($package in $scoopPackages) {
    Write-Host "Installing $package..." -ForegroundColor Yellow
    & scoop install $package
}

# Optional: Install Chocolatey and packages
$installChoco = Read-Host "Do you want to install Chocolatey and additional packages? (y/n)"
if ($installChoco -eq "y") {
    # Install Chocolatey if not already installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey package manager..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    # Install Chocolatey packages
    Write-Host "`nInstalling Chocolatey packages..." -ForegroundColor Cyan
    foreach ($package in $chocoPackages) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
        & choco install $package -y
    }
}

# Install Node.js and NPM via NVM for Windows
$installNode = Read-Host "Do you want to install Node.js via NVM for Windows? (y/n)"
if ($installNode -eq "y") {
    # Install NVM for Windows using scoop
    scoop install nvm
    
    # Install latest LTS version of Node.js
    nvm install lts
    nvm use lts
    
    # Install global NPM packages
    npm install -g yarn
}

# Install Python via pyenv-win
$installPython = Read-Host "Do you want to install Python via pyenv-win? (y/n)"
if ($installPython -eq "y") {
    # Install pyenv-win using scoop
    scoop install pyenv
    
    # Install latest Python version
    pyenv install 3.11.0
    pyenv global 3.11.0
    
    # Install global pip packages
    pip install black isort flake8 pytest
}

Write-Host "`nInstalling Windows Terminal profile..." -ForegroundColor Cyan
# Create Windows Terminal settings directory if it doesn't exist
$settingsDir = "$env:LOCALAPPDATA\Microsoft\Windows Terminal"
if (-not (Test-Path $settingsDir)) {
    New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
}

# Copy Windows Terminal settings
$dotfilesTerminalSettings = "$PSScriptRoot\..\..\config\windows-terminal\settings.json"
$terminalSettingsPath = "$settingsDir\settings.json"

if (Test-Path $dotfilesTerminalSettings) {
    Copy-Item -Path $dotfilesTerminalSettings -Destination $terminalSettingsPath -Force
    Write-Host "Windows Terminal settings have been copied to $terminalSettingsPath" -ForegroundColor Green
} else {
    Write-Host "Windows Terminal settings file not found at $dotfilesTerminalSettings" -ForegroundColor Yellow
}

# Configure WSL if desired
$installWSL = Read-Host "Do you want to install Windows Subsystem for Linux (WSL)? (y/n)"
if ($installWSL -eq "y") {
    Write-Host "Installing WSL..." -ForegroundColor Yellow
    wsl --install
    
    # This will install the default Ubuntu distribution
    # After installation, you'll need to restart your computer
    Write-Host "WSL installation started. You may need to restart your computer to complete the installation." -ForegroundColor Green
}

Write-Host "`nAll packages have been installed!" -ForegroundColor Green
Write-Host "`nNote: You may need to restart your terminal or computer for some changes to take effect." -ForegroundColor Yellow