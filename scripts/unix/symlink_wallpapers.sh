#!/bin/bash

SRC="$(dirname "$0")/../../media/wallpapers"
DEST="$HOME/Pictures/Wallpapers"

if [ ! -L "$DEST" ] && [ ! -d "$DEST" ]; then
    mkdir -p "$(dirname "$DEST")"
    ln -s "$SRC" "$DEST"
    echo "Symlinked $SRC to $DEST"
else
    echo "$DEST already exists or is a symlink."
fi 