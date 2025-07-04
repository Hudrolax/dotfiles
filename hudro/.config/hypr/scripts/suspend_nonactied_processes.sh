#!/usr/bin/env bash
set -eo pipefail

SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Какие приложения замораживать
FREEZE_LIST=("firefox" "chromium" "chrome" "vlc")
DELAY=30

# Хранилище фоновых job’ов (pid процесса -> pid sleep-таймера)
declare -A freeze_jobs=()

# Проверка, нужно ли фризить по имени
should_freeze() {
  local comm="$1"
  for name in "${FREEZE_LIST[@]}"; do
    [[ "$comm" == "$name" ]] && return 0
  done
  return 1
}

# Запланировать заморозку pid через delay секунд
schedule_freeze() {
  local pid=$1 delay=$2
  # если уже есть таймер — ничего не делаем
  [[ -n "${freeze_jobs[$pid]}" ]] && return

  # запускаем sleep в фоне
  ( sleep "$delay"
    # перед фризом проверяем, что процесс до сих пор висит в неактивном WS
    # (тут можно доработать логику проверки по крайней мере: если он ещё жив)
    if ps -p "$pid" > /dev/null; then
      kill -STOP "$pid"
    fi
  ) &
  freeze_jobs[$pid]=$!
}

# Отменить запланированную заморозку и сразу CONT
cancel_freeze() {
  local pid=$1
  local job=${freeze_jobs[$pid]:-}
  if [[ -n "$job" ]]; then
    kill "$job" 2>/dev/null || true
    unset freeze_jobs[$pid]
  fi
  kill -CONT "$pid" 2>/dev/null || true
}

handle_workspace_change() {
  local active_ws=$1

  # Получаем список клиентов
  declare -A ws_pids=()
  while read -r client; do
    ws=$(jq '.workspace.id'   <<<"$client")
    pid=$(jq '.pid'            <<<"$client")
    ws_pids[$ws]="${ws_pids[$ws]} $pid"
  done < <(hyprctl -j clients | jq -c '.[]')

  # Проходим по всем рабочим пространствам и их pid
  for ws in "${!ws_pids[@]}"; do
    for pid in ${ws_pids[$ws]}; do
      # берём имя команды
      if comm=$(ps -p "$pid" -o comm= 2>/dev/null); then
        if should_freeze "$comm"; then
          if [[ $ws -eq $active_ws ]]; then
            # активная WS — отменяем отложенную заморозку + CONT
            cancel_freeze "$pid"
          else
            schedule_freeze "$pid" $DELAY
          fi
        fi
      fi
    done
  done
}

# Слушаем события socket2
socat -u UNIX-CLIENT:"$SOCK" STDOUT \
  | while read -r line; do
      [[ ${line%%>>*} == "workspace" ]] && handle_workspace_change "${line##*>>}"
    done

