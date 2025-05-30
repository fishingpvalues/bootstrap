#!/bin/bash\n\n# If this script is meant to operate on user config, keep $HOME/.config/.
# If it is meant to operate on repo files, use dot_config/ for chezmoi compatibility.

THEME_FILE="$HOME/.config/.current_theme"\nTHEMES=(forest water desert)\nCUR=$(cat "$THEME_FILE" 2>/dev/null)\nIDX=0\nfor i in "${!THEMES[@]}"; do [[ "${THEMES[$i]}" == "$CUR" ]] && IDX=$i; done\nNEXT_IDX=$(( (IDX + 1) % ${#THEMES[@]} ))\nNEXT_THEME=${THEMES[$NEXT_IDX]}\necho "$NEXT_THEME" > "$THEME_FILE"\nnotify-send "Theme Switch" "Activated $NEXT_THEME theme" 