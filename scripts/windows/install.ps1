#!/usr/bin/env pwsh
# Dotfiles installation script for Windows

. "$PSScriptRoot/functions.ps1"

# Check for administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as Administrator"
    exit 1
}

# Update the dotfiles directory path to point to the parent of scripts/windows
$DOTFILES_DIR = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$HOME_DIR = $env:USERPROFILE

function Install-Winget {
    # Check if winget is available
    $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
    
    if (-not $wingetAvailable) {
        Write-Host "Installing winget from Microsoft Store..."
        
        # Using direct MSIX link if Microsoft Store install is not possible
        $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $output = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        
        # Download the installer
        Invoke-WebRequest -Uri $url -OutFile $output
        
        # Install the package
        Add-AppxPackage -Path $output
        
        # Cleanup
        Remove-Item -Path $output -Force
        
        # Test if winget is now available
        $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        if (-not $wingetAvailable) {
            Write-Warning "Failed to install winget. Please install it manually from the Microsoft Store."
            return $false
        }
    }
    
    return $true
}

function Install-Scoop {
    # Check if Scoop is installed
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop package manager..."
        
        try {
            # Set execution policy for current user
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            
            # Install Scoop
            Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
            
            # Check if installation was successful
            if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
                Write-Warning "Failed to install Scoop. Please install it manually."
                return $false
            }
        }
        catch {
            Write-Warning "Error installing Scoop: $_"
            return $false
        }
    }
    
    return $true
}

function Install-Chezmoi {
    Write-Host "Setting up chezmoi for dotfiles management..." -ForegroundColor Cyan
    
    # Check if chezmoi is already installed
    if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
        Write-Host "Installing chezmoi..." -ForegroundColor Yellow
        
        # Using Invoke-WebRequest to install
        (Invoke-WebRequest -UseBasicParsing https://get.chezmoi.io/ps1).Content | powershell -c -
        
        # Add to PATH if not already there
        $chezmoiPath = "$HOME_DIR\bin"
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$chezmoiPath*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$chezmoiPath", "User")
            # Update current session path
            $env:Path = "$env:Path;$chezmoiPath"
        }
    } else {
        Write-Host "chezmoi is already installed." -ForegroundColor Green
    }
    
    # Initialize chezmoi with the dotfiles directory
    Write-Host "Initializing chezmoi with your dotfiles..." -ForegroundColor Yellow
    chezmoi init --apply --source="$DOTFILES_DIR"
}

