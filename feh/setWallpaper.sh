#!/bin/bash

# Скрипт для установки обоев в Hyprland через feh action
# Использование: feh -A ";[Set Wallpaper] path/to/script.sh %F [monitor_name]"

set -o errexit
set -o nounset
set -o pipefail

# ===== Конфигурация =====
readonly WALLPAPER_DIR="${HOME}/.config/hypr/walls"
readonly OUTPUT_RESOLUTION="1920:1080"
readonly FFMPEG_QUALITY=2
readonly DEFAULT_MONITOR="DP-3"

# ===== Проверка зависимостей =====
check_dependencies() {
    local dependencies=("ffmpeg" "hyprctl" "dunstify")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            dunstify "Error: ${cmd} not installed"
            exit 127
        fi
    done
}

# ===== Основная функция =====
main() {
    check_dependencies

    local wallpaper_file="${1:-}"
    local monitor="${2:-${DEFAULT_MONITOR}}"

    [[ -f "${wallpaper_file}" ]] || {
        dunstify "Error" "File not found: ${wallpaper_file}"
        exit 1
    }

    mkdir -p "${WALLPAPER_DIR}"
    
    # Фиксированное имя файла для монитора
    local output_file="${WALLPAPER_DIR}/${monitor}.jpg"

    # Конвертация с заменой файла
    ffmpeg -v error -y -i "${wallpaper_file}" \
        -vf "scale=${OUTPUT_RESOLUTION}:force_original_aspect_ratio=decrease" \
        -q:v "${FFMPEG_QUALITY}" \
        "${output_file}"

    # Установка обоев
    hyprctl hyprpaper preload "${wallpaper_file}" >/dev/null
    hyprctl hyprpaper wallpaper "${monitor},contain:${wallpaper_file}" >/dev/null

    dunstify "Wallpaper Set" "Monitor: ${monitor}" -i "${wallpaper_file}"
}

main "$@"