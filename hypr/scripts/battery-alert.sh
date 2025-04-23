#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT1"
THRESHOLDS=(20 10 5)
NOTIFIED_LEVEL=100

while true; do
  STATUS=$(cat "$BATTERY_PATH/status")
  CAPACITY=$(cat "$BATTERY_PATH/capacity")

  if [[ "$STATUS" == "Discharging" ]]; then
    for THRESHOLD in "${THRESHOLDS[@]}"; do
      if [[ $CAPACITY -le $THRESHOLD ]] && [[ $NOTIFIED_LEVEL -gt $THRESHOLD ]]; then
        case $THRESHOLD in
          5)
            notify-send -u critical -i "battery-alert" "Battery level critical!" "you didn't listen, suspending laptop now."
            sleep 3
            systemctl suspend
            ;;
          *)
            notify-send -i "battery-alert" "Battery at ${CAPACITY}%" "charge it maybe? ok!"
            ;;
        esac
        NOTIFIED_LEVEL=$THRESHOLD
      fi
    done
  else
    NOTIFIED_LEVEL=100
  fi

done
