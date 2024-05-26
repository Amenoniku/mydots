#!/bin/sh

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