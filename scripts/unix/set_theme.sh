#!/bin/bash

# If this script is meant to operate on user config, keep $HOME/.config/.
# If it is meant to operate on repo files, use dot_config/ for chezmoi compatibility.

THEME=$1
if [[ -z "$THEME" ]]; then echo "Usage: $0 <forest|water|desert>"; exit 1; fi

# Waybar
theme_dir="$HOME/.config/waybar"
ln -sf "$theme_dir/colors-${THEME}.css" "$theme_dir/current-theme.css"
pkill -SIGUSR2 waybar || waybar &

# Kitty
kitty_dir="$HOME/.config/kitty"
ln -sf "$kitty_dir/colors-${THEME}.conf" "$kitty_dir/current-theme.conf"
pgrep -f "kitty" | xargs -r kill -SIGUSR1

# WezTerm
wezterm_dir="$HOME/.config/wezterm/colors"
ln -sf "colors-${THEME}.lua" "$wezterm_dir/current_theme.lua"
wezterm cli reload-configuration &>/dev/null

# Rofi
rofi_dir="$HOME/.config/rofi/themes"
ln -sf "$rofi_dir/colors-${THEME}.rasi" "$rofi_dir/current-colors.rasi"

# Alacritty
yazi_dir="$HOME/.config/yazi"
alacritty_dir="$HOME/.config/alacritty"
zathura_dir="$HOME/.config/zathura"
starship_dir="$HOME/.config/starship"
lazygit_dir="$HOME/.config/lazygit"
nvim_dir="$HOME/.config/nvim/colors"
obsidian_dir="$HOME/.config/obsidian/themes"
firefox_dir="$HOME/.mozilla/firefox"
vscode_dir="$HOME/.config/Code/User"
qt5ct_dir="$HOME/.config/qt5ct"
qt6ct_dir="$HOME/.config/qt6ct"

# Symlink per-theme configs if present
ln -sf "$alacritty_dir/colors-${THEME}.yml" "$alacritty_dir/current-theme.yml" 2>/dev/null
ln -sf "$yazi_dir/colors-${THEME}.toml" "$yazi_dir/current-theme.toml" 2>/dev/null

# Dunst theme colors
DUNST_CONFIG="$HOME/.config/dunst/dunstrc"
if [ -f "$DUNST_CONFIG" ]; then
    case $THEME in
        forest)
            sed -i \
                -e 's/#THEME_BG_COLOR#/#2A3D2F/g' \
                -e 's/#THEME_FG_COLOR#/#A3BFA8/g' \
                "$DUNST_CONFIG"
            ;;
        water)
            sed -i \
                -e 's/#THEME_BG_COLOR#/#1B2B34/g' \
                -e 's/#THEME_FG_COLOR#/#A7C7E7/g' \
                "$DUNST_CONFIG"
            ;;
        desert)
            sed -i \
                -e 's/#THEME_BG_COLOR#/#3B2F2F/g' \
                -e 's/#THEME_FG_COLOR#/#EBCB8B/g' \
                "$DUNST_CONFIG"
            ;;
    esac
fi

# App theme symlinks
btop_dir="$HOME/.config/btop/themes"
tmux_dir="$HOME/.config/tmux"
neofetch_dir="$HOME/.config/neofetch"
bat_dir="$HOME/.config/bat/themes"
lf_dir="$HOME/.config/lf"
micro_dir="$HOME/.config/micro/colorschemes"
helix_dir="$HOME/.config/helix/themes"
zellij_dir="$HOME/.config/zellij/themes"
k9s_dir="$HOME/.config/k9s"
htop_dir="$HOME/.config/htop"
ranger_dir="$HOME/.config/ranger/colorschemes"
mpv_dir="$HOME/.config/mpv/scripts/themes"
ncmpcpp_dir="$HOME/.config/ncmpcpp"
mako_dir="$HOME/.config/mako"
foot_dir="$HOME/.config/foot/themes"
swaylock_dir="$HOME/.config/swaylock"

ln -sf "$btop_dir/${THEME}.theme" "$btop_dir/current.theme" 2>/dev/null
ln -sf "$tmux_dir/${THEME}.conf" "$tmux_dir/current-theme.conf" 2>/dev/null
ln -sf "$neofetch_dir/${THEME}.conf" "$neofetch_dir/current-theme.conf" 2>/dev/null
ln -sf "$bat_dir/${THEME}.tmTheme" "$bat_dir/current-theme.tmTheme" 2>/dev/null
ln -sf "$lf_dir/${THEME}.theme" "$lf_dir/current-theme.theme" 2>/dev/null
ln -sf "$micro_dir/${THEME}.json" "$micro_dir/current-theme.json" 2>/dev/null
ln -sf "$helix_dir/${THEME}.toml" "$helix_dir/current-theme.toml" 2>/dev/null
ln -sf "$zellij_dir/${THEME}.kdl" "$zellij_dir/current-theme.kdl" 2>/dev/null
ln -sf "$k9s_dir/${THEME}.yml" "$k9s_dir/current-theme.yml" 2>/dev/null
ln -sf "$htop_dir/${THEME}.htoprc" "$htop_dir/current-theme.htoprc" 2>/dev/null
ln -sf "$ranger_dir/${THEME}.conf" "$ranger_dir/current-theme.conf" 2>/dev/null
ln -sf "$mpv_dir/${THEME}.lua" "$mpv_dir/current-theme.lua" 2>/dev/null
ln -sf "$ncmpcpp_dir/${THEME}.config" "$ncmpcpp_dir/current-theme.config" 2>/dev/null
ln -sf "$mako_dir/${THEME}.conf" "$mako_dir/current-theme.conf" 2>/dev/null
ln -sf "$foot_dir/${THEME}.ini" "$foot_dir/current-theme.ini" 2>/dev/null
ln -sf "$swaylock_dir/${THEME}.conf" "$swaylock_dir/current-theme.conf" 2>/dev/null

# GTK theme, icon, cursor (example: WhiteSur variants)
case $THEME in
    forest)
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-dark"
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
        ;;
    water)
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-light"
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-light"
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
        ;;
    desert)
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur"
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur"
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
        ;;
esac

# Wallpaper: pick random from subfolder
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/${THEME}"
if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        killall swaybg || true
        swaybg -i "$WALLPAPER" -m fill &
    fi
fi

# More app theme symlinks
btop_dir="$HOME/.config/btop/themes"
tmux_dir="$HOME/.config/tmux"
neofetch_dir="$HOME/.config/neofetch"
bat_dir="$HOME/.config/bat/themes"
lf_dir="$HOME/.config/lf"
micro_dir="$HOME/.config/micro/colorschemes"
helix_dir="$HOME/.config/helix/themes"
zellij_dir="$HOME/.config/zellij/themes"
k9s_dir="$HOME/.config/k9s"
htop_dir="$HOME/.config/htop"
ranger_dir="$HOME/.config/ranger/colorschemes"
mpv_dir="$HOME/.config/mpv/scripts/themes"
ncmpcpp_dir="$HOME/.config/ncmpcpp"
mako_dir="$HOME/.config/mako"
foot_dir="$HOME/.config/foot/themes"
swaylock_dir="$HOME/.config/swaylock"

ln -sf "$btop_dir/${THEME}.theme" "$btop_dir/current.theme" 2>/dev/null
ln -sf "$tmux_dir/${THEME}.conf" "$tmux_dir/current-theme.conf" 2>/dev/null
ln -sf "$neofetch_dir/${THEME}.conf" "$neofetch_dir/config.conf" 2>/dev/null
ln -sf "$bat_dir/${THEME}.tmTheme" "$bat_dir/current.tmTheme" 2>/dev/null
ln -sf "$lf_dir/colors-${THEME}.conf" "$lf_dir/colors.conf" 2>/dev/null
ln -sf "$micro_dir/${THEME}.ini" "$micro_dir/current-theme.ini" 2>/dev/null
ln -sf "$helix_dir/${THEME}.toml" "$helix_dir/current.toml" 2>/dev/null
ln -sf "$zellij_dir/${THEME}.kdl" "$zellij_dir/current-theme.kdl" 2>/dev/null
ln -sf "$k9s_dir/skin-${THEME}.yaml" "$k9s_dir/skin.yaml" 2>/dev/null
ln -sf "$htop_dir/${THEME}.rc" "$htop_dir/htoprc" 2>/dev/null
ln -sf "$ranger_dir/${THEME}.conf" "$ranger_dir/colorschemes/current.conf" 2>/dev/null
ln -sf "$mpv_dir/${THEME}.lua" "$mpv_dir/current-theme.lua" 2>/dev/null
ln -sf "$ncmpcpp_dir/${THEME}.config" "$ncmpcpp_dir/config" 2>/dev/null
ln -sf "$mako_dir/${THEME}.conf" "$mako_dir/config" 2>/dev/null
ln -sf "$foot_dir/${THEME}.ini" "$foot_dir/current-theme.ini" 2>/dev/null
ln -sf "$swaylock_dir/${THEME}.conf" "$swaylock_dir/config" 2>/dev/null

# Advanced GTK/Qt tricks
# Set GTK font and monospace font
case $THEME in
    forest)
        gsettings set org.gnome.desktop.interface font-name "Inter 11"
        gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 11"
        ;;
    water)
        gsettings set org.gnome.desktop.interface font-name "Cantarell 11"
        gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 11"
        ;;
    desert)
        gsettings set org.gnome.desktop.interface font-name "Fira Sans 11"
        gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 11"
        ;;
esac
# Optionally patch qt5ct/qt6ct color config with sed for accent color
if [ -f "$qt5ct_dir/colors.conf" ]; then
    sed -i "s/^accentColor=.*/accentColor=#88C0D0/" "$qt5ct_dir/colors.conf"
fi
if [ -f "$qt6ct_dir/colors.conf" ]; then
    sed -i "s/^accentColor=.*/accentColor=#88C0D0/" "$qt6ct_dir/colors.conf"
fi

# --- Live reload for every app possible ---

# Kitty (already reloads via SIGUSR1)
# WezTerm (already reloads via cli)
# Alacritty: send SIGUSR1 if running
pgrep -x alacritty | xargs -r kill -SIGUSR1
# Foot: send SIGUSR1 if running
pgrep -x foot | xargs -r kill -SIGUSR1
# btop: send --reload if running
pgrep -x btop && btop --reload &>/dev/null
# tmux: reload config if running
pgrep -x tmux && tmux source-file "$tmux_dir/current-theme.conf"
# ranger: reload colors if running
pgrep -x ranger && ranger --cmd reload &>/dev/null
# nvim: set colorscheme if running (headless)
pgrep -x nvim && nvim --headless "+colorscheme current-theme" +q &>/dev/null
# lazygit: send SIGHUP if running
pgrep -x lazygit | xargs -r kill -SIGHUP
# mako: reload config if running
pgrep -x mako | xargs -r kill -SIGUSR1
# dunst: already restarted above
# waybar: already reloads above
# rofi: no reload needed, picks up theme on next launch
# mpv: reload scripts if running
pgrep -x mpv | xargs -r kill -SIGHUP
# htop: no live reload, restart to pick up config
# neofetch: picks up config on next run
# starship: picks up config on next prompt
# obsidian: may require restart for theme
# swaylock: picks up config on next lock
# ncmpcpp: send USR1 to reload config
pgrep -x ncmpcpp | xargs -r kill -USR1
# bat: picks up theme on next run
# yazi: picks up config on next run
# zathura: send SIGHUP to reload config
pgrep -x zathura | xargs -r kill -SIGHUP
# k9s: send SIGHUP to reload skin
pgrep -x k9s | xargs -r kill -SIGHUP
# micro: picks up theme on next run
# helix: picks up theme on next run
# zellij: send SIGHUP to reload theme
pgrep -x zellij | xargs -r kill -SIGHUP

# --- pywal/pywalfox integration (if available) ---
if command -v wal &>/dev/null; then
    wal -i "$WALLPAPER" --saturate 0.7 --backend auto
    # pywalfox for Firefox
    if command -v pywalfox &>/dev/null; then
        pywalfox update
    fi
fi

# --- VSCode live theme switching ---
if pgrep -x code &>/dev/null; then
    # Reload VSCode window (simulate Ctrl+R via wmctrl/xdotool if available)
    if command -v wmctrl &>/dev/null && command -v xdotool &>/dev/null; then
        for wid in $(wmctrl -lx | awk '/code.Code/ {print $1}'); do
            xdotool windowactivate $wid key ctrl+r
        done
    fi
fi

# --- Firefox live theme switching ---
if pgrep -x firefox &>/dev/null; then
    pkill -HUP firefox
fi

# --- Logging ---
echo "[set_theme.sh] Theme switched to $THEME and all apps reloaded."

notify-send "Theme Switch" "Activated $THEME theme" 