#!/usr/bin/env bash
# Dotfiles installation script for macOS and Linux

set -e

# Update the dotfiles directory path to point to the parent of scripts/unix
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
OS="$(uname -s)"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print with color
print_color() {
  printf "${!1}${2}${NC}\n"
}

# Install chezmoi for dotfiles management
install_chezmoi() {
  print_color "BLUE" "Setting up chezmoi for dotfiles management..."
  
  if ! command -v chezmoi &>/dev/null; then
    print_color "YELLOW" "Installing chezmoi..."
    if [[ "$OS" == "Darwin" ]]; then
      brew install chezmoi
    else
      # Linux installation
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
      # Add to PATH if not already there
      if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
        export PATH="$PATH:$HOME/.local/bin"
      fi
    fi
  else
    print_color "GREEN" "chezmoi is already installed."
  fi
  
  # Initialize chezmoi with the dotfiles directory
  print_color "YELLOW" "Initializing chezmoi with your dotfiles..."
  chezmoi init --apply --source="$DOTFILES_DIR"
}

# MACOS SPECIFIC INSTALLATION
install_macos() {
  print_color "BLUE" "Setting up macOS environment..."
  
  # Check for Homebrew, install if not found
  if ! command -v brew &>/dev/null; then
    print_color "YELLOW" "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  
  # Check for Xcode Command Line Tools
  if ! xcode-select -p &>/dev/null; then
    print_color "YELLOW" "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait for installation to finish
    print_color "YELLOW" "Please wait for Xcode Command Line Tools to finish installing, then press any key to continue..."
    read -n 1
  fi
  
  # Install brew packages
  print_color "BLUE" "Installing packages with Homebrew..."
  brew tap homebrew/cask-fonts
  
  # Core utilities
  brew install \
    neovim \
    wget \
    curl \
    thefuck \
    zsh \
    nushell \
    btop \
    yazi \
    macchina \
    lnav \
    wezterm \
    ffmpeg \
    exa \
    bat \
    fzf \
    ripgrep \
    zoxide \
    ncdu \
    fd \
    ranger \
    tldr \
    aria2 \
    kubectl \
    helm \
    terraform \
    lazygit \
    lazydocker \
    python \
    node \
    rustup-init \
    gnupg \
    pinentry-mac \
    yt-dlp \
    miniforge \
    chezmoi
    
  # Configure Miniforge to use .conda/envs directory
  CONDA_ENV_DIR="$HOME/.conda/envs"
  mkdir -p "$CONDA_ENV_DIR"
  
  # Configure conda to use the custom environments directory
  cat > "$HOME/.condarc" <<EOL
envs_dirs:
  - $CONDA_ENV_DIR
  - $HOME/miniforge3/envs
EOL
  
  # Ensure conda initialization is in shell profiles
  for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
      if ! grep -q "conda initialize" "$SHELL_RC"; then
        print_color "YELLOW" "Adding conda initialization to $SHELL_RC"
        $HOME/miniforge3/bin/conda init "$(basename "$SHELL_RC" | sed 's/\.//')"
      fi
    fi
  done
  
  print_color "GREEN" "Configured conda to store environments in $CONDA_ENV_DIR"
  
  # Fonts
  brew install --cask \
    font-fira-code-nerd-font \
    font-meslo-lg-nerd-font
  
  # Developer tools
  brew install --cask \
    visual-studio-code \
    github \
    keepassxc \
    iterm2 \
    warp \
    utm \
    orbstack \
    dbeaver-community \
    docker
    
  # Desktop tools
  brew install --cask \
    bettertouchtool \
    caffeine \
    one-switch \
    stats \
    raycast \
    rectangle \
    alfred \
    appcleaner \
    alt-tab \
    karabiner-elements \
    hammerspoon \
    iina \
    pandan \
    monitorcontrol \
    drawio \
    obsidian \
    hiddenbar \
    the-unarchiver \
    qlstephen \
    qlmarkdown \
    quicklook-json \
    firefox \
    maccy \
    amethyst \
    shotr
  
  # Install slim toolkit
  brew tap slimtoolkit/tap
  brew install slimtoolkit
  
  # Jan AI
  brew install --cask jan
  
  # Discord
  brew install --cask discord
  
  # Teams
  brew install --cask microsoft-teams
  
  # Spotify
  brew install --cask spotify
  
  # Install pure-paste
  if ! brew list pure-paste &>/dev/null; then
    print_color "YELLOW" "Installing Pure Paste..."
    brew install --cask pure-paste
  fi
  
  # Install f.lux
  if ! brew list flux &>/dev/null; then
    print_color "YELLOW" "Installing f.lux..."
    brew install --cask flux
  fi
  
  # Setup Rust
  rustup-init -y
  
  # Install CUDA for Nvidia GPUs if available
  if system_profiler SPDisplaysDataType 2>/dev/null | grep -q "NVIDIA"; then
    print_color "YELLOW" "NVIDIA GPU detected, installing CUDA..."
    brew install cuda
  fi
  
  # Setup Python development tools
  print_color "BLUE" "Setting up Python development tools..."
  pip3 install --user --upgrade uv ruff pyright pdoc commitizen pre-commit just
  
  # Setup preferences for macOS

  # Karabiner-Elements - Map Caps Lock to Escape
  mkdir -p "$HOME/.config/karabiner"
  cat > "$HOME/.config/karabiner/karabiner.json" <<EOL
{
    "global": {
        "check_for_updates_on_startup": true,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
    },
    "profiles": [
        {
            "name": "Default profile",
            "selected": true,
            "simple_modifications": [
                {
                    "from": {
                        "key_code": "caps_lock"
                    },
                    "to": [
                        {
                            "key_code": "escape"
                        }
                    ]
                }
            ]
        }
    ]
}
EOL
  
  print_color "GREEN" "macOS setup completed!"
}

