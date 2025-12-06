#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DROPIN_DIR="/etc/systemd/system/ly.service.d"
DROPIN_FILE="${DROPIN_DIR}/10-fallout.conf"
HELPER="/usr/local/bin/fallout-tty-palette"
LY_CFG="/etc/ly/config.ini"
LY_CFG_BAK="/etc/ly/config.ini.bak-fallout"

echo "[*] Remove systemd drop-in"
sudo rm -f "${DROPIN_FILE}"
rmdir "${DROPIN_DIR}" 2>/dev/null || true

echo "[*] Remove helper"
sudo rm -f "${HELPER}"

if [ -f "${LY_CFG_BAK}" ]; then
  echo "[*] Restore original /etc/ly/config.ini"
  sudo mv -f "${LY_CFG_BAK}" "${LY_CFG}"
else
  echo "[*] Scrub term_reset_cmd from current ly config"
  sudo sed -i -E '/^# Fallout palette reapply on reset$/d;/^term_reset_cmd *= .*fallout-tty-palette.*$/d' "${LY_CFG}" 2>/dev/null || true
fi

echo "[*] Reload systemd + restart ly (if running)"
sudo systemctl daemon-reload
sudo systemctl try-restart ly.service || true

echo "✅ Reverted."
