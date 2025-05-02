# functions.ps1 - Shared PowerShell functions for dotfiles scripts

function Create-SymLink {
    param (
        [string]$SourcePath,
        [string]$DestPath
    )
    if (Test-Path $SourcePath) {
        if (Test-Path $DestPath) {
            if (-not (Get-Item $DestPath).LinkType) {
                $backupPath = "$DestPath.backup"
                Write-Host "Backing up existing file to $backupPath"
                Move-Item -Path $DestPath -Destination $backupPath -Force
            } else {
                Remove-Item -Path $DestPath -Force
            }
        } else {
            $parentDir = Split-Path -Parent $DestPath
            if (-not (Test-Path $parentDir)) {
                New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
            }
        }
        New-Item -ItemType SymbolicLink -Path $DestPath -Target $SourcePath -Force | Out-Null
        Write-Host "Created symlink: $DestPath -> $SourcePath"
    }
}

function Install-Winget {
    $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetAvailable) {
        Write-Host "Installing winget from Microsoft Store..."
        $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $output = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Invoke-WebRequest -Uri $url -OutFile $output
        Add-AppxPackage -Path $output
        Remove-Item -Path $output -Force
        $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        if (-not $wingetAvailable) {
            Write-Warning "Failed to install winget. Please install it manually from the Microsoft Store."
            return $false
        }
    }
    return $true
}

function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop package manager..."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
            if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
                Write-Warning "Failed to install Scoop. Please install it manually."
                return $false
            }
        } catch {
            Write-Warning "Error installing Scoop: $_"
            return $false
        }
    }
    return $true
}

function Install-Chezmoi {
    Write-Host "Setting up chezmoi for dotfiles management..." -ForegroundColor Cyan
    if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
        Write-Host "Installing chezmoi..." -ForegroundColor Yellow
        (Invoke-WebRequest -UseBasicParsing https://get.chezmoi.io/ps1).Content | powershell -c -
        $chezmoiPath = "$env:USERPROFILE\bin"
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$chezmoiPath*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$chezmoiPath", "User")
            $env:Path = "$env:Path;$chezmoiPath"
        }
    } else {
        Write-Host "chezmoi is already installed." -ForegroundColor Green
    }
    Write-Host "Initializing chezmoi with your dotfiles..." -ForegroundColor Yellow
    chezmoi init --apply --source="$((Get-Item $PSScriptRoot).Parent.Parent.FullName)"
}

function Install-Packages {
    $wingetSuccess = Install-Winget
    if (-not $wingetSuccess) {
        Write-Warning "Continuing without winget. Some packages may not be installed."
    }
    $scoopSuccess = Install-Scoop
    if (-not $scoopSuccess) {
        Write-Warning "Continuing without Scoop. Some packages may not be installed."
    }
    # ... (rest of Install-Packages logic should remain in install.ps1)
} 