#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "[*] Removing fallout-tty hook files…"
sudo rm -f /usr/lib/initcpio/hooks/fallout-tty
sudo rm -f /usr/lib/initcpio/install/fallout-tty

echo "[*] Removing 'fallout-tty' from HOOKS…"
if [ -f /etc/mkinitcpio.conf ]; then
  sudo sed -i -E 's/\bfallout-tty\b//g; s/  +/ /g; s/\( +/\(/; s/ +\)/\)/' /etc/mkinitcpio.conf
  echo "[*] New HOOKS line:"
  grep '^HOOKS=' /etc/mkinitcpio.conf || true
fi

echo "[*] Rebuilding initramfs…"
sudo mkinitcpio -P

echo "✅ Reverted. Your boot is back to the stock text LUKS prompt."