function Install-Packages {
    # Install winget if needed
    $wingetSuccess = Install-Winget
    if (-not $wingetSuccess) {
        Write-Warning "Continuing without winget. Some packages may not be installed."
    }
    
    # Install Scoop if needed
    $scoopSuccess = Install-Scoop
    if (-not $scoopSuccess) {
        Write-Warning "Continuing without Scoop. Some packages may not be installed."
    }
    
    if ($wingetSuccess) {
        Write-Host "Installing packages using winget..."
        
        $packages = @(
            # Terminal and shell
            "Microsoft.PowerShell",
            "Microsoft.WindowsTerminal",
            "wez.wezterm", # WezTerm terminal
            "Warp.Warp", # Warp Terminal
            
            # Development tools
            "Microsoft.VisualStudioCode",
            "Git.Git",
            "Neovim.Neovim",
            "Docker.DockerDesktop",
            "Microsoft.WSL2",
            "Kubernetes.kubectl",
            "Kubernetes.Helm",
            "Rustlang.Rustup",
            "Python.Python.3.11",
            "GitHub.cli",
            "GitHub.GitHubDesktop",
            "Microsoft.PowerToys",
            
            # Data and Productivity
            "KeePassXCTeam.KeePassXC",
            "Obsidian.Obsidian",
            "DBBrowserForSQLite.DBBrowserForSQLite",
            "dbeaver.dbeaver",
            "drawio.drawio",
            "Discord.Discord",
            "Microsoft.Teams",
            "Spotify.Spotify",
            "Mozilla.Firefox",
            "Brave.Brave",
            
            # Utilities
            "7zip.7zip",
            "VideoLAN.VLC",
            "IINA.IINA",
            "voidtools.Everything",
            "qBittorrent.qBittorrent",
            "Lexikos.AutoHotkey",
            "Notion.Notion",
            "flux.flux",
            "AltSnap.AltSnap",
            "ShareX.ShareX",
            "twpayne.chezmoi"  # Add chezmoi to the winget packages
        )
        
        foreach ($package in $packages) {
            Write-Host "Installing $package..."
            winget install --id $package --silent --accept-source-agreements --accept-package-agreements
        }
    }
    
    if ($scoopSuccess) {
        # Setup Scoop buckets
        scoop bucket add extras
        scoop bucket add nerd-fonts
        scoop bucket add versions
        scoop bucket add java
        
        # Install packages via Scoop
        Write-Host "Installing packages using Scoop..."
        $scoopPackages = @(
            # CLI utilities
            "less",
            "which",
            "touch",
            "sed",
            "grep",
            "curl",
            "wget",
            "bat",
            "fd",
            "ripgrep",
            "jq",
            "zoxide",
            "fzf",
            "yazi",
            "btop",
            "lazygit",
            "lazydocker",
            "lnav",
            "tldr",
            "macchina",
            "bind",
            "neofetch",
            "aria2",
            "nushell",
            "binwalk",
            "ncdu",
            "onefetch",
            "vhs", # Terminal GIF recorder
            "chezmoi",  # Add chezmoi to Scoop packages as a fallback
            # Additional recommended tools
            "lsd",
            "duf",
            "dust",
            "glow",
            "httpie",
            "procs",
            # Rust-powered modern tools
            "broot",
            "bottom",
            "as-tree",
            "dua-cli",
            "delta",
            "difftastic",
            "just",
            "atuin",
            "bandwhich",
            "hyperfine",
            "miniserve",
            "choose",
            # New SOTA tools
            "eza",
            "vivid",
            "sd",
            "xh",
            "gitui",
            "ripgrep-all",
            "bat-extras",
            "onefetch"
        )
        
        foreach ($package in $scoopPackages) {
            Write-Host "Installing $package with Scoop..."
            scoop install $package
        }
        
        # Install Nerd Fonts
        Write-Host "Installing Nerd Fonts..."
        scoop install FiraCode-NF
        scoop install MesloLGS-NF
        
        # dog: try scoop, else cargo
        if (-not (Get-Command dog -ErrorAction SilentlyContinue)) {
            try {
                scoop install dog
            } catch {
                Write-Host "dog not available in Scoop, installing via cargo..."
                if (Get-Command cargo -ErrorAction SilentlyContinue) {
                    cargo install dog
                } else {
                    Write-Warning "cargo not found. Please install Rust/cargo to get dog."
                }
            }
        }
        # Fallback to cargo for Rust-powered tools if not available
        $rustTools = @("broot","bottom","as-tree","dua-cli","delta","difftastic","just","atuin","bandwhich","hyperfine","miniserve","choose","eza","vivid","sd","xh","gitui","ripgrep-all","bat-extras","onefetch")
        foreach ($tool in $rustTools) {
            if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
                if (Get-Command cargo -ErrorAction SilentlyContinue) {
                    Write-Host "Installing $tool via cargo..."
                    cargo install $tool
                } else {
                    Write-Warning "$tool not found and cargo not available. Please install Rust/cargo to get $tool."
                }
            }
        }
    }
    
    # Install Python packages with pip
    Write-Host "Installing Python packages..."
    pip install --upgrade uv ruff pyright pdoc commitizen pre-commit
    
    # Setup Rust with rustup
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        Write-Host "Initializing Rust environment..."
        rustup default stable
        rustup component add clippy rustfmt rust-analyzer
    }
    
    # Install Ollama for local LLM inference
    Write-Host "Installing Ollama..."
    Invoke-WebRequest -Uri "https://ollama.com/download/ollama-windows.zip" -OutFile "$env:TEMP\ollama.zip"
    Expand-Archive -Path "$env:TEMP\ollama.zip" -DestinationPath "$env:LOCALAPPDATA\Programs\Ollama" -Force
    
    # Add Ollama to PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*Ollama*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$env:LOCALAPPDATA\Programs\Ollama", "User")
    }
    
    # Install Jan AI
    Write-Host "Downloading Jan AI..."
    $janUrl = "https://jan.ai/download/windows"
    $janOutputPath = "$env:TEMP\jan-setup.exe"
    Invoke-WebRequest -Uri $janUrl -OutFile $janOutputPath
    Write-Host "Installing Jan AI (requires user confirmation)..."
    Start-Process -FilePath $janOutputPath -Wait
    
    # Install WSL Ubuntu if not already installed
    if (-not (wsl --list | Select-String "Ubuntu")) {
        Write-Host "Installing WSL Ubuntu..."
        wsl --install -d Ubuntu
    }
}