# DEBIAN/UBUNTU INSTALLATION
install_debian() {
  print_color "BLUE" "Setting up Debian/Ubuntu environment..."
  
  # Update and install essential packages
  sudo apt-get update
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release
  
  # Add important repositories
  
  # VS Code
  if ! grep -q "packages.microsoft.com/repos/code" /etc/apt/sources.list.d/vscode.list 2>/dev/null; then
    print_color "YELLOW" "Adding VS Code repository..."
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg >/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
  fi
  
  # Docker
  if ! grep -q "download.docker.com" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
    print_color "YELLOW" "Adding Docker repository..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi
  
  # Update after adding repositories
  sudo apt-get update
  
  # Install packages
  sudo apt-get install -y \
    neovim \
    wget \
    curl \
    python3-dev \
    python3-pip \
    python3-venv \
    thefuck \
    zsh \
    fzf \
    ripgrep \
    fd-find \
    bat \
    htop \
    btop \
    tmux \
    git \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    code \
    lnav \
    gnupg2 \
    texlive-full \
    p7zip-full \
    hashcat \
    nmap \
    make \
    cmake \
    gcc \
    g++
    
  # Create symbolic links for differently named packages
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf $(which fdfind) /usr/local/bin/fd
  fi
  
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf $(which batcat) /usr/local/bin/bat
  fi
  
  # Setup Docker permissions
  if getent group docker &>/dev/null; then
    sudo usermod -aG docker $USER
    print_color "YELLOW" "Added user to docker group. You may need to log out and back in for this to take effect."
  fi
  
  # Install and setup nushell
  if ! command -v nu &>/dev/null; then
    print_color "YELLOW" "Installing Nushell..."
    sudo apt-get install -y libssl-dev pkg-config
    cargo install nu
  fi
  
  # Install wezterm
  if ! command -v wezterm &>/dev/null; then
    print_color "YELLOW" "Installing WezTerm..."
    curl -LO https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu20.04.deb
    sudo dpkg -i wezterm-nightly.Ubuntu20.04.deb || sudo apt-get install -f -y
    rm wezterm-nightly.Ubuntu20.04.deb
  fi
  
  # Install kubectl and helm
  if ! command -v kubectl &>/dev/null; then
    print_color "YELLOW" "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
  fi
  
  if ! command -v helm &>/dev/null; then
    print_color "YELLOW" "Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
  fi
  
  # Install yazi file manager
  if ! command -v yazi &>/dev/null; then
    print_color "YELLOW" "Installing Yazi file manager..."
    cargo install yazi
  fi
  
  # Install macchina
  if ! command -v macchina &>/dev/null; then
    print_color "YELLOW" "Installing macchina..."
    cargo install macchina
  fi
  
  # Install Miniforge
  if ! command -v conda &>/dev/null; then
    print_color "YELLOW" "Installing Miniforge3..."
    wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" -O miniforge.sh
    bash miniforge.sh -b -p $HOME/miniforge3
    rm miniforge.sh
    
    # Add to PATH for current session
    export PATH="$HOME/miniforge3/bin:$PATH"
    
    # Add to shell initialization
    $HOME/miniforge3/bin/conda init bash zsh
  fi
  
  # Create .conda directory structure if it doesn't exist
  CONDA_ENV_DIR="$HOME/.conda/envs"
  mkdir -p "$CONDA_ENV_DIR"
  
  # Configure conda to use the custom environments directory
  cat > "$HOME/.condarc" <<EOL
envs_dirs:
  - $CONDA_ENV_DIR
  - $HOME/miniforge3/envs
EOL
  
  # Ensure conda initialization is in shell profiles
  for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
      if ! grep -q "conda initialize" "$SHELL_RC"; then
        print_color "YELLOW" "Adding conda initialization to $SHELL_RC"
        $HOME/miniforge3/bin/conda init "$(basename "$SHELL_RC" | sed 's/\.//')"
      fi
    fi
  done
  
  print_color "GREEN" "Configured conda to store environments in $CONDA_ENV_DIR"
  
  # Install Python tools
  print_color "YELLOW" "Installing Python development tools..."
  pip3 install --user --upgrade uv ruff pyright pdoc commitizen pre-commit just
  
  # Install Rust
  if ! command -v rustup &>/dev/null; then
    print_color "YELLOW" "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  
  # Install Obsidian
  if ! command -v obsidian &>/dev/null; then
    print_color "YELLOW" "Installing Obsidian..."
    wget -O obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.4.13/obsidian_1.4.13_amd64.deb"
    sudo dpkg -i obsidian.deb || sudo apt-get install -f -y
    rm obsidian.deb
  fi
  
  # Install Firefox
  if ! command -v firefox &>/dev/null; then
    print_color "YELLOW" "Installing Firefox..."
    sudo apt-get install -y firefox
  fi
  
  # Install Discord
  if ! command -v discord &>/dev/null; then
    print_color "YELLOW" "Installing Discord..."
    wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo dpkg -i discord.deb || sudo apt-get install -f -y
    rm discord.deb
  fi
  
  # Install chezmoi
  if ! command -v chezmoi &>/dev/null; then
    print_color "YELLOW" "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    # Add to PATH
    export PATH="$PATH:$HOME/.local/bin"
  fi

  print_color "GREEN" "Debian/Ubuntu setup completed!"
}

