#!/usr/bin/env bash

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo"
    exit 1
fi

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is only for macOS"
    exit 1
fi

# Function to handle errors
handle_error() {
    local app="$1"
    echo "Error occurred while configuring $app. Continuing with other apps..."
}

# Function to safely kill applications
kill_app() {
    local app="$1"
    if pgrep -x "$app" >/dev/null; then
        killall "$app" &>/dev/null || true
        sleep 1
    fi
}

# Create necessary directories
mkdir -p "${HOME}/Library/Preferences"
mkdir -p "${HOME}/init"

# Source all app-specific configuration files in order
declare -a config_files=(
    "system.sh"      # System settings should be first
    "finder.sh"      # Finder settings
    "dock.sh"        # Dock settings
    "safari.sh"      # Safari settings
    "chrome.sh"      # Chrome settings
    "terminal.sh"    # Terminal settings
    "mail.sh"        # Mail settings
    "spotlight.sh"   # Spotlight settings should be last
)

# Source each configuration file
for config in "${config_files[@]}"; do
    config_path="${HOME}/.macos/apps/$config"
    if [ -f "$config_path" ]; then
        echo "Applying settings from $config..."
        if ! source "$config_path"; then
            handle_error "${config%.*}"
        fi
    else
        echo "Warning: Configuration file $config not found"
    fi
done

# Kill affected applications to apply changes
echo "Restarting applications to apply changes..."

declare -a apps_to_restart=(
    "Activity Monitor"
    "Address Book"
    "Calendar"
    "cfprefsd"
    "Contacts"
    "Dock"
    "Finder"
    "Google Chrome"
    "Mail"
    "Messages"
    "Photos"
    "Safari"
    "SystemUIServer"
    "Terminal"
)

for app in "${apps_to_restart[@]}"; do
    kill_app "$app"
done

echo "Done. Note that some of these changes require a logout/restart to take effect."
echo "Please save your work and restart your computer for all changes to take effect." 