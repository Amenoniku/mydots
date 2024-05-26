#!/bin/bash

getActiveMonitor() {
  monitors_info=$(hyprctl monitors)

  cursor_x=$(hyprctl cursorpos | cut -d',' -f1)
  monitor_id=''

  active_monitor=''
  while IFS= read -r line; do
    if [ "$(echo "$line" | grep -c 'Monitor')" -gt 0 ]; then
      monitor_id=$(echo "$line" | cut -d' ' -f2)
    fi
    if [ "$(echo "$line" | grep -c ' at ')" -gt 0 ]; then
      monitor_x=$(echo "$line" | grep -o '^[^x]*')
      monitor_w=$(echo "$line" | grep -oP 'at \K[0-9]+')
      if [ "$cursor_x" -lt $((monitor_x + monitor_w)) ]; then
        active_monitor="$monitor_id"
        break
      fi
    fi
  done <<< "$monitors_info"
  echo "$active_monitor"
}

takeScreenshot() {
  screenshotName=~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png
  monitor=$(getActiveMonitor)
  grim -o "$monitor" /tmp/full_screenshot.png
  feh -T null --image-bg black --fullscreen --scale-down -x /tmp/full_screenshot.png &
  grim -g "$(slurp)" -t png - | tee /tmp/selected_screenshot.png | wl-copy
  cp /tmp/selected_screenshot.png "$screenshotName"
  dunstify -i "$screenshotName" "Screenshot of the region taken" -t 1000
  pkill feh
  swappy -f "$screenshotName"

  echo "$screenshotName"
}

takeScreenshot