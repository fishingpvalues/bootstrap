#!/usr/bin/env bash
# unix-healer.sh - Heal common dotfiles/chezmoi issues on Unix/macOS/Linux

set -e

printf '\033[36m[Healer] Starting dotfiles healing process...\033[0m\n'

# 1. Ensure chezmoi is installed
if ! command -v chezmoi >/dev/null 2>&1; then
  printf '\033[31m[Healer] chezmoi not found. Please install chezmoi first!\033[0m\n'
else
  printf '\033[32m[Healer] chezmoi found.\033[0m\n'
fi

# 2. Symlink shell profiles
for shell in zsh bash; do
  src="$PWD/config/$shell/${shell}rc"
  dest="$HOME/.${shell}rc"
  if [ -f "$src" ]; then
    if [ ! -L "$dest" ] || [ "$(readlink "$dest")" != "$src" ]; then
      printf "[Healer] Symlinking $dest to $src\n"
      ln -sf "$src" "$dest"
    else
      printf "[Healer] $dest is already symlinked.\n"
    fi
  fi
done

# 3. Make scripts executable
find "$PWD/scripts/unix" -type f -name '*.sh' -exec chmod +x {} +
printf '[Healer] Made all scripts in scripts/unix executable.\n'

# 4. Check for Nerd Font
if fc-list | grep -qi 'Nerd Font'; then
  printf '[Healer] Nerd Font is installed.\n'
else
  printf '\033[33m[Healer] Nerd Font not found. Please install a Nerd Font for best prompt experience.\033[0m\n'
fi

printf '\033[36m[Healer] Healing complete! Restart your terminal to apply all changes.\033[0m\n' 