#!/usr/bin/env bash
# ----------------------------------------------------------------------
#  setup-lid-suspend.sh
#
#  • Включает переход в suspend при закрытии крышки (и на питании, и на батарее)
#  • Создаёт/обновляет user-unit, который:
#        – ставит все MPRIS-плееры на паузу
#        – выключает DPMS
#        – запускает hyprlock
#
#  Скрипт аккуратно правит только нужные строки, делает резервную копию
#  logind.conf, запрашивает sudo лишь при необходимости и безопасен
#  при повторных запусках.
# ----------------------------------------------------------------------
set -euo pipefail

# ---------- 1. Пробуем беспарольный sudo, иначе запрашиваем -----------------
if ! sudo -n true 2>/dev/null; then
    echo "⏳  Нужен sudo — введите пароль:"
    sudo true
fi

# ---------- 2. Настройка /etc/systemd/logind.conf ---------------------------
LOGIND=/etc/systemd/logind.conf
sudo cp -n "$LOGIND" "${LOGIND}.bak" 2>/dev/null || true   # разово делаем бэкап
changed=0

ensure_key() {      # $1=ключ  $2=значение
    if sudo grep -Eq "^[[:space:]]*$1[[:space:]]*=$2" "$LOGIND"; then
        return      # уже правильно
    fi
    if sudo grep -Eq "^[[:space:]]*$1[[:space:]]*=" "$LOGIND"; then
        sudo sed -Ei "s|^[[:space:]]*$1[[:space:]]*=.*|$1=$2|" "$LOGIND"
    else
        echo "$1=$2" | sudo tee -a "$LOGIND" >/dev/null
    fi
    changed=1
}

ensure_key HandleLidSwitch            suspend
ensure_key HandleLidSwitchExternalPower suspend

if (( changed )); then
    echo "✓ logind.conf обновлён — перезапускаем systemd-logind"
    sudo systemctl restart systemd-logind
else
    echo "• logind.conf уже настроен"
fi

# ---------- 3. Создание / обновление user-unit ------------------------------
UNIT_DIR="$HOME/.config/systemd/user"
UNIT_FILE="$UNIT_DIR/lock-before-sleep.service"
mkdir -p "$UNIT_DIR"

playerctl_line="ExecStart=/usr/bin/playerctl -a pause"
if ! command -v playerctl >/dev/null 2>&1; then
    playerctl_line="# $playerctl_line   # playerctl не найден"
fi

read -r -d '' UNIT_CONTENT <<EOF
[Unit]
Description=Pause media & lock screen before suspend
Before=sleep.target

[Service]
Type=oneshot
$playerctl_line
ExecStart=/usr/bin/hyprctl dispatch dpms off
ExecStartPost=/usr/bin/hyprlock

[Install]
WantedBy=sleep.target
EOF

update_unit=0
if [[ ! -f $UNIT_FILE ]] || ! diff -q <(printf '%s\n' "$UNIT_CONTENT") "$UNIT_FILE" >/dev/null; then
    printf '%s\n' "$UNIT_CONTENT" > "$UNIT_FILE"
    update_unit=1
fi

if (( update_unit )); then
    echo "✓ systemd-unit lock-before-sleep.service создан/обновлён"
else
    echo "• systemd-unit уже актуален"
fi

# ---------- 4. Активация user-unit -----------------------------------------
systemctl --user daemon-reload
systemctl --user enable --now lock-before-sleep.service
echo "✓ lock-before-sleep.service активирован"

# ---------- 5. Финальное сообщение ------------------------------------------
echo -e "\nГотово! При закрытии крышки ноутбук перейдёт в suspend,\nа перед этим музыка поставится на паузу и запустится hyprlock."
