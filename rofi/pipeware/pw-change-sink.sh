#!/bin/bash

dir="$HOME/.config/rofi"
theme='style-1'

currentSinkId=$(pactl list short sinks |
  awk -v currentSink="$(pactl get-default-sink)" '{
    if ($2 == currentSink) {
      print $1
    }
  }'
)

sinksDescriptions=$(pactl list sinks |
  grep -E 'Sink #|Description:' |
  sed 's/Sink #//; N; s/\n//; s/\s\+/ /g; s/Description: //' |
  awk -v currentSink="$currentSinkId" '{
    if ($1 == currentSink) {
      print " " $0
    } else {
      print $0
    }
  }'
)


chosenSinkId=$(echo "$sinksDescriptions" | rofi -dmenu -i -theme "${dir}"/${theme}.rasi -p '󰽰' | awk '{print $1}')

if [ -n "$chosenSinkId" ]; then
  pactl set-default-sink "$chosenSinkId"
  currentSinkInputs=$(pactl list short sink-inputs | awk '{print $1}')
  for sinkInput in $currentSinkInputs; do
    pactl move-sink-input "$sinkInput" "$chosenSinkId"
  done
fi
