#!/usr/bin/env bash

# =============================================
# Конфигурация скрипта для загрузки обоев
# =============================================

# Параметры API Wallhaven
readonly API_URL="https://wallhaven.cc/api/v1/search"
readonly API_KEY="nEVL4198MXFWxnlfqV8UBrtpNG2rLyNb" # В продакшене лучше использовать переменные окружения

# Параметры поиска обоев
readonly QUERY="+artwork +illustration +cyberpunk -gore"
readonly RESOLUTION="1920x1080"                              # Желаемое разрешение
readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers/wallhaven" # Папка для хранения обоев

# Конфигурация мониторов
readonly MONITORS=("DP-3" "HDMI-A-1") # Массив мониторов для удобства масштабирования

# =============================================
# Функции скрипта
# =============================================

# Функция для создания директории, если она не существует
ensure_directory_exists() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir" || {
      echo "Ошибка: не удалось создать директорию $dir" >&2
      return 1
    }
  fi
}

# Функция для безопасного кодирования URL параметров
urlencode() {
  local string="$1"
  local length="${#string}"
  local encoded=""
  local pos char

  for ((pos = 0; pos < length; pos++)); do
    char="${string:$pos:1}"
    case "$char" in
    [a-zA-Z0-9.~_-]) encoded+="$char" ;;
    " ") encoded+="%20" ;;
    *) encoded+=$(printf '%%%02X' "'$char") ;;
    esac
  done
  echo "$encoded"
}

# Функция для скачивания случайных обоев
download_random_wallpaper() {
  local output_dir="$1"
  local encoded_query
  encoded_query=$(urlencode "$QUERY") || return 1

  # Формируем параметры запроса
  local api_params=(
    "q=$encoded_query"
    "categories=100"
    "resolutions=$RESOLUTION"
    "ratios=16x9"
    "sorting=random"
    "purity=100"
    "apikey=$API_KEY"
    "ai_art_filter=0"
    "colors=000000"
  )

  # Выполняем запрос к API
  local response
  response=$(curl -s "${API_URL}?$(
    IFS='&'
    echo "${api_params[*]}"
  )") || {
    echo "Ошибка: не удалось выполнить запрос к API Wallhaven" >&2
    return 1
  }

  # Извлекаем URL обоев
  local wallpaper_url
  wallpaper_url=$(jq -r '.data[0].path' <<<"$response") || {
    echo "Ошибка: не удалось разобрать ответ API" >&2
    return 1
  }

  if [[ -z "$wallpaper_url" || "$wallpaper_url" == "null" ]]; then
    echo "Ошибка: не удалось получить URL обоев. Попробуйте позже или смените тему." >&2
    return 1
  fi

  # Скачиваем обои
  local filename output_path
  filename=$(basename "$wallpaper_url")
  output_path="$output_dir/$filename"

  if ! wget -q "$wallpaper_url" -O "$output_path"; then
    echo "Ошибка: не удалось скачать обои" >&2
    return 1
  fi

  echo "$output_path"
}

# Функция для получения случайного файла из локальной директории
get_local_random_wallpaper() {
  local dir="$1"
  find "$dir" -type f -print0 | shuf -zn1 | tr -d '\0'
}

# Функция для установки обоев на мониторы
set_wallpapers() {
  local wallpapers=("$@")
  hyprctl hyprpaper unload all

  for i in "${!wallpapers[@]}"; do
    local wallpaper="${wallpapers[$i]}"
    local monitor="${MONITORS[$i]}"

    if [[ -n "$wallpaper" && -n "$monitor" ]]; then
      hyprctl hyprpaper preload "$wallpaper"
      hyprctl hyprpaper wallpaper "$monitor,contain:$wallpaper"
      echo "${monitor} -> $(basename "$wallpaper")"
    fi
  done
}

# =============================================
# Основная логика скрипта
# =============================================

main() {
  # Проверяем и создаем директорию для обоев
  ensure_directory_exists "$WALLPAPER_DIR" || exit 1

  # Массив для хранения путей к обоям
  local wallpapers=()

  # Пытаемся скачать новые обои
  for ((i = 0; i < ${#MONITORS[@]}; i++)); do
    local wallpaper
    wallpaper=$(download_random_wallpaper "$WALLPAPER_DIR") || {
      echo "Используем локальные обои для монитора ${MONITORS[$i]}" >&2
      wallpaper=$(get_local_random_wallpaper "$WALLPAPER_DIR")
    }
    wallpapers+=("$wallpaper")
  done

  # Устанавливаем обои на мониторы
  echo "Устанавливаем обои:"
  set_wallpapers "${wallpapers[@]}"
}

main "$@"
