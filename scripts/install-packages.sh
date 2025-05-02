#!/usr/bin/env bash
# Cross-platform package installation script

set -e

# Detect the operating system
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f "/etc/arch-release" ] || [ -f "/etc/artix-release" ]; then
      echo "arch"
    elif [ -f "/etc/fedora-release" ]; then
      echo "fedora"
    elif [ -f "/etc/debian_version" ]; then
      echo "debian"
    else
      echo "linux"
    fi
  else
    echo "unknown"
  fi
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Log functions
log_info() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

log_success() {
  echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

log_warning() {
  echo -e "\033[1;33m[WARNING]\033[0m $1"
}

log_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Install packages on Arch Linux
install_arch() {
  log_info "Installing packages on Arch Linux..."
  
  # Make sure system is up to date
  sudo pacman -Syu --noconfirm
  
  # Install Pacman packages
  sudo pacman -S --needed --noconfirm git base-devel zsh neovim ripgrep fd bat exa python python-pip nodejs npm \
    curl wget fzf htop btop tmux ranger lazygit gcc

  # Check if yay is installed (AUR helper)
  if ! command_exists yay; then
    log_info "Installing yay AUR helper..."
    
    # Create temp directory
    mkdir -p "$HOME/tmp"
    cd "$HOME/tmp" || return
    
    # Clone and install yay
    git clone https://aur.archlinux.org/yay.git
    cd yay || return
    makepkg -si --noconfirm
    cd "$HOME" || return
    rm -rf "$HOME/tmp"
  fi

  # Install AUR packages
  yay -S --needed --noconfirm nerd-fonts-fira-code visual-studio-code-bin zsh-autosuggestions zsh-syntax-highlighting \
    zoxide lazydocker neofetch nerd-fonts-meslo powerlevel10k-git python-virtualenvwrapper
}

# Install packages on Debian/Ubuntu
install_debian() {
  log_info "Installing packages on Debian/Ubuntu..."
  
  # Update package list
  sudo apt update
  
  # Install common packages
  sudo apt install -y git zsh neovim ripgrep fd-find bat python3 python3-pip nodejs npm \
    curl wget fzf htop tmux ranger fontconfig build-essential cargo

  # Symlink fd-find to fd
  if command_exists fdfind && ! command_exists fd; then
    sudo ln -s "$(which fdfind)" /usr/local/bin/fd
  fi

  # Setup cargo if not already done
  if command_exists cargo; then
    # Install exa (a modern replacement for ls) via cargo
    if ! command_exists exa; then
      cargo install exa
    fi
  fi

  # Install nerd fonts
  if [ ! -d "$HOME/.local/share/fonts" ]; then
    mkdir -p "$HOME/.local/share/fonts"
  fi
  
  # Download and install Fira Code Nerd Font
  if [ ! -f "$HOME/.local/share/fonts/Fira Code Regular Nerd Font Complete.ttf" ]; then
    log_info "Installing Fira Code Nerd Font..."
    curl -fLo "$HOME/.local/share/fonts/Fira Code Regular Nerd Font Complete.ttf" \
      https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
    fc-cache -fv
  fi
}

# Install Homebrew on macOS if not present
install_homebrew() {
  if ! command_exists brew; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH (for Apple Silicon Macs)
    if [[ "$(uname -m)" == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    log_info "Homebrew already installed, updating..."
    brew update
  fi
}

# Install packages on macOS
install_macos() {
  install_homebrew

  # Check if Brewfile exists in home directory
  if [ -f "$HOME/.Brewfile" ]; then
    log_info "Installing packages from Brewfile..."
    brew bundle --global
  else
    log_warning "No .Brewfile found in home directory, installing essential packages..."
    
    # Install essential packages
    brew install git zsh neovim ripgrep fd bat exa python3 node \
      curl wget fzf htop tmux ranger lazygit macchina

    # Install casks
    brew install --cask visual-studio-code wezterm font-fira-code-nerd-font
  fi
  
  # Install Rust (if not already installed)
  if ! command_exists rustup; then
    log_info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi

  # Install Python tools
  log_info "Installing Python development tools..."
  pip3 install --user uv ruff pyright pdoc commitizen pre-commit
}

# Install packages on Fedora
install_fedora() {
  log_info "Installing packages on Fedora..."
  
  # Update system
  sudo dnf update -y
  
  # Install essential packages
  sudo dnf install -y git zsh neovim ripgrep fd-find bat python3 python3-pip nodejs npm \
    curl wget fzf htop tmux ranger fontconfig-devel
    
  # Install additional tools through COPR repositories
  sudo dnf copr enable -y atim/lazygit
  sudo dnf install -y lazygit
}

# Main function
main() {
  os=$(detect_os)
  
  log_info "Detected operating system: $os"
  
  case "$os" in
    macos)
      install_macos
      ;;
    arch)
      install_arch
      ;;
    debian)
      install_debian
      ;;
    fedora)
      install_fedora
      ;;
    *)
      log_error "Unsupported operating system: $os"
      exit 1
      ;;
  esac
  
  log_success "Package installation completed!"
}

# Run main function
main "$@"