#!/usr/bin/env pwsh
# Cross-platform package installation script
# Supports Windows (Scoop), macOS (Homebrew), and Linux (pacman/apt/dnf)

# Stop on errors
$ErrorActionPreference = "Stop"

# Import chezmoi data
$chezmoiData = chezmoi data --format json | ConvertFrom-Json

# Define common packages for all platforms
$commonPackages = @(
    "git",
    "neovim",
    "ripgrep",
    "fd",
    "fzf",
    "bat",
    "delta",
    "jq",
    "lazygit",
    "starship"
)

# Define OS-specific package lists
$windowsPackages = @(
    "pwsh",
    "windows-terminal",
    "gsudo",
    "mingw",
    "gcc",
    "make",
    "llvm"
)

$macosPackages = @(
    "coreutils",
    "gnu-sed",
    "gnu-tar",
    "grep",
    "bash",
    "zsh",
    "kitty",
    "rectangle",
    "alt-tab",
    "karabiner-elements"
)

$archPackages = @(
    "base-devel",
    "yay",
    "zsh",
    "kitty",
    "i3-wm",
    "sway",
    "waybar",
    "rofi",
    "dunst",
    "picom",
    "xorg-server",
    "xorg-xinit"
)

# Development tools based on user preferences
if ($chezmoiData.use_docker) {
    $commonPackages += @("docker", "docker-compose")
}

if ($chezmoiData.use_kubernetes) {
    $commonPackages += @("kubectl", "helm", "k9s")
}

if ($chezmoiData.use_node) {
    $commonPackages += @("nodejs", "npm", "yarn")
}

if ($chezmoiData.use_python) {
    $commonPackages += @("python", "pip")
}

if ($chezmoiData.use_rust) {
    $commonPackages += @("rust", "cargo")
}

if ($chezmoiData.use_go) {
    $commonPackages += @("go")
}

# Install package manager if needed
function Install-PackageManager {
    switch ($chezmoiData.chezmoi.os) {
        "windows" {
            if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
                Write-Host "Installing Scoop..."
                Invoke-RestMethod get.scoop.sh | Invoke-Expression
                scoop install git
                scoop bucket add extras
                scoop bucket add versions
                scoop bucket add nerd-fonts
            }
        }
        "darwin" {
            if (-not (Get-Command brew -ErrorAction SilentlyContinue)) {
                Write-Host "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            }
        }
        "linux" {
            if ($chezmoiData.is_arch -and $chezmoiData.use_aur) {
                if (-not (Get-Command $chezmoiData.aur_helper -ErrorAction SilentlyContinue)) {
                    Write-Host "Installing $($chezmoiData.aur_helper)..."
                    git clone "https://aur.archlinux.org/$($chezmoiData.aur_helper).git"
                    Set-Location $chezmoiData.aur_helper
                    makepkg -si --noconfirm
                    Set-Location ..
                    Remove-Item -Recurse -Force $chezmoiData.aur_helper
                }
            }
        }
    }
}

# Install packages based on OS
function Install-Packages {
    Write-Host "Installing packages for $($chezmoiData.chezmoi.os)..."
    
    switch ($chezmoiData.chezmoi.os) {
        "windows" {
            foreach ($package in ($commonPackages + $windowsPackages)) {
                Write-Host "Installing $package..."
                scoop install $package
            }
        }
        "darwin" {
            foreach ($package in ($commonPackages + $macosPackages)) {
                Write-Host "Installing $package..."
                brew install $package
            }
        }
        "linux" {
            if ($chezmoiData.is_arch) {
                if ($chezmoiData.use_aur) {
                    foreach ($package in ($commonPackages + $archPackages)) {
                        Write-Host "Installing $package..."
                        & $chezmoiData.aur_helper -S --noconfirm $package
                    }
                } else {
                    foreach ($package in ($commonPackages + $archPackages)) {
                        Write-Host "Installing $package..."
                        sudo pacman -S --noconfirm $package
                    }
                }
            }
        }
    }
}

# Install fonts
function Install-Fonts {
    if ($chezmoiData.use_nerd_font) {
        $font = $chezmoiData.nerd_font
        Write-Host "Installing $font Nerd Font..."
        
        switch ($chezmoiData.chezmoi.os) {
            "windows" {
                scoop bucket add nerd-fonts
                scoop install "$font-NF"
            }
            "darwin" {
                brew tap homebrew/cask-fonts
                brew install --cask "font-$($font.ToLower())-nerd-font"
            }
            "linux" {
                if ($chezmoiData.is_arch) {
                    if ($chezmoiData.use_aur) {
                        & $chezmoiData.aur_helper -S --noconfirm "nerd-fonts-$($font.ToLower())"
                    }
                }
            }
        }
    }
}

# Configure Git globally
function Configure-Git {
    Write-Host "`nConfiguring Git global settings..."
    
    # Get Git credentials from chezmoi data or prompt
    $gitName = $chezmoiData.name
    $gitEmail = $chezmoiData.email
    
    if (-not $gitName) {
        $gitName = Read-Host "Enter your full name for Git commits"
    }
    if (-not $gitEmail) {
        $gitEmail = Read-Host "Enter your email for Git commits"
    }
    
    # Configure Git settings
    Write-Host "Setting up Git configuration..."
    git config --global user.name $gitName
    git config --global user.email $gitEmail
    
    # Configure Git defaults (similar to mathiasbynens/dotfiles)
    git config --global core.excludesfile "~/.gitignore_global"
    git config --global core.attributesfile "~/.gitattributes"
    
    # Better diffs
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    
    # Better merging
    git config --global merge.conflictstyle "diff3"
    git config --global diff.colorMoved "default"
    
    # Prevent showing files whose names contain non-ASCII symbols as unversioned
    git config --global core.precomposeunicode "true"
    
    # Automatically correct and execute mistyped commands
    git config --global help.autocorrect 1
    
    # Use main as default branch
    git config --global init.defaultBranch "main"
    
    # Rebase preferences
    git config --global pull.rebase true
    git config --global rebase.autoStash true
    
    # Aliases
    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual '!gitk'
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    # If GPG signing is enabled
    if ($chezmoiData.git_sign_commits -and $chezmoiData.git_signing_key) {
        git config --global commit.gpgsign true
        git config --global user.signingkey $chezmoiData.git_signing_key
    }
    
    # Create global gitignore if it doesn't exist
    $gitignoreGlobal = Join-Path $HOME ".gitignore_global"
    if (-not (Test-Path $gitignoreGlobal)) {
        @"
# Compiled source
*.com
*.class
*.dll
*.exe
*.o
*.so

# Packages
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Logs and databases
*.log
*.sql
*.sqlite

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE specific files
.idea/
.vscode/
*.swp
*.swo
*~

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Python
__pycache__/
*.py[cod]
*$py.class
.env
.venv
venv/
ENV/

# Ruby
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
/test/tmp/
/test/version_tmp/
/tmp/

# Local env files
.env.local
.env.*.local
"@ | Out-File -FilePath $gitignoreGlobal -Encoding utf8
    }
    
    Write-Host "Git configuration complete!"
}

# Main installation process
try {
    Install-PackageManager
    Install-Packages
    Install-Fonts
    
    # Configure Git after it's installed
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Configure-Git
    } else {
        Write-Warning "Git is not installed. Skipping Git configuration."
    }
    
    Write-Host "Installation complete!"
} catch {
    Write-Error "An error occurred during installation: $_"
    exit 1
} 