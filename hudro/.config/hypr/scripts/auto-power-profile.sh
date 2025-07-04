#!/bin/bash

# Предыдущее состояние
prev=""

while true; do
    # Определяем статус питания
    state=$(cat /sys/class/power_supply/AC/online)

    if [ "$state" == "1" ] && [ "$prev" != "1" ]; then
        powerprofilesctl set balanced
        prev="1"
    elif [ "$state" == "0" ] && [ "$prev" != "0" ]; then
        powerprofilesctl set power-saver
        prev="0"
    fi

    sleep 5
done
