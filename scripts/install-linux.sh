#!/usr/bin/env bash
set -e

# --- Color Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'
print_color() { printf "${!1}%s${NC}\n" "$2"; }

# --- Detect OS ---
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f "/etc/arch-release" ] || [ -f "/etc/artix-release" ]; then
      echo "arch"
    elif [ -f "/etc/fedora-release" ]; then
      echo "fedora"
    elif [ -f "/etc/debian_version" ]; then
      echo "debian"
    elif [ -f "/etc/alpine-release" ]; then
      echo "alpine"
    else
      echo "linux"
    fi
  else
    echo "unsupported"
  fi
}

# --- Helper: Warn if running pip as root ---
warn_if_pip_as_root() {
  if [[ "$EUID" == 0 ]]; then
    print_color YELLOW "[WARN] Running pip as root can break your system Python. Use a virtual environment if possible. See: https://pip.pypa.io/warnings/venv"
  fi
}

# --- Install Packages ---
install_packages() {
  os=$(detect_os)
  print_color BLUE "[Install] Detected OS: $os"
  case "$os" in
    arch)
      sudo pacman -Syu --noconfirm
      sudo pacman -S --needed --noconfirm git base-devel zsh neovim ripgrep fd bat exa python python-pip nodejs npm curl wget fzf htop btop tmux ranger lazygit gcc
      # SOTA tools install (Pacman/AUR/Cargo)
      SOTA_TOOLS=(eza bat fd ripgrep sd xh gitui broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog zoxide lazygit)
      for tool in "${SOTA_TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
          if pacman -Si "$tool" &>/dev/null; then
            sudo pacman -S --noconfirm "$tool"
          elif command -v yay &>/dev/null; then
            yay -S --noconfirm "$tool"
          elif command -v cargo &>/dev/null; then
            cargo install "$tool"
          fi
        fi
      done
      ;;
    debian)
      sudo apt update
      sudo apt install -y git zsh neovim ripgrep fd-find bat python3 python3-pip nodejs npm curl wget fzf htop tmux ranger fontconfig build-essential cargo unzip
      if command -v fdfind && ! command -v fd; then sudo ln -sf "$(which fdfind)" /usr/local/bin/fd; fi
      # Warn if running pip as root
      warn_if_pip_as_root
      # SOTA tools install (Homebrew/Cargo/Apt)
      if command -v brew >/dev/null 2>&1; then
        print_color BLUE "[SOTA] Installing SOTA CLI tools with Homebrew..."
        TOOLS=(eza bat fd ripgrep sd xh gitui rga broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog choose-gui zoxide yazi lazygit onefetch)
        for tool in "${TOOLS[@]}"; do
          if ! brew list --formula | grep -q "^$tool$"; then brew install "$tool"; fi
        done
      else
        print_color BLUE "[SOTA] Installing SOTA CLI tools with apt/cargo..."
        sudo apt install -y bat fd-find ripgrep ncdu hyperfine zoxide
        if command -v fdfind && ! command -v fd; then sudo ln -sf "$(which fdfind)" /usr/local/bin/fd; fi
        if ! command -v cargo >/dev/null 2>&1; then
          print_color YELLOW "[SOTA] Cargo not found. Installing Rust..."
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
          export PATH="$HOME/.cargo/bin:$PATH"
        fi
        if command -v rustup >/dev/null 2>&1; then
          rustup self update
          rustup install stable
          rustup default stable
          export PATH="$HOME/.cargo/bin:$PATH"
        fi
        CARGO_TOOLS=(eza sd xh gitui broot dua-cli just atuin bandwhich miniserve dog lazygit)
        for tool in "${CARGO_TOOLS[@]}"; do
          if ! command -v "$tool" >/dev/null 2>&1; then
            cargo install "$tool"
          else
            print_color GREEN "[SOTA] $tool already installed."
          fi
        done
      fi
      # Ensure $HOME/.local/bin is in PATH for pipx and user-level pip installs
      if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        print_color YELLOW "[PATH] Added $HOME/.local/bin to PATH for this session."
      fi
      # If running as root, also ensure /root/.local/bin is in PATH (for CI or sudo installs)
      if [[ "$EUID" == 0 && ":$PATH:" != *":/root/.local/bin:"* && -d "/root/.local/bin" ]]; then
        export PATH="/root/.local/bin:$PATH"
        print_color YELLOW "[PATH] Added /root/.local/bin to PATH for this session (root user)."
      fi
      ;;
    fedora)
      sudo dnf update -y
      sudo dnf install -y git zsh neovim ripgrep fd-find bat python3 python3-pip nodejs npm curl wget fzf htop tmux ranger fontconfig-devel unzip
      # SOTA tools install (DNF/Cargo)
      SOTA_TOOLS=(eza bat fd ripgrep sd xh gitui broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog zoxide lazygit)
      for tool in "${SOTA_TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
          if dnf list --available "$tool" &>/dev/null; then
            sudo dnf install -y "$tool"
          elif command -v cargo &>/dev/null; then
            cargo install "$tool"
          fi
        fi
      done
      if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        print_color YELLOW "[PATH] Added $HOME/.local/bin to PATH for this session."
      fi
      ;;
    alpine)
      sudo apk update
      sudo apk add --no-cache bash curl wget git zsh neovim python3 py3-pip py3-virtualenv fzf ripgrep fd bat htop tmux docker tree openssh sudo ncurses less unzip jq gcc musl-dev linux-headers shadow
      # SOTA tools install (APK/Cargo)
      SOTA_TOOLS=(eza bat fd ripgrep sd xh gitui broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog zoxide lazygit)
      for tool in "${SOTA_TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
          if apk search -q "$tool" | grep -q "$tool"; then
            sudo apk add --no-cache "$tool"
          elif command -v cargo &>/dev/null; then
            cargo install "$tool"
          fi
        fi
      done
      if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        print_color YELLOW "[PATH] Added $HOME/.local/bin to PATH for this session."
      fi
      ;;
    *)
      print_color RED "[Install] Unsupported OS: $os"
      exit 1
      ;;
  esac
}

