#!/usr/bin/env bash

# =============================================
# Конфигурация скрипта для загрузки обоев
# =============================================

# Функция для уведомлений
send_dunst() {
  local text=$1
  local pic=$2
  dunstify -i $pic -a "Обновлятор обоев" -t 3000 "$text"
}

readonly ENV_PATH="$HOME/.config/hypr/scripts/.env"
if [ -f "$ENV_PATH" ]; then
  source $ENV_PATH
else
  send_dunst "Ошибка: файл .env не найден!"
  exit 1
fi

# API Wallhaven
readonly API_URL="https://wallhaven.cc/api/v1/search"

# Параметры поиска обоев
readonly QUERY="+art +artwork -gore -horror -3d -nipples -erotic -boobs -glutes -nude -hentai -bdsm -bottomless -womb-tattoo -cameltoe -vulva -pubic -furry -adult-games -lesbians -VintageFlash -spread-legs -panties-down -v -underboob -body-oil -Keith-P.-Rein -fishnet-bodysuit -Jonathan-Hamilton -Gantz -suicide -upskirt -tan-lines -catsuit -nip-slips -Dandonfuga -swimwear -the-gap -thong -areola-slip -Homura-Akemi -implied-sex -ass -sex -micro-bikini -bikini -see-through-dress -dva -overwatch -pov -anime-girls -anime-boys"
readonly CATEGORIES='111'
readonly AI_ART_FILTER="1"
readonly PURITY="111"
readonly RESOLUTION="1920x1080"
readonly RATIOS="16x9"
readonly SORTING="random"
readonly COLORS="000000"

# Параметры системы
readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers/wallhaven"
readonly MONITORS=("DP-3" "HDMI-A-1")

# =============================================
# Функции скрипта
# =============================================

# Функция для создания директории, если она не существует
ensure_directory_exists() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir" || {
      send_dunst "Ошибка: не удалось создать директорию $dir" >&2
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
    "categories=$CATEGORIES"
    "atleast=$RESOLUTION"
    "ratios=$RATIOS"
    "sorting=$SORTING"
    "purity=$PURITY"
    "ai_art_filter=$AI_ART_FILTER"
    "colors=$COLORS"
    "page=1"
    "limit=2"
    "apikey=$WALLHEVEN_API_KEY"
  )

  # Выполняем запрос к API
  local response
  response=$(curl -s "${API_URL}?$(
    IFS='&'
    echo "${api_params[*]}"
  )") || {
    send_dunst "Ошибка: не удалось выполнить запрос к API Wallhaven" >&2
    return 1
  }

  # Извлекаем URL обоев
  local wallpaper_url
  wallpaper_url=$(jq -r '.data[0].path' <<<"$response") || {
    send_dunst "Ошибка: не удалось разобрать ответ API" >&2
    return 1
  }

  if [[ -z "$wallpaper_url" || "$wallpaper_url" == "null" ]]; then
    send_dunst "Ошибка: не удалось получить URL обоев. Попробуйте позже или смените тему." >&2
    return 1
  fi

  # Скачиваем обои
  local filename output_path
  filename=$(basename "$wallpaper_url")
  output_path="$output_dir/$filename"

  if ! wget -q "$wallpaper_url" -O "$output_path"; then
    send_dunst "Ошибка: не удалось скачать обои" >&2
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
  for i in "${!wallpapers[@]}"; do
    local wallpaper="${wallpapers[$i]}"
    local monitor="${MONITORS[$i]}"

    if [[ -n "$wallpaper" && -n "$monitor" ]]; then
      hyprctl hyprpaper preload "$wallpaper"
      hyprctl hyprpaper wallpaper "$monitor,contain:$wallpaper"
      send_dunst "${monitor} -> $(basename "$wallpaper")" "$wallpaper"
    fi
  done
}
set_wallpaper() {
  local wallpaper=$1
  local monitor=$2
  hyprctl hyprpaper preload "$wallpaper"
  hyprctl hyprpaper wallpaper "$monitor,contain:$wallpaper"
  send_dunst "${monitor} -> $(basename "$wallpaper")" "$wallpaper"
}

# =============================================
# Основная логика скрипта
# =============================================
main() {
  send_dunst "Меняем обои!"
  sleep 2
  ensure_directory_exists "$WALLPAPER_DIR" || exit 1

  local wallpapers=()
  hyprctl hyprpaper unload all

  # Массив для хранения PID фоновых процессов
  local pids=()

  for ((i = 0; i < ${#MONITORS[@]}; i++)); do
    (
      local monitor=${MONITORS[$i]}
      send_dunst "Гружу обоину для ${monitor}..."

      local wallpaper
      wallpaper=$(download_random_wallpaper "$WALLPAPER_DIR") || {
        send_dunst "Используем локальные обои для монитора ${monitor}" >&2
        wallpaper=$(get_local_random_wallpaper "$WALLPAPER_DIR")
      }

      set_wallpaper "$wallpaper" "$monitor"
    ) &        # Запускаем в фоне
    pids+=($!) # Сохраняем PID процесса
  done

  # Ждём завершения всех фоновых процессов
  wait "${pids[@]}"
  send_dunst "Все обои загружены!"
}

# main "$@"