function Install-VSCodeExtensions {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host "Installing VS Code extensions..."
        
        # Define a list of VS Code extensions to install
        $extensions = @(
            "adoxxorg.adoxx-adoscript",
            "alefragnani.project-manager",
            "batisteo.vscode-django",
            "codezombiech.gitignore",
            "donjayamanne.git-extension-pack",
            "donjayamanne.githistory",
            "donjayamanne.python-environment-manager",
            "donjayamanne.python-extension-pack",
            "eamodio.gitlens",
            "github.copilot",
            "github.copilot-chat",
            "gruntfuggly.todo-tree",
            "hediet.vscode-drawio",
            "kevinrose.vsc-python-indent",
            "mathworks.language-matlab",
            "ms-python.debugpy",
            "ms-python.python",
            "ms-python.vscode-pylance",
            "ms-toolsai.jupyter",
            "ms-toolsai.jupyter-keymap",
            "ms-toolsai.jupyter-renderers",
            "ms-toolsai.tensorboard",
            "ms-toolsai.vscode-jupyter-cell-tags",
            "ms-toolsai.vscode-jupyter-slideshow",
            "ms-vscode-remote.remote-wsl",
            "njpwerner.autodocstring",
            "visualstudioexptteam.intellicode-api-usage-examples",
            "visualstudioexptteam.vscodeintellicode",
            "wholroyd.jinja",
            "ziyasal.vscode-open-in-github"
        )
        
        # Install each extension
        foreach ($extension in $extensions) {
            Write-Host "Installing VS Code extension: $extension"
            code --install-extension $extension
        }
    }
    else {
        Write-Warning "VS Code not found in PATH. Skipping extension installation."
    }
}

function Configure-KarabinerForCapslockToEscape {
    # This is for Windows, using AutoHotkey instead of Karabiner
    Write-Host "Configuring CapsLock to Escape mapping with AutoHotkey..."
    
    # Create AutoHotkey script
    $autoHotkeyScript = @"
#NoEnv
#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Map CapsLock to Escape
CapsLock::Escape

; Map Shift+CapsLock to toggle CapsLock state
+CapsLock::
    SetCapsLockState, % GetKeyState("CapsLock", "T") ? "Off" : "On"
return
"@
    
    # Create startup folder if it doesn't exist
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    if (-not (Test-Path $startupFolder)) {
        New-Item -ItemType Directory -Path $startupFolder -Force | Out-Null
    }
    
    # Write script to startup folder
    $scriptPath = "$startupFolder\CapsLockToEscape.ahk"
    Set-Content -Path $scriptPath -Value $autoHotkeyScript
    
    # Run the script now
    if (Get-Command AutoHotkey -ErrorAction SilentlyContinue) {
        Start-Process AutoHotkey -ArgumentList $scriptPath
        Write-Host "AutoHotkey script created and running. CapsLock is now mapped to Escape."
    }
    else {
        Write-Warning "AutoHotkey not found. Script created but not running. Please start it manually or install AutoHotkey."
    }
}

