#!/bin/bash
OPCAO=$(printf "  Logout\n  Suspender\n  Reiniciar\n  Desligar" \
  | wofi --dmenu \
         --prompt "Energia" \
         --width 300 \
         --height 280 \
         --location center \
         --cache-file /dev/null \
         --style "$HOME/.config/wofi/settings-style.css")

case "$OPCAO" in
  "  Logout")    hyprctl dispatch exit ;;
  "  Suspender") systemctl suspend ;;
  "  Reiniciar") systemctl reboot ;;
  "  Desligar")  systemctl poweroff ;;
esac
