#!/bin/bash

OPTIONS="Logout\nSuspend\nReboot\nShutdown"

chosen=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power Menu:")

case "$chosen" in
    "Logout")
        hyprctl dispatch exit 0
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac

exit 0 