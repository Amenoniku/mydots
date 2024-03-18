#!/bin/bash

# Получаем информацию о звуковых устройствах и текущем выбранном устройстве с помощью wpctl
audio_info=$(wpctl status | awk '/├─ Sinks:,/^$/' | sed '1d')
current_sink=$(echo "$audio_info" | grep -oP '\*\s+\K\S+$' | sed 's/[^0-9]*//g')

# Создаем массив с информацией о звуковых устройствах
readarray -t sinks <<< "$(echo "$audio_info" | grep -oP '^\s+\d+\.\s+\K.*')"

# Формируем список для rofi, помечая текущий выбранный звуковой источник звездочкой
rofi_list=""
for sink in "${sinks[@]}"; do
    sink_id=$(echo "$sink" | awk '{print $1}')
    sink_name=$(echo "$sink" | awk '{$1=""; print $0}')
    if [[ $sink_id -eq $current_sink ]]; then
        rofi_list+="* $sink_name\n"
    else
        rofi_list+="$sink_id $sink_name\n"
    fi
done

# Выводим список в rofi и получаем выбранный пункт
chosen_sink=$(echo -e "$rofi_list" | rofi -dmenu -p "Выберите звуковой источник" | awk '{print $1}')

# Если выбран какой-то пункт (а не отмена), то устанавливаем его как новый звуковой источник
if [[ -n $chosen_sink ]]; then
    wpctl set-default $chosen_sink
fi

