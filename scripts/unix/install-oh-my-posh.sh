#!/bin/bash
# Oh My Posh Installation Script for Linux/macOS
# This script installs Oh My Posh and sets up the GitHub Dark theme

# Update the dotfiles directory path to point to the parent of scripts/unix
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

# Define directories
OH_MY_POSH_DIR="$HOME/.config/oh-my-posh"
CONFIG_DIR="$HOME/.config/powershell"

# Create necessary directories
echo "Creating Oh My Posh configuration directories..."
mkdir -p "$OH_MY_POSH_DIR"
mkdir -p "$CONFIG_DIR"

# Check if Oh My Posh is installed
if ! command -v oh-my-posh &> /dev/null; then
    echo "Oh My Posh not found. Installing..."
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "Installing Oh My Posh using Homebrew..."
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
        else
            echo "Homebrew not found. Installing Oh My Posh using the installation script..."
            curl -s https://ohmyposh.dev/install.sh | bash -s
        fi
    else
        # Linux
        echo "Installing Oh My Posh using the installation script..."
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    
    # Check if installation was successful
    if ! command -v oh-my-posh &> /dev/null; then
        echo "Failed to install Oh My Posh. Please install it manually."
        exit 1
    fi
else
    echo "Oh My Posh is already installed."
fi

# Copy GitHub Dark theme to Oh My Posh directory
echo "Setting up GitHub Dark theme for Oh My Posh..."
SOURCE_THEME="$DOTFILES_DIR/config/powershell/github-dark.omp.json"
DEST_THEME="$OH_MY_POSH_DIR/github-dark.omp.json"

if [ -f "$SOURCE_THEME" ]; then
    cp "$SOURCE_THEME" "$DEST_THEME"
    echo "GitHub Dark theme copied successfully!"
    
    # Create a symlink to the current theme
    ln -sf "$DEST_THEME" "$OH_MY_POSH_DIR/current-theme.omp.json"
else
    echo "Theme file not found at $SOURCE_THEME. Creating a default one."
    
    # Create a minimal theme file if the source doesn't exist
    cat > "$DEST_THEME" << 'EOF'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        {
          "background": "#0d1117",
          "foreground": "#c9d1d9",
          "leading_diamond": "\ue0b6",
          "style": "diamond",
          "template": " {{ .UserName }} ",
          "trailing_diamond": "\ue0b0",
          "type": "session"
        },
        {
          "background": "#0d1117",
          "foreground": "#58a6ff",
          "powerline_symbol": "\ue0b0",
          "properties": {
            "folder_separator_icon": " \ue0b1 ",
            "home_icon": "\uf7db",
            "style": "full"
          },
          "style": "powerline",
          "template": " {{ .Path }} ",
          "type": "path"
        },
        {
          "background": "#0d1117",
          "foreground": "#3fb950",
          "powerline_symbol": "\ue0b0",
          "properties": {
            "branch_icon": "\ue725 ",
            "fetch_stash_count": true,
            "fetch_status": true,
            "fetch_upstream_icon": true
          },
          "style": "powerline",
          "template": " {{ .UpstreamIcon }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }} ",
          "type": "git"
        },
        {
          "background": "#0d1117",
          "foreground": "#bc8cff",
          "powerline_symbol": "\ue0b0",
          "style": "powerline",
          "template": " \ue235 {{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }}{{ end }} ",
          "type": "python"
        },
        {
          "background": "#0d1117",
          "foreground": "#ff7b72",
          "powerline_symbol": "\ue0b0",
          "style": "powerline",
          "template": " \ue718 {{ if .PackageManagerIcon }}{{ .PackageManagerIcon }} {{ end }}{{ .Full }} ",
          "type": "node"
        },
        {
          "background": "#0d1117",
          "foreground": "#e3b341",
          "powerline_symbol": "\ue0b0",
          "style": "powerline",
          "template": " \ue7a8 {{ .CurrentDate | date .Format }} ",
          "type": "time"
        }
      ],
      "type": "prompt"
    },
    {
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "foreground": "#58a6ff",
          "style": "plain",
          "template": "\u276f ",
          "type": "text"
        }
      ],
      "type": "prompt"
    }
  ],
  "final_space": true,
  "version": 2
}
EOF
    ln -sf "$DEST_THEME" "$OH_MY_POSH_DIR/current-theme.omp.json"
    echo "Created default GitHub Dark theme."
