#!/usr/bin/env bash
# gpu_status.sh — выводит для каждой NVIDIA-GPU: «спит» или «активна»

# Функция проверки одной GPU
check_gpu() {
    local devpath=$1
    local name

    # Попробуем прочитать описание устройства
    name=$(sed -n 's/^.* \[\(.*\)\]$/\1/p' /sys/bus/pci/devices/"$devpath"/uevent 2>/dev/null)
    [ -z "$name" ] && name="$devpath"

    if [[ -r /sys/bus/pci/devices/"$devpath"/power/runtime_status ]]; then
        status=$(< /sys/bus/pci/devices/"$devpath"/power/runtime_status)
        case "$status" in
            suspended) echo "GPU $name ($devpath): спит" ;;
            active)    echo "GPU $name ($devpath): активна" ;;
            *)         echo "GPU $name ($devpath): статус '$status'" ;;
        esac
    else
        # fallback: проверим через nvidia-smi
        if command -v nvidia-smi >/dev/null && nvidia-smi &>/dev/null; then
            echo "GPU $name ($devpath): активна (nvidia-smi OK)"
        else
            echo "GPU $name ($devpath): спит или драйвер недоступен"
        fi
    fi
}

# Основной цикл: ищем все устройства с vendor 0x10de (NVIDIA)
for path in /sys/bus/pci/devices/*; do
    dev=$(basename "$path")
    if [[ -r $path/vendor ]] && grep -q '^0x10de$' "$path/vendor"; then
        check_gpu "$dev"
    fi
done