# ALPINE LINUX INSTALLATION
install_alpine() {
  print_color "BLUE" "Setting up Alpine Linux environment..."

  # Update and install essential packages
  sudo apk update
  sudo apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    zsh \
    neovim \
    python3 \
    py3-pip \
    py3-virtualenv \
    thefuck \
    fzf \
    ripgrep \
    fd \
    bat \
    htop \
    tmux \
    docker \
    lnav \
    gcc \
    g++ \
    make \
    cmake \
    openssl-dev \
    pkgconf \
    cargo \
    just \
    unzip \
    ncurses \
    shadow \
    fontconfig \
    ttf-fira-code-nerd \
    ttf-meslo-nerd

  # Add user to docker group
  if getent group docker &>/dev/null; then
    sudo usermod -aG docker $USER
    print_color "YELLOW" "Added user to docker group. You may need to log out and back in for this to take effect."
  fi

  # Install Python tools
  print_color "YELLOW" "Installing Python development tools..."
  pip3 install --user --upgrade uv ruff pyright pdoc commitizen pre-commit just

  # Install Rust
  if ! command -v rustup &>/dev/null; then
    print_color "YELLOW" "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi

  # Install yazi file manager
  if ! command -v yazi &>/dev/null; then
    print_color "YELLOW" "Installing Yazi file manager..."
    cargo install yazi
  fi

  # Install macchina
  if ! command -v macchina &>/dev/null; then
    print_color "YELLOW" "Installing macchina..."
    cargo install macchina
  fi

  # Install chezmoi
  if ! command -v chezmoi &>/dev/null; then
    print_color "YELLOW" "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    export PATH="$PATH:$HOME/.local/bin"
  fi

  print_color "GREEN" "Alpine Linux setup completed!"
}