fi

# Install FiraCode Nerd Font if necessary
echo -n "Would you like to install FiraCode Nerd Font? (y/N): "
read -r install_font

if [ "$install_font" = "y" ] || [ "$install_font" = "Y" ]; then
    echo "Installing FiraCode Nerd Font..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use Homebrew if available
        if command -v brew &> /dev/null; then
            brew tap homebrew/cask-fonts
            brew install --cask font-fira-code-nerd-font
        else
            echo "Homebrew not found. Please install fonts manually from https://www.nerdfonts.com/font-downloads"
        fi
    else
        # Linux
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        
        echo "Downloading FiraCode Nerd Font..."
        wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip -O /tmp/FiraCode.zip
        
        echo "Extracting and installing fonts..."
        unzip -q /tmp/FiraCode.zip -d /tmp/FiraCode
        cp /tmp/FiraCode/*.ttf "$FONT_DIR/"
        
        # Update font cache
        if command -v fc-cache &> /dev/null; then
            echo "Updating font cache..."
            fc-cache -f
        fi
        
        # Clean up
        rm -rf /tmp/FiraCode /tmp/FiraCode.zip
    fi
    
    echo "Fonts installed!"
else
    echo "Skipping font installation. Please ensure you have a Nerd Font installed for optimal experience."
fi

# Configure shell integration
echo -n "Configure Oh My Posh for your shell? (y/N): "
read -r configure_shell

if [ "$configure_shell" = "y" ] || [ "$configure_shell" = "Y" ]; then
    # Detect shell
    CURRENT_SHELL=$(basename "$SHELL")
    
    case "$CURRENT_SHELL" in
        bash)
            SHELL_RC="$HOME/.bashrc"
            echo "Configuring Oh My Posh for Bash..."
            
            # Check if already configured
            if ! grep -q "oh-my-posh" "$SHELL_RC"; then
                echo '
# Oh My Posh configuration
export POSH_THEME="$HOME/.config/oh-my-posh/github-dark.omp.json"
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init bash --config $POSH_THEME)"
fi' >> "$SHELL_RC"
                echo "Bash configuration updated!"
            else
                echo "Oh My Posh already configured in .bashrc"
            fi
            ;;
            
        zsh)
            SHELL_RC="$HOME/.zshrc"
            echo "Configuring Oh My Posh for Zsh..."
            
            # Check if already configured
            if ! grep -q "oh-my-posh" "$SHELL_RC"; then
                echo '
# Oh My Posh configuration
export POSH_THEME="$HOME/.config/oh-my-posh/github-dark.omp.json"
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config $POSH_THEME)"
fi' >> "$SHELL_RC"
                echo "Zsh configuration updated!"
            else
                echo "Oh My Posh already configured in .zshrc"
            fi
            ;;
            
        fish)
            SHELL_RC="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$SHELL_RC")"
            echo "Configuring Oh My Posh for Fish..."
            
            # Check if already configured
            if ! grep -q "oh-my-posh" "$SHELL_RC" 2>/dev/null; then
                echo '
# Oh My Posh configuration
set -x POSH_THEME "$HOME/.config/oh-my-posh/github-dark.omp.json"
if command -v oh-my-posh &>/dev/null
    oh-my-posh init fish --config "$POSH_THEME" | source
end' >> "$SHELL_RC"
                echo "Fish configuration updated!"
            else
                echo "Oh My Posh already configured in config.fish"
            fi
            ;;
            
        *)
            echo "Unsupported shell: $CURRENT_SHELL"
            echo "Please manually configure Oh My Posh for your shell."
            ;;
    esac
    
else
    echo "Skipping shell configuration."
fi

echo "Oh My Posh setup complete with GitHub Dark theme!"
echo "Note: You may need to restart your terminal for changes to take effect."