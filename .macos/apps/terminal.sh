#!/usr/bin/env bash

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Disable the annoying line marks
defaults write com.apple.Terminal ShowLineMarks -int 0

# Don't display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Use a modified version of the Solarized Dark theme by default in Terminal.app
THEME_PATH="${HOME}/init/Solarized Dark xterm-256color.terminal"
ITERM_THEME_PATH="${HOME}/init/Solarized Dark.itermcolors"

# Create init directory if it doesn't exist
mkdir -p "${HOME}/init"

# Download themes if they don't exist
if [ ! -f "$THEME_PATH" ]; then
    curl -o "$THEME_PATH" "https://raw.githubusercontent.com/tomislav/osx-terminal.app-colors-solarized/master/Solarized%20Dark%20xterm-256color.terminal"
fi

if [ ! -f "$ITERM_THEME_PATH" ]; then
    curl -o "$ITERM_THEME_PATH" "https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors"
fi

# Apply Terminal.app theme
if [ -f "$THEME_PATH" ]; then
    osascript <<EOD
tell application "Terminal"
    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    set themeName to "Solarized Dark xterm-256color"

    (* Store the IDs of all the open terminal windows. *)
    set initialOpenedWindows to id of every window

    (* Open the custom theme so that it gets added to the list
       of available terminal themes (note: this will open two
       additional terminal windows). *)
    do shell script "open '$THEME_PATH'"

    (* Wait a little bit to ensure that the custom theme is added. *)
    delay 1

    (* Set the custom theme as the default terminal theme. *)
    set default settings to settings set themeName

    (* Get the IDs of all the currently opened terminal windows. *)
    set allOpenedWindows to id of every window

    repeat with windowID in allOpenedWindows
        (* Close the additional windows that were opened in order
           to add the custom theme to the list of terminal themes. *)
        if initialOpenedWindows does not contain windowID then
            close (every window whose id is windowID)
        else
            (* Change the theme for the initial opened terminal windows
               to remove the need to close them in order for the custom
               theme to be applied. *)
            set current settings of tabs of (every window whose id is windowID) to settings set themeName
        end if
    end repeat
end tell
EOD
else
    echo "Warning: Terminal theme file not found at $THEME_PATH"
fi

# Install the Solarized Dark theme for iTerm
if [ -f "$ITERM_THEME_PATH" ]; then
    open "$ITERM_THEME_PATH"
else
    echo "Warning: iTerm theme file not found at $ITERM_THEME_PATH"
fi 