# --- Install Krew Plugins ---
install_krew_plugins() {
  if ! command -v kubectl-krew >/dev/null 2>&1; then
    print_color YELLOW "[Krew] Installing Krew..."
    cd "$(mktemp -d)"
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m)"
    [ "$ARCH" == "x86_64" ] && ARCH="amd64"
    [ "$ARCH" == "armv7l" ] && ARCH="arm"
    KREW="krew-${OS}_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz"
    ./${KREW} install krew
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  fi
  KREW_PLUGINS=(ctx ns neat tail view-secret access-matrix get-all sniff tree who-can trace popeye konfig ktop resource-capacity deprecations)
  for plugin in "${KREW_PLUGINS[@]}"; do
    if ! kubectl krew list | grep -q "^$plugin$"; then
      kubectl krew install "$plugin"
    fi
  done
}

# --- Install Fonts ---
install_fonts() {
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  if [ ! -d "$FONT_DIR/FiraCode" ]; then
    print_color YELLOW "[Fonts] Installing Fira Code Nerd Font..."
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip" -O /tmp/firacode.zip
    unzip -q /tmp/firacode.zip -d "$FONT_DIR/FiraCode"
    rm /tmp/firacode.zip
  fi
  if [ ! -d "$FONT_DIR/MesloLGS" ]; then
    print_color YELLOW "[Fonts] Installing MesloLGS NF fonts..."
    wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" -O "$FONT_DIR/MesloLGS NF Regular.ttf"
    wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" -O "$FONT_DIR/MesloLGS NF Bold.ttf"
    wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" -O "$FONT_DIR/MesloLGS NF Italic.ttf"
    wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" -O "$FONT_DIR/MesloLGS NF Bold Italic.ttf"
  fi
  fc-cache -f -v || true
}

# --- Oh My Posh Setup ---
setup_oh_my_posh() {
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
  OH_MY_POSH_DIR="$HOME/.config/oh-my-posh"
  mkdir -p "$OH_MY_POSH_DIR"
  if ! command -v oh-my-posh &>/dev/null; then
    print_color YELLOW "[OMP] Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
  fi
  THEME_SRC="$DOTFILES_DIR/config/powershell/github-dark.omp.json"
  THEME_DEST="$OH_MY_POSH_DIR/github-dark.omp.json"
  if [ -f "$THEME_SRC" ]; then
    cp "$THEME_SRC" "$THEME_DEST"
    ln -sf "$THEME_DEST" "$OH_MY_POSH_DIR/current-theme.omp.json"
  fi
}

# --- Symlink Shell Profiles ---
symlink_shell_profiles() {
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
  for shell in zsh bash; do
    src="$DOTFILES_DIR/config/$shell/${shell}rc"
    dest="$HOME/.${shell}rc"
    if [ -f "$src" ]; then
      ln -sf "$src" "$dest"
    fi
  done
}

# --- Make Scripts Executable ---
make_scripts_executable() {
  DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
  find "$DOTFILES_DIR/bootstrap/scripts/unix" -type f -name '*.sh' -exec chmod +x {} +
}

# --- Heal Common Issues ---
heal_common_issues() {
  print_color BLUE "[Heal] Healing common dotfiles issues..."
  if ! command -v chezmoi >/dev/null 2>&1; then
    print_color RED "[Heal] chezmoi not found. Please install chezmoi first!"
  else
    print_color GREEN "[Heal] chezmoi found."
  fi
  if fc-list | grep -qi 'Nerd Font'; then
    print_color GREEN "[Heal] Nerd Font is installed."
  else
    print_color YELLOW "[Heal] Nerd Font not found. Please install a Nerd Font for best prompt experience."
  fi
}

# --- Main ---
main() {
  print_color BOLD "====== Starting Linux dotfiles installation ======"
  install_packages
  install_krew_plugins
  install_fonts
  setup_oh_my_posh
  symlink_shell_profiles
  make_scripts_executable
  heal_common_issues
  print_color GREEN "====== Linux dotfiles installation complete! ======"
  print_color YELLOW "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

main "$@" 