# Install Oh My Zsh if not already installed
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_color "BLUE" "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    print_color "GREEN" "Oh My Zsh already installed."
  fi

  ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}

  # Install Powerlevel10k theme
  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    print_color "YELLOW" "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  else
    print_color "GREEN" "Powerlevel10k theme already installed."
  fi

  print_color "BLUE" "Installing Oh My Zsh plugins..."

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_color "YELLOW" "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi
  if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    print_color "YELLOW" "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
  fi
  if [ ! -d "$ZSH_CUSTOM/plugins/fzf" ]; then
    print_color "YELLOW" "Installing fzf plugin..."
    git clone https://github.com/unixorn/fzf-zsh-plugin.git "$ZSH_CUSTOM/plugins/fzf"
  fi
  if [ ! -d "$ZSH_CUSTOM/plugins/history-substring-search" ]; then
    print_color "YELLOW" "Installing history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/history-substring-search"
  fi
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-interactive-cd" ]; then
    print_color "YELLOW" "Installing zsh-interactive-cd..."
    git clone https://github.com/changyuheng/zsh-interactive-cd.git "$ZSH_CUSTOM/plugins/zsh-interactive-cd"
  fi

  # Install autojump for fast directory navigation
  if ! command -v autojump &>/dev/null; then
    print_color "YELLOW" "Installing autojump..."
    if [[ "$OS" == "Darwin" ]]; then
      brew install autojump
    elif command -v apk &>/dev/null; then
      sudo apk add --no-cache autojump
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y autojump
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm autojump
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y autojump
    else
      print_color "RED" "Could not install autojump. Please install it manually."
    fi
  fi

  # direnv integration
  if ! command -v direnv &>/dev/null; then
    print_color "YELLOW" "Installing direnv..."
    if [[ "$OS" == "Darwin" ]]; then
      brew install direnv
    elif command -v apk &>/dev/null; then
      sudo apk add --no-cache direnv
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y direnv
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm direnv
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y direnv
    else
      print_color "RED" "Could not install direnv. Please install it manually."
    fi
  fi

  # Install fd and fzf for better file searching
  if ! command -v fd &>/dev/null; then
    print_color "YELLOW" "Installing fd..."
    if [[ "$OS" == "Darwin" ]]; then
      brew install fd
    elif command -v apk &>/dev/null; then
      sudo apk add --no-cache fd
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install -y fd-find
      if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
      fi
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm fd
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y fd-find
    else
      print_color "RED" "Could not install fd. Please install it manually."
    fi
  fi
  if ! command -v fzf &>/dev/null; then
    print_color "YELLOW" "Installing fzf..."
    if [[ "$OS" == "Darwin" ]]; then
      brew install fzf
      $(brew --prefix)/opt/fzf/install --all --no-update-rc
    elif command -v apk &>/dev/null; then
      sudo apk add --no-cache fzf
    else
      if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --all --no-update-rc
      fi
    fi
  fi
  if [ -f "$DOTFILES_DIR/config/zsh/p10k.zsh" ]; then
    print_color "YELLOW" "Copying Powerlevel10k configuration..."
    cp -f "$DOTFILES_DIR/config/zsh/p10k.zsh" "$HOME/.p10k.zsh"
    print_color "GREEN" "Powerlevel10k configuration copied successfully."
  fi
  print_color "GREEN" "Oh My Zsh plugins setup complete."
}

# Install required fonts
install_fonts() {
  if [[ "$OS" != "Darwin" ]]; then
    # Install Fira Code Nerd Font
    if [ ! -d "$HOME/.local/share/fonts/FiraCode" ]; then
      print_color "YELLOW" "Installing Fira Code Nerd Font..."
      mkdir -p "$HOME/.local/share/fonts/FiraCode"
      wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip" -O /tmp/firacode.zip
      unzip -q /tmp/firacode.zip -d "$HOME/.local/share/fonts/FiraCode"
      rm /tmp/firacode.zip
    fi
    
    # Install MesloLGS NF (for Powerlevel10k)
    if [ ! -d "$HOME/.local/share/fonts/MesloLGS" ]; then
      print_color "YELLOW" "Installing MesloLGS NF fonts..."
      mkdir -p "$HOME/.local/share/fonts/MesloLGS"
      wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" -O "$HOME/.local/share/fonts/MesloLGS/MesloLGS NF Regular.ttf"
      wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" -O "$HOME/.local/share/fonts/MesloLGS/MesloLGS NF Bold.ttf"
      wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" -O "$HOME/.local/share/fonts/MesloLGS/MesloLGS NF Italic.ttf"
      wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" -O "$HOME/.local/share/fonts/MesloLGS/MesloLGS NF Bold Italic.ttf"
    fi
    
    # Rebuild font cache
    fc-cache -f -v
  fi
}

# Setup Neovim with Lazy.nvim
setup_neovim() {
  print_color "BLUE" "Setting up Neovim with Lazy.nvim..."
  
  # Create Neovim config directories
  mkdir -p "$HOME/.config/nvim"
  
  # Link Neovim configs
  if [ -d "$DOTFILES_DIR/config/nvim" ]; then
    find "$DOTFILES_DIR/config/nvim" -type f -exec ln -sf {} "$HOME/.config/nvim/$(basename {})" \;
  fi
  
  # Initialize Lazy.nvim
  if [[ "$OS" == "Darwin" ]]; then
    LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
  else
    LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
  fi
  
  if [ ! -d "$LAZY_PATH" ]; then
    print_color "YELLOW" "Installing Lazy.nvim..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_PATH"
  fi
}

# Setup Nushell configuration
setup_nushell() {
  print_color "BLUE" "Setting up Nushell configuration..."
  
  # Create Nushell config directory
  NUSHELL_CONFIG_DIR="$HOME/.config/nushell"
  mkdir -p "$NUSHELL_CONFIG_DIR"
  
  # Link Nushell config files
  if [ -d "$DOTFILES_DIR/config/nushell" ]; then
    print_color "YELLOW" "Linking Nushell configuration files..."
    ln -sf "$DOTFILES_DIR/config/nushell/config.nu" "$NUSHELL_CONFIG_DIR/config.nu"
    ln -sf "$DOTFILES_DIR/config/nushell/env.nu" "$NUSHELL_CONFIG_DIR/env.nu"
    
    # Link Oh My Posh theme for Nushell to use
    OMPOSH_DIR="$HOME/.config/powershell"
    mkdir -p "$OMPOSH_DIR"
    ln -sf "$DOTFILES_DIR/config/powershell/github-dark.omp.json" "$OMPOSH_DIR/github-dark.omp.json"
    
    print_color "GREEN" "Nushell configuration linked successfully."
  else
    print_color "RED" "Nushell configuration directory not found in dotfiles."
  fi
  
  # Install Oh My Posh if it's not installed yet
  if ! command -v oh-my-posh &>/dev/null; then
    print_color "YELLOW" "Installing Oh My Posh..."
    
    if [[ "$OS" == "Darwin" ]]; then
      brew install jandedobbeleer/oh-my-posh/oh-my-posh
    else
      # Linux installation
      curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    
    print_color "GREEN" "Oh My Posh installed successfully."
  else
    print_color "GREEN" "Oh My Posh is already installed."
  fi
}

# Install VSCode extensions
install_vscode_extensions() {
  print_color "BLUE" "Installing VS Code extensions..."
  
  if command -v code &> /dev/null; then
    code --install-extension adoxxorg.adoxx-adoscript
    code --install-extension alefragnani.project-manager
    code --install-extension batisteo.vscode-django
    code --install-extension codezombiech.gitignore
    code --install-extension donjayamanne.git-extension-pack
    code --install-extension donjayamanne.githistory
    code --install-extension donjayamanne.python-environment-manager
    code --install-extension donjayamanne.python-extension-pack
    code --install-extension eamodio.gitlens
    code --install-extension github.copilot
    code --install-extension github.copilot-chat
    code --install-extension gruntfuggly.todo-tree
    code --install-extension hediet.vscode-drawio
    code --install-extension kevinrose.vsc-python-indent
    code --install-extension mathworks.language-matlab
    code --install-extension ms-python.debugpy
    code --install-extension ms-python.python
    code --install-extension ms-python.vscode-pylance
    code --install-extension ms-toolsai.jupyter
    code --install-extension ms-toolsai.jupyter-keymap
    code --install-extension ms-toolsai.jupyter-renderers
    code --install-extension ms-toolsai.tensorboard
    code --install-extension ms-toolsai.vscode-jupyter-cell-tags
    code --install-extension ms-toolsai.vscode-jupyter-slideshow
    code --install-extension ms-vscode-remote.remote-wsl
    code --install-extension njpwerner.autodocstring
    code --install-extension visualstudioexptteam.intellicode-api-usage-examples
    code --install-extension visualstudioexptteam.vscodeintellicode
    code --install-extension wholroyd.jinja
    code --install-extension ziyasal.vscode-open-in-github
  else
    print_color "YELLOW" "VS Code not found, skipping extension installation."
  fi
}

# Set Zsh as default shell
set_zsh_default() {
  if [[ "$SHELL" != *"zsh"* ]]; then
    print_color "YELLOW" "Setting Zsh as default shell..."
    if command -v chsh >/dev/null 2>&1 ; then
      chsh -s $(which zsh)
    else
      print_color "RED" "Could not change shell automatically. Please run: chsh -s $(which zsh)"
    fi
  else
    print_color "GREEN" "Zsh is already the default shell."
  fi
}

# Main installation function
main() {
  print_color "BOLD" "====== Starting dotfiles installation ======"
  
  if [[ "$OS" == "Darwin" ]]; then
    print_color "BLUE" "Detected macOS system"
    install_macos
  elif [[ "$OS" == "Linux" ]]; then
    print_color "BLUE" "Detected Linux system"
    if command -v apk &> /dev/null; then
      print_color "YELLOW" "Alpine Linux detected"
      install_alpine
    elif command -v pacman &> /dev/null; then
      if [ -f "$DOTFILES_DIR/Makefile" ];then
        print_color "YELLOW" "Arch Linux detected, using Makefile for installation"
        cd "$DOTFILES_DIR" && make install
        exit 0
      fi
    else
      install_debian
    fi
  else
    print_color "RED" "Unsupported OS: $OS"
    exit 1
  fi
  
  install_oh_my_zsh
  install_fonts
  setup_neovim
  install_vscode_extensions
  setup_nushell
  
  # Use chezmoi to manage dotfiles instead of create_symlinks
  install_chezmoi
  
  set_zsh_default
  
  print_color "GREEN" "====== Dotfiles installation complete! ======"
  print_color "YELLOW" "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

main "$@"