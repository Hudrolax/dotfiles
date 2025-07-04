#!/bin/bash

hyprctl clients -j | jq -r '.[].pid' | while read -r pid; do
  node=$(ls -l /proc/$pid/fd 2>/dev/null | awk '/\/dev\/dri\/render/{print $NF; exit}')
  [[ -z $node ]] && continue                        # нет 3D-рендера
  # путь в sysfs вида /devices/.../0000:01:00.0/drm/renderD129
  sys=$(udevadm info -q path -n "$node")
  pci=$(echo "$sys" | grep -oE '[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-7]')
  name=$(lspci -s "$pci" | cut -d':' -f3- | sed 's/^ //')
  printf "%-7s %-20s → %s\n" "$pid" "$(ps -p $pid -o comm=)" "$name"
done
