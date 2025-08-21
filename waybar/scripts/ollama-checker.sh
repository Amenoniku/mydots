#!/bin/bash

# Проверяем, передан ли аргумент "stop"
if [ "$1" == "stop" ]; then
    # Получаем список всех запущенных моделей и останавливаем каждую
    for model in $(ollama ps | awk 'NR>1 {print $1}'); do
        ollama stop "$model" > /dev/null 2>&1
    done
    exit 0
fi

# Получаем список запущенных моделей
running_models=$(ollama ps | awk 'NR>1')

if [ -n "$running_models" ]; then
    model_count=$(echo "$running_models" | wc -l)
    # Если есть запущенные модели, формируем tooltip
    tooltip="Active models:\n"
    tooltip+=$(echo "$running_models" | awk '{print "- " $1}')
    
    # Выводим JSON для Waybar
    # Предполагается, что иконка ollama.svg находится в ~/.config/waybar/scripts/
    echo "{\"text\": \" 󰧑 : $model_count\", \"tooltip\": \"$tooltip\", \"class\": \"active\"}"

else
    # Если нет запущенных моделей, выводим пустую строку
    echo ""
fi