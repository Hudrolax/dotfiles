#!/usr/bin/env bash
# usage: pin.sh <app_id|process> <icon>

APP="$1"          # пример: "google-chrome-stable"
ICON="$2"         # пример: ""

# ▸  Смотрим, есть ли окно нужного класса в Hyprland …
if hyprctl clients -j | grep -q "\"class\":\"$APP\"" ; then
    # …или, попроще, процесс:
    # if pgrep -x "$APP" >/dev/null ; then
    echo "{\"text\":\"$ICON\",\"class\":\"running\"}"
else
    echo "{\"text\":\"$ICON\"}"
fi
