# functions.sh - Shared bash functions for dotfiles scripts

# Print with color
print_color() {
  local color_var="$1"
  local text="$2"
  local NC='\033[0m'
  printf "%b%s%b\n" "${!color_var}" "$text" "$NC"
}

# Install chezmoi for dotfiles management
install_chezmoi() {
  print_color "BLUE" "Setting up chezmoi for dotfiles management..."
  if ! command -v chezmoi &>/dev/null; then
    print_color "YELLOW" "Installing chezmoi..."
    if [[ "$(uname -s)" == "Darwin" ]]; then
      brew install chezmoi
    else
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
      if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
        export PATH="$PATH:$HOME/.local/bin"
      fi
    fi
  else
    print_color "GREEN" "chezmoi is already installed."
  fi
  print_color "YELLOW" "Initializing chezmoi with your dotfiles..."
  chezmoi init --apply --source="$DOTFILES_DIR"
} 