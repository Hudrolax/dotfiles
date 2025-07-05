#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────
# 0) Где лежит конфиг ‒ массив объектов { "name": "...", "delay": N }
# ────────────────────────────────────────────────────────────────
CFG_FILE="${WS_FREEZER_CFG:-$HOME/.config/hypr/scripts/ws-freezer.json}"

# ────────────────────────────────────────────────────────────────
# 1) Загрузка конфигурации (глобальная переменная `config`)
# ────────────────────────────────────────────────────────────────
config='[]'
load_config() {
  if [[ -f $CFG_FILE ]] && jq -e . "$CFG_FILE" >/dev/null 2>&1; then
    config=$(jq -c . "$CFG_FILE")
    echo "[ws-freezer] config reloaded @ $(date +%T)"
  else
    echo "[ws-freezer] ⚠  $CFG_FILE missing or invalid – using empty list" >&2
    config='[]'
  fi
}
load_config

# слежение за изменениями (фоновый процесс)
command -v inotifywait >/dev/null || { echo "install inotify-tools" >&2; exit 1; }
inotifywait -mq -e close_write "$(dirname "$CFG_FILE")" 2>/dev/null |
  while read -r _; do load_config; done &

# ────────────────────────────────────────────────────────────────
# 2) Определяем socket2 Hyprland
# ────────────────────────────────────────────────────────────────
RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID}
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  SOCK="$RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
else
  SOCK=$(find "$RUNTIME_DIR/hypr" -maxdepth 2 -name '.socket2.sock' | head -n1)
fi
[[ -S $SOCK ]] || { echo "[ws-freezer] socket2 not found" >&2; exit 1; }

# ────────────────────────────────────────────────────────────────
# 3) Ассоциативный массив: pid процесса → pid sleep-таймера
# ────────────────────────────────────────────────────────────────
declare -A freeze_jobs

# ────────────────────────────────────────────────────────────────
# 4) Вспомогательные функции
# ────────────────────────────────────────────────────────────────
get_delay() { jq -r --arg n "$1" '.[]|select(.name==$n)|.delay//empty' <<<"$config"; }
should_freeze() { [[ $(get_delay "$1") =~ ^[0-9]+$ ]]; }

schedule_freeze() {               # schedule_freeze <pid> <delay>
  local pid=$1 delay=$2
  [[ -n ${freeze_jobs[$pid]:-} ]] && return           # таймер уже есть
  (
    sleep "$delay"
    kill -STOP "$pid" 2>/dev/null || true
  ) &
  freeze_jobs[$pid]=$!
}

cancel_freeze() {                 # cancel_freeze <pid>
  local pid=$1 job=${freeze_jobs[$pid]:-}
  [[ -n $job ]] && kill "$job" 2>/dev/null || true
  unset freeze_jobs[$pid]
  kill -CONT "$pid" 2>/dev/null || true
}

# ────────────────────────────────────────────────────────────────
# 5) Основная логика при смене рабочего пространства
# ────────────────────────────────────────────────────────────────
handle_ws_change() {
  local active_ws=$1
  declare -A ws_pids=()

  # собираем pid по рабочим пространствам
  while read -r cl; do
    local ws pid
    ws=$(jq '.workspace.id' <<<"$cl")
    pid=$(jq '.pid'         <<<"$cl")
    ws_pids[$ws]="${ws_pids[$ws]:-} $pid"
  done < <(hyprctl -j clients 2>/dev/null | jq -c '.[]')

  for ws in "${!ws_pids[@]}"; do
    for pid in ${ws_pids[$ws]}; do
      if comm=$(ps -p "$pid" -o comm= 2>/dev/null); then
        if should_freeze "$comm"; then
          if [[ $ws -eq $active_ws ]]; then
            cancel_freeze "$pid"
          else
            schedule_freeze "$pid" "$(get_delay "$comm")"
          fi
        fi
      fi
    done
  done
}

# ────────────────────────────────────────────────────────────────
# 6) «Усыпляем» уже скрытые WS при запуске
# ────────────────────────────────────────────────────────────────
CUR_WS=$(hyprctl -j activeworkspace | jq '.id') || CUR_WS=0
handle_ws_change "$CUR_WS"

# ────────────────────────────────────────────────────────────────
# 7) Слушаем события socket2
# ────────────────────────────────────────────────────────────────
socat -u UNIX-CONNECT:"$SOCK" STDOUT |
  while read -r line; do
    [[ ${line%%>>*} == "workspace" ]] && handle_ws_change "${line##*>>}"
  done
