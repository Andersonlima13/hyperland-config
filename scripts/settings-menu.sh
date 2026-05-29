#!/bin/bash
# =========================================================
# SETTINGS MENU — wofi-based (Hyprland / Wayland)
# Salve em: ~/.config/hypr/scripts/settings-menu.sh
# chmod +x ~/.config/hypr/scripts/settings-menu.sh
# =========================================================

MENU=$(printf "  Rede\n  Bluetooth\n  Áudio\n  Display / Monitores\n  Tema GTK\n  Teclado e Mouse\n  Wallpaper\n  Fonte de Energia\n  Monitor de Sistema\n  Editar Hyprland.conf\n  Editar Waybar\n  Reiniciar Waybar\n  Sair / Logout" \
  | wofi --dmenu \
         --prompt "Configurações" \
         --width 420 \
         --height 520 \
         --location center \
         --style "$HOME/.config/wofi/settings-style.css" \
         --cache-file /dev/null)

case "$MENU" in
  "  Rede")
        # Tenta nm-connection-editor; fallback para nm-applet
        if command -v nm-connection-editor &>/dev/null; then
            nm-connection-editor
        else
            notify-send "Rede" "Instale: sudo apt install network-manager-gnome"
        fi
        ;;
  "  Bluetooth")
        blueman-manager
        ;;
  "  Áudio")
        pavucontrol
        ;;
  "  Display / Monitores")
        # wdisplays é o melhor para Wayland
        if command -v wdisplays &>/dev/null; then
            wdisplays
        elif command -v nwg-displays &>/dev/null; then
            nwg-displays
        else
            notify-send "Display" "Instale: sudo apt install wdisplays"
        fi
        ;;
  "  Tema GTK")
        if command -v nwg-look &>/dev/null; then
            nwg-look
        else
            notify-send "Tema GTK" "Instale: nwg-look\nhttps://github.com/nwg-piotr/nwg-look"
        fi
        ;;
  "  Teclado e Mouse")
        if command -v gnome-control-center &>/dev/null; then
            gnome-control-center keyboard
        else
            notify-send "Teclado" "Edite kb_layout no hyprland.conf"
        fi
        ;;
  "  Wallpaper")
        # Abre seletor de arquivo para escolher wallpaper
        IMG=$(zenity --file-selection \
                     --title="Escolha o Wallpaper" \
                     --file-filter="Imagens | *.jpg *.jpeg *.png *.webp" \
                     2>/dev/null)
        if [ -n "$IMG" ]; then
            pkill swaybg
            swaybg -i "$IMG" -m fill &
            # Salva o caminho para persistir no próximo login
            sed -i "s|swaybg -i .* -m fill|swaybg -i $IMG -m fill|" \
                "$HOME/.config/hypr/hyprland.conf"
            notify-send "Wallpaper" "Wallpaper alterado com sucesso!"
        fi
        ;;
  "  Fonte de Energia")
        if command -v gnome-power-manager &>/dev/null; then
            gnome-power-manager
        else
            notify-send "Energia" "Instale: sudo apt install gnome-power-manager"
        fi
        ;;
  "  Monitor de Sistema")
        if command -v gnome-system-monitor &>/dev/null; then
            gnome-system-monitor
        else
            kitty -e htop
        fi
        ;;
  "  Editar Hyprland.conf")
        # Abre no editor de texto padrão
        EDITOR_APP=${VISUAL:-${EDITOR:-nano}}
        if command -v gedit &>/dev/null; then
            gedit "$HOME/.config/hypr/hyprland.conf"
        elif command -v kate &>/dev/null; then
            kate "$HOME/.config/hypr/hyprland.conf"
        else
            kitty -e $EDITOR_APP "$HOME/.config/hypr/hyprland.conf"
        fi
        ;;
  "  Editar Waybar")
        EDITOR_APP=${VISUAL:-${EDITOR:-nano}}
        if command -v gedit &>/dev/null; then
            gedit "$HOME/.config/waybar/config"
        else
            kitty -e $EDITOR_APP "$HOME/.config/waybar/config"
        fi
        ;;
  "  Reiniciar Waybar")
        pkill waybar && waybar &
        notify-send "Waybar" "Waybar reiniciado!"
        ;;
  "  Sair / Logout")
        CONFIRM=$(printf "  Logout\n  Suspender\n  Reiniciar\n  Desligar" \
          | wofi --dmenu --prompt "Confirmar?" --width 300 --height 250 \
                 --location center --cache-file /dev/null \
                 --style "$HOME/.config/wofi/settings-style.css")
        case "$CONFIRM" in
          "  Logout")    hyprctl dispatch exit ;;
          "  Suspender") systemctl suspend ;;
          "  Reiniciar") systemctl reboot ;;
          "  Desligar")  systemctl poweroff ;;
        esac
        ;;
esac
