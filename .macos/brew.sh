#!/usr/bin/env bash

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Update Homebrew
brew update

###############################################################################
# Taps                                                                        #
###############################################################################
echo "Adding Homebrew taps..."

brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew tap homebrew/bundle

###############################################################################
# Terminal Utilities                                                         #
###############################################################################
echo "Installing terminal utilities..."

brew install \
  aria2 \
  bat \
  btop \
  exa \
  fd \
  ffmpeg \
  fzf \
  htop \
  jq \
  lazygit \
  lazydocker \
  lnav \
  ncdu \
  ranger \
  ripgrep \
  tldr \
  tree \
  wget \
  yazi \
  yt-dlp \
  zoxide

# System information and monitoring
brew install macchina

###############################################################################
# Development Tools                                                           #
###############################################################################
echo "Installing development tools..."

# Git and version control
brew install git

# DevOps tools
brew install \
  docker \
  kubectl \
  helm \
  k9s \
  terraform \
  slimtoolkit/slim/slim

# Text editors and IDE tools
brew install \
  neovim \
  vim

# Database tools
# CLI utilities will be installed, DBeaver added to casks below

# Programming languages and package managers
brew install python

# Install additional Python tools via pip
pip3 install --user \
  uv \
  ruff \
  pyright \
  pdoc \
  commitizen \
  pre-commit

# Shell utilities
brew install nushell

# GPG and security tools
brew install gnupg

# Install Rust via rustup
echo "Installing Rust via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install miniforge3 (Conda)
brew install miniforge

# Security and hacking tools
# brew install \
#   aircrack-ng \
#   hashcat \
#   john \
#   nmap \
#   wireshark

# Install Ollama
# brew install ollama

###############################################################################
# GUI Applications via Cask                                                  #
###############################################################################
echo "Installing GUI applications..."

# Fonts
brew install --cask \
  font-meslo-lg-nerd-font \
  font-fira-code-nerd-font

# Terminal emulators
brew install --cask \
  warp \
  wezterm

# Development tools
brew install --cask \
  dbeaver-community \
  visual-studio-code

# Productivity and utilities
brew install --cask \
  alfred \
  alt-tab \
  amethyst \
  appcleaner \
  bettertouchtool \
  caffeine \
  discord \
  drawio \
  firefox \
  hammerspoon \
  hiddenbar \
  iina \
  jan \
  karabiner-elements \
  keepassxc \
  maccy \
  microsoft-teams \
  monitor-control \
  obsidian \
  orbstack \
  pandan \
  pure-paste \
  qlstephen \
  quicklook-json \
  qlmarkdown \
  raycast \
  rectangle \
  shotr \
  spotify \
  stats \
  the-unarchiver \
  utm \
  vlc

# Flux (separate due to name format)
brew install --cask f-lux

# Install mactex without GUI components
brew install --cask mactex-no-gui

# Install mas (Mac App Store CLI) for oneswitch installation
brew install mas

# Install OneSwitch if Mac App Store is available
if command -v mas &> /dev/null; then
  echo "Installing OneSwitch from Mac App Store..."
  mas install 1477630474 || echo "Could not install OneSwitch. Check Mac App Store authentication."
fi

# Check for NVIDIA GPU and install CUDA if found
if [[ "$(system_profiler SPDisplaysDataType 2>/dev/null | grep -i nvidia)" ]]; then
  echo "NVIDIA GPU detected, installing CUDA tools..."
  brew install --cask cuda
else
  echo "No NVIDIA GPU detected, skipping CUDA installation"
fi

###############################################################################
# Cleanup                                                                    #
###############################################################################
echo "Cleaning up..."
brew cleanup

echo "Homebrew installation complete!"