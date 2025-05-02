#!/bin/bash

THEME_FILE="$HOME/.config/.current_theme"
THEMES=(forest water desert)
CUR=$(cat "$THEME_FILE" 2>/dev/null)
IDX=0
for i in "${!THEMES[@]}"; do [[ "${THEMES[$i]}" == "$CUR" ]] && IDX=$i; done
NEXT_IDX=$(( (IDX + 1) % ${#THEMES[@]} ))
NEXT="${THEMES[$NEXT_IDX]}"
"$HOME/scripts/unix/set_theme.sh" "$NEXT"
echo "$NEXT" > "$THEME_FILE"
notify-send "Theme Switch" "Activated $NEXT theme" 