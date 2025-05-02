#!/usr/bin/env bash

###############################################################################
# Finder                                                                      #
###############################################################################

# Ensure the Preferences directory exists
PREFS_DIR="${HOME}/Library/Preferences"
mkdir -p "$PREFS_DIR"

# Function to safely run PlistBuddy commands
run_plistbuddy() {
    local plist="$1"
    local command="$2"
    local default="$3"
    
    # Create plist if it doesn't exist
    if [ ! -f "$plist" ]; then
        /usr/libexec/PlistBuddy -c "Save" "$plist" 2>/dev/null
    fi
    
    # Run the command
    if ! /usr/libexec/PlistBuddy -c "$command" "$plist" 2>/dev/null; then
        # If the command failed, try to create the entry with a default value
        if [ -n "$default" ]; then
            /usr/libexec/PlistBuddy -c "Add :$command $default" "$plist" 2>/dev/null
        fi
    fi
}

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null || true

# Show the /Volumes folder
sudo chflags nohidden /Volumes || true

# Expand the following File Info panes:
# "General", "Open with", and "Sharing & Permissions"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true 

# Set up Finder view settings
FINDER_PLIST="$PREFS_DIR/com.apple.finder.plist"

# Show item info near icons on the desktop and in other icon views
run_plistbuddy "$FINDER_PLIST" "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" "bool"
run_plistbuddy "$FINDER_PLIST" "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" "bool"
run_plistbuddy "$FINDER_PLIST" "Set :StandardViewSettings:IconViewSettings:showItemInfo true" "bool"

# Show item info to the right of the icons on the desktop
run_plistbuddy "$FINDER_PLIST" "Set :DesktopViewSettings:IconViewSettings:labelOnBottom false" "bool"

# Enable snap-to-grid for icons
run_plistbuddy "$FINDER_PLIST" "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" "string"
run_plistbuddy "$FINDER_PLIST" "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" "string"
run_plistbuddy "$FINDER_PLIST" "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" "string"

# Set grid spacing
run_plistbuddy "$FINDER_PLIST" "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" "integer"
run_plistbuddy "$FINDER_PLIST" "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" "integer"
run_plistbuddy "$FINDER_PLIST" "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" "integer"

# Set icon size
run_plistbuddy "$FINDER_PLIST" "Set :DesktopViewSettings:IconViewSettings:iconSize 80" "integer"
run_plistbuddy "$FINDER_PLIST" "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" "integer"
run_plistbuddy "$FINDER_PLIST" "Set :StandardViewSettings:IconViewSettings:iconSize 80" "integer"

# Kill Finder to apply changes
killall Finder &>/dev/null || true 