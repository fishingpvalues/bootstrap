#!/usr/bin/env bash

# Check if running on macOS 10.15 (Catalina) or later
if [[ $(sw_vers -productVersion | cut -d. -f1) -ge 11 ]] || [[ $(sw_vers -productVersion | cut -d. -f2) -ge 15 ]]; then
    echo "Note: Some Spotlight settings might need manual configuration on macOS Catalina and later"
fi

# Hide Spotlight tray-icon (and subsequent helper)
#sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

# Safely disable Spotlight indexing for any volume
disable_spotlight_indexing() {
    local volume="$1"
    if [ -d "$volume" ]; then
        sudo mdutil -i off "$volume" 2>/dev/null || true
    fi
}

# Disable Spotlight indexing for any volume that gets mounted
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

# Change indexing order and disable some search results
# Yosemite-specific search results:
# MENU_DEFINITION
# MENU_CONVERSION
# MENU_EXPRESSION
# MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
# MENU_WEBSEARCH             (send search queries to Apple)
# MENU_OTHER
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 1;"name" = "FONTS";}' \
	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
	'{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "CONTACT";}' \
	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "IMAGES";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# Safely restart the Spotlight service
restart_spotlight() {
	# Kill metadata server to restart indexing
	killall mds &>/dev/null || true
	
	# Wait for the service to restart
	sleep 2
	
	# Enable indexing for the main volume
	sudo mdutil -i on / &>/dev/null || true
	
	# Rebuild index if needed (this can take a while)
	if [ "$1" = "rebuild" ]; then
		sudo mdutil -E / &>/dev/null || true
	fi
}

# Apply settings
restart_spotlight "rebuild"

# Disable indexing for any currently mounted external volumes
for volume in /Volumes/*; do
	disable_spotlight_indexing "$volume"
done 