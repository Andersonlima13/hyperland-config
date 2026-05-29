#!/bin/bash
# =========================================================
# MODO LEITURA — Filtro de luz azul + gamma quente
# Salve em: ~/.config/hypr/scripts/reading-mode.sh
# chmod +x ~/.config/hypr/scripts/reading-mode.sh
#
# Dependência: wlsunset
#   sudo apt install wlsunset
#   (ou compile: https://git.sr.ht/~kennylevinsen/wlsunset)
# =========================================================

STATE_FILE="/tmp/reading-mode.state"
WAYBAR_SIGNAL=8   # pkill -SIGRTMIN+8 waybar  →  atualiza o módulo custom

# ── Verifica dependência ──────────────────────────────────
if ! command -v wlsunset &>/dev/null; then
    notify-send "Modo Leitura" \
        "wlsunset não encontrado.\nInstale: sudo apt install wlsunset" \
        --icon=display-brightness-symbolic
    exit 1
fi

# ── Toggle ────────────────────────────────────────────────
if [ -f "$STATE_FILE" ]; then
    # ── DESATIVAR ────────────────────────────────────────
    rm -f "$STATE_FILE"
    pkill wlsunset 2>/dev/null

    # Restaura gamma neutro (1.0) em todos os monitores
    for output in $(hyprctl monitors -j | python3 -c \
        "import sys,json; [print(m['name']) for m in json.load(sys.stdin)]" 2>/dev/null); do
        wlr-randr --output "$output" --custom-mode \
            "$(hyprctl monitors -j | python3 -c \
            "import sys,json; ms=json.load(sys.stdin); \
             [print(f\"{int(m['width'])}x{int(m['height'])}@{m['refreshRate']:.0f}Hz\") \
              for m in ms if m['name']=='$output']" 2>/dev/null)" 2>/dev/null || true
    done

    notify-send "Modo Leitura" "Desativado 🌙" --icon=weather-clear
    pkill -SIGRTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null

else
    # ── ATIVAR ───────────────────────────────────────────
    touch "$STATE_FILE"

    # wlsunset: temperatura do dia=4000K (tom quente/âmbar)
    # -l/-L = latitude/longitude (não essencial, -t/-T fixam direto)
    # -t = temperatura mínima (noite), -T = temperatura máxima (dia)
    # Com -t e -T iguais, a temperatura fica fixa sem variar por horário
    wlsunset -t 3400 -T 3500 &

    notify-send "Modo Leitura" "Ativado 📖  Luz azul reduzida" \
        --icon=weather-few-clouds
    pkill -SIGRTMIN+$WAYBAR_SIGNAL waybar 2>/dev/null
fi