function Setup-Miniforge {
    # Check if Miniforge is already installed
    if (Test-Path "$HOME_DIR\miniforge3") {
        Write-Host "Miniforge already installed."
    }
    else {
        Write-Host "Installing Miniforge3..."
        $miniforgeUrl = "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe"
        $miniforgeInstaller = "$env:TEMP\miniforge3_installer.exe"
        
        # Download the installer
        Invoke-WebRequest -Uri $miniforgeUrl -OutFile $miniforgeInstaller
        
        # Run the installer silently
        Start-Process -FilePath $miniforgeInstaller -ArgumentList "/S /InstallationType=JustMe /AddToPath=1 /RegisterPython=1 /D=$HOME_DIR\miniforge3" -Wait
        
        # Cleanup
        Remove-Item -Path $miniforgeInstaller -Force
        
        Write-Host "Miniforge3 installed successfully."
    }
    
    # Create .conda directory structure if it doesn't exist
    $condaEnvDir = "$HOME_DIR\.conda\envs"
    if (-not (Test-Path $condaEnvDir)) {
        New-Item -Path $condaEnvDir -ItemType Directory -Force | Out-Null
        Write-Host "Created conda environments directory at $condaEnvDir"
    }
    
    # Configure conda to use the custom environments directory
    $condaConfigDir = "$HOME_DIR\.condarc"
    $condaConfig = @"
envs_dirs:
  - $($condaEnvDir.Replace("\", "/"))
  - $($HOME_DIR.Replace("\", "/"))/miniforge3/envs
"@
    
    Set-Content -Path $condaConfigDir -Value $condaConfig
    Write-Host "Configured conda to store environments in $condaEnvDir"
    
    # Ensure Miniforge is in the PATH
    $miniforgePathEntries = @(
        "$HOME_DIR\miniforge3",
        "$HOME_DIR\miniforge3\Scripts",
        "$HOME_DIR\miniforge3\Library\bin"
    )
    
    # Add to current session PATH if not already there
    foreach ($pathEntry in $miniforgePathEntries) {
        if ($env:Path -notlike "*$pathEntry*") {
            $env:Path = "$pathEntry;$env:Path"
        }
    }
    
    # Add to permanent user PATH if not already there
    $currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $pathUpdated = $false
    
    foreach ($pathEntry in $miniforgePathEntries) {
        if ($currentUserPath -notlike "*$pathEntry*") {
            $currentUserPath = "$pathEntry;$currentUserPath"
            $pathUpdated = $true
        }
    }
    
    if ($pathUpdated) {
        [Environment]::SetEnvironmentVariable("PATH", $currentUserPath, "User")
        Write-Host "Added Miniforge directories to user PATH"
    }
    
    # Initialize conda for PowerShell and other shells
    if (Test-Path "$HOME_DIR\miniforge3\Scripts\conda.exe") {
        # Initialize conda for future sessions
        Write-Host "Initializing conda for PowerShell..."
        & "$HOME_DIR\miniforge3\Scripts\conda.exe" init powershell | Out-Null
        
        Write-Host "Initializing conda for cmd.exe..."
        & "$HOME_DIR\miniforge3\Scripts\conda.exe" init cmd.exe | Out-Null
        
        Write-Host "Conda initialization complete"
    }
}

function Setup-WSLWithZsh {
    Write-Host "Configuring WSL to use Zsh as default shell..." -ForegroundColor Cyan
    
    # Check if WSL is installed
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        # Install Oh My Zsh in WSL if not already installed
        Write-Host "Setting up Oh My Zsh in WSL..." -ForegroundColor Yellow
        
        # Check if zsh is installed in WSL, if not install it
        wsl -e bash -c "if ! command -v zsh &> /dev/null; then sudo apt update && sudo apt install -y zsh; fi"
        
        # Install Oh My Zsh if not installed
        wsl -e bash -c 'if [ ! -d "$HOME/.oh-my-zsh" ]; then sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; fi'
        
        # Install Powerlevel10k theme
        Write-Host "Installing Powerlevel10k theme in WSL..." -ForegroundColor Yellow
        wsl -e bash -c 'ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
        if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        fi'
        
        # Install required plugins
        Write-Host "Installing Oh My Zsh plugins in WSL..." -ForegroundColor Yellow
        wsl -e bash -c 'ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
        # zsh-autosuggestions
        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        fi
        
        # fast-syntax-highlighting (faster than zsh-syntax-highlighting)
        if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
            git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
        fi
        
        # history-substring-search
        if [ ! -d "$ZSH_CUSTOM/plugins/history-substring-search" ]; then
            git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/history-substring-search"
        fi
        
        # zsh-interactive-cd
        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-interactive-cd" ]; then
            git clone https://github.com/changyuheng/zsh-interactive-cd.git "$ZSH_CUSTOM/plugins/zsh-interactive-cd"
        fi
        
        # Install useful utilities
        if ! command -v autojump &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y autojump
        fi
        
        if ! command -v direnv &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y direnv
        fi
        
        if ! command -v fd &> /dev/null && ! command -v fdfind &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y fd-find
            # Create symlink for fd
            if command -v fdfind &> /dev/null; then
                sudo ln -sf $(which fdfind) /usr/local/bin/fd
            fi
        fi
        
        if ! command -v fzf &> /dev/null; then
            if [ ! -d "$HOME/.fzf" ]; then
                git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
                "$HOME/.fzf/install" --all --no-update-rc
            fi
        fi'

        # Link dotfiles in WSL home directory
        Write-Host "Linking dotfiles in WSL..." -ForegroundColor Yellow
        wsl -e bash -c "if [ -d ~/dotfiles ]; then rm -rf ~/dotfiles; fi && mkdir -p ~/dotfiles"
        
        # Create Linux symlink by mounting Windows dotfiles directory into WSL
        wsl -e bash -c "ln -sf ~/dotfiles/.zshrc ~/.zshrc"
        
        # Copy p10k configuration
        Write-Host "Copying p10k configuration to WSL..." -ForegroundColor Yellow
        wsl -e bash -c 'if [ -f ~/dotfiles/.p10k.zsh ]; then
            cp -f ~/dotfiles/.p10k.zsh ~/.p10k.zsh
        fi'
        
        # WSL mount point creation for Windows dotfiles
        $wslMountScript = @"
#!/bin/bash
# Mount Windows dotfiles directory to WSL
if mountpoint -q ~/dotfiles; then
    echo "Dotfiles already mounted"
else
    mkdir -p ~/dotfiles
    mount -t drvfs $($DOTFILES_DIR.Replace('\', '/')) ~/dotfiles
    echo "Mounted Windows dotfiles directory to ~/dotfiles"
fi
"@
        
        # Write the mount script to WSL
        $mountScriptContent = $wslMountScript.Replace("`r`n", "`n")
        wsl -e bash -c "echo '$mountScriptContent' > ~/.mount-dotfiles.sh && chmod +x ~/.mount-dotfiles.sh"
        
        # Add to .profile to auto-mount on login
        wsl -e bash -c 'if ! grep -q "~/.mount-dotfiles.sh" ~/.profile; then
            echo "~/.mount-dotfiles.sh" >> ~/.profile
            echo "Mount script added to ~/.profile"
        fi'
        
        # Set Zsh as default shell in WSL
        wsl -e bash -c 'if [ "$SHELL" != "/usr/bin/zsh" ]; then chsh -s $(which zsh) $(whoami); fi'
        
        Write-Host "WSL configured to use Zsh with Powerlevel10k as default shell" -ForegroundColor Green
    } else {
        Write-Warning "WSL not found. Skipping WSL configuration."
    }
}

function Configure-WindowsTerminalForZsh {
    Write-Host "Configuring Windows Terminal to use WSL with Zsh..." -ForegroundColor Cyan
    
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if ((Test-Path $wtSettingsPath) -and (Get-Command wt -ErrorAction SilentlyContinue) -and (Get-Command wsl -ErrorAction SilentlyContinue)) {
        try {
            $wtSettings = Get-Content -Path $wtSettingsPath -Raw | ConvertFrom-Json
            
            # Backup settings if needed
            $backupPath = "$wtSettingsPath.backup-zsh"
            if (-not (Test-Path $backupPath)) {
                Copy-Item -Path $wtSettingsPath -Destination $backupPath
                Write-Host "Created backup of Windows Terminal settings at $backupPath"
            }
            
            # Find the WSL profile
            $wslProfile = $wtSettings.profiles.list | Where-Object { $_.name -like "*Ubuntu*" -or $_.name -like "*WSL*" -or $_.commandline -like "*wsl*" } | Select-Object -First 1
            
            if ($wslProfile) {
                # Update the command line to launch directly into zsh
                $wslProfile.commandline = "wsl.exe ~ -d Ubuntu -e /usr/bin/zsh"
                
                # Ensure font is set to a Nerd Font
                if (-not $wslProfile.font) {
                    $wslProfile.font = @{
                        face = "FiraCode NF"
                        size = 11
                    }
                }
                
                # Save changes
                $wtSettings | ConvertTo-Json -Depth 32 | Set-Content -Path $wtSettingsPath
                Write-Host "Updated Windows Terminal settings to use Zsh in WSL" -ForegroundColor Green
            } else {
                Write-Warning "Could not find WSL profile in Windows Terminal settings"
            }
        }
        catch {
            Write-Warning "Failed to update Windows Terminal settings for WSL: $_"
        }
    } else {
        Write-Warning "Windows Terminal or WSL not found. Skipping Windows Terminal configuration for WSL."
    }
}

# Main installation process
Write-Host "Starting dotfiles installation on Windows..." -ForegroundColor Cyan

# Ask user if they want to install packages
$installPackages = Read-Host "Do you want to install recommended packages? (y/N)"
if ($installPackages -eq "y" -or $installPackages -eq "Y") {
    Install-Packages
    Setup-Miniforge
    Install-VSCodeExtensions
    Configure-KarabinerForCapslockToEscape
    Setup-WSLWithZsh
    Configure-WindowsTerminalForZsh
}

# Install chezmoi for dotfiles management
Install-Chezmoi

# Create symlinks for configuration files
Write-Host "Creating symlinks for configuration files..." -ForegroundColor Cyan

# Create symbolic links for shell configs
Write-Host "Linking shell configuration files..." -ForegroundColor Cyan
Create-SymLink -SourcePath "$DOTFILES_DIR\config\bash\bashrc" -DestPath "$HOME_DIR\.bashrc"
Create-SymLink -SourcePath "$DOTFILES_DIR\config\zsh\zshrc" -DestPath "$HOME_DIR\.zshrc"

# Linking Nushell configuration
$NUSHELL_CONFIG_DIR = "$HOME_DIR\AppData\Roaming\nushell"
if (-Not (Test-Path $NUSHELL_CONFIG_DIR)) {
    New-Item -Path $NUSHELL_CONFIG_DIR -ItemType Directory -Force | Out-Null
    Write-Host "Created Nushell config directory at $NUSHELL_CONFIG_DIR"
}

Write-Host "Linking Nushell configuration files..." -ForegroundColor Cyan
Create-SymLink -SourcePath "$DOTFILES_DIR\config\nushell\config.nu" -DestPath "$NUSHELL_CONFIG_DIR\config.nu"
Create-SymLink -SourcePath "$DOTFILES_DIR\config\nushell\env.nu" -DestPath "$NUSHELL_CONFIG_DIR\env.nu"

# Also link the Oh My Posh theme for Nushell to use
$OMPosh_DEST_DIR = "$HOME_DIR\.config\powershell"
if (-Not (Test-Path $OMPosh_DEST_DIR)) {
    New-Item -Path $OMPosh_DEST_DIR -ItemType Directory -Force | Out-Null
}
Create-SymLink -SourcePath "$DOTFILES_DIR\config\powershell\github-dark.omp.json" -DestPath "$OMPosh_DEST_DIR\github-dark.omp.json"

# Link neovim configuration
if (Test-Path "$DOTFILES_DIR\config\nvim") {
    $NVIM_CONFIG_DIR = "$HOME_DIR\AppData\Local\nvim"
    if (-Not (Test-Path $NVIM_CONFIG_DIR)) {
        New-Item -Path $NVIM_CONFIG_DIR -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "Linking Neovim configuration..." -ForegroundColor Cyan
    # Create parent directories if needed and then create symlinks for each file
    Get-ChildItem -Path "$DOTFILES_DIR\config\nvim" -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring("$DOTFILES_DIR\config\nvim\".Length)
        $destPath = Join-Path -Path $NVIM_CONFIG_DIR -ChildPath $relativePath
        
        # Create directory structure
        $destDir = Split-Path -Parent $destPath
        if (-not (Test-Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
        }
        
        Create-SymLink -SourcePath $_.FullName -DestPath $destPath
    }
}

# Link WezTerm configuration
if (Test-Path "$DOTFILES_DIR\config\wezterm") {
    $WEZTERM_CONFIG_DIR = "$HOME_DIR\.config\wezterm"
    if (-Not (Test-Path $WEZTERM_CONFIG_DIR)) {
        New-Item -Path $WEZTERM_CONFIG_DIR -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "Linking WezTerm configuration..." -ForegroundColor Cyan
    Get-ChildItem -Path "$DOTFILES_DIR\config\wezterm" -File | ForEach-Object {
        Create-SymLink -SourcePath $_.FullName -DestPath "$WEZTERM_CONFIG_DIR\$($_.Name)"
    }
}

# Link VS Code settings
if (Test-Path "$DOTFILES_DIR\config\vscode") {
    $VSCODE_CONFIG_DIR = "$HOME_DIR\AppData\Roaming\Code\User"
    if (-Not (Test-Path $VSCODE_CONFIG_DIR)) {
        New-Item -Path $VSCODE_CONFIG_DIR -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "Linking VS Code configuration..." -ForegroundColor Cyan
    Create-SymLink -SourcePath "$DOTFILES_DIR\config\vscode\settings.json" -DestPath "$VSCODE_CONFIG_DIR\settings.json"
    Create-SymLink -SourcePath "$DOTFILES_DIR\config\vscode\keybindings.json" -DestPath "$VSCODE_CONFIG_DIR\keybindings.json"
}

# Setup Lazy.nvim plugin manager
$lazyNvimPath = "$env:LOCALAPPDATA\nvim-data\lazy\lazy.nvim"
if (-not (Test-Path $lazyNvimPath)) {
    Write-Host "Installing Lazy.nvim..."
    $lazyDir = Split-Path -Parent $lazyNvimPath
    New-Item -Path $lazyDir -ItemType Directory -Force | Out-Null
    git clone https://github.com/folke/lazy.nvim.git --filter=blob:none --branch=stable $lazyNvimPath
}

# Configure Windows Terminal to use the configured fonts
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if ((Test-Path $wtSettingsPath) -and (Get-Command wt -ErrorAction SilentlyContinue)) {
    Write-Host "Configuring Windows Terminal..." -ForegroundColor Cyan
    
    try {
        $wtSettings = Get-Content -Path $wtSettingsPath -Raw | ConvertFrom-Json
        
        # Check if we need to create a backup
        $backupPath = "$wtSettingsPath.backup"
        if (-not (Test-Path $backupPath)) {
            Copy-Item -Path $wtSettingsPath -Destination $backupPath
            Write-Host "Created backup of Windows Terminal settings at $backupPath"
        }
        
        # Set default font to FiraCode Nerd Font for all profiles
        foreach ($profile in $wtSettings.profiles.list) {
            $profile.font = @{
                face = "FiraCode NF"
                size = 11
            }
        }
        
        # Set GitHub Dark theme as the default
        $wtSettings.theme = "GitHub Dark Default"
        
        # Add GitHub Dark theme if it doesn't exist
        $hasGithubTheme = $false
        foreach ($scheme in $wtSettings.schemes) {
            if ($scheme.name -eq "GitHub Dark Default") {
                $hasGithubTheme = $true
                break
            }
        }
        
        if (-not $hasGithubTheme) {
            $wtSettings.schemes += @{
                name = "GitHub Dark Default"
                background = "#0d1117"
                foreground = "#c9d1d9"
                selectionBackground = "#284566"
                cursorColor = "#c9d1d9"
                black = "#484f58"
                brightBlack = "#6e7681"
                red = "#ff7b72"
                brightRed = "#ffa198"
                green = "#3fb950"
                brightGreen = "#56d364"
                yellow = "#d29922"
                brightYellow = "#e3b341"
                blue = "#58a6ff"
                brightBlue = "#79c0ff"
                purple = "#bc8cff"
                brightPurple = "#d2a8ff"
                cyan = "#39c5cf"
                brightCyan = "#56d4dd"
                white = "#b1bac4"
                brightWhite = "#f0f6fc"
            }
        }
        
        # Save changes
        $wtSettings | ConvertTo-Json -Depth 32 | Set-Content -Path $wtSettingsPath
        Write-Host "Updated Windows Terminal settings with FiraCode Nerd Font and GitHub Dark theme"
    }
    catch {
        Write-Warning "Failed to update Windows Terminal settings: $_"
    }
}

Write-Host "Dotfiles installation completed!" -ForegroundColor Green
Write-Host "You may need to restart your terminal for all changes to take effect." -ForegroundColor Yellow