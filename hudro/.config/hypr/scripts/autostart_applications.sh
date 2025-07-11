#!/usr/bin/env bash
set -euo pipefail

# Куда складываем логи
logdir="$HOME/.local/log/autostart"
mkdir -p "$logdir"

# Команды — каждая в одинарных кавычках
scripts=(
  'hyprctl dispatch exec "[workspace 1 silent] chromium --app=https://chat.openai.com"'
  'hyprctl dispatch exec "[workspace 2 silent] firefox"'
  'hyprctl dispatch exec "[workspace 3 silent] alacritty"'
  'hyprctl dispatch exec "[workspace 4 silent] obsidian"'
  'keepassxc'
  'hyprctl dispatch exec "[workspace 1 silent] kdeconnect-app"'
)

for cmd in "${scripts[@]}"; do
  # Имя лога: первая «полезная» команда без параметров, без «/»
  logname=$(printf '%s\n' "$cmd" | awk '{print $NF}' | sed 's/[^[:alnum:]_.-]/_/g')
  logfile="$logdir/$logname.log"

  # Новая сессия, без tty, вывод в лог
  setsid bash -c "$cmd" </dev/null >>"$logfile" 2>&1 &
done
