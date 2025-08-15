#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# sanity
command -v sudo >/dev/null || { echo "sudo missing"; exit 1; }
command -v pacman >/dev/null || { echo "This is for Arch."; exit 1; }

echo "[*] Ensuring stock mkinitcpio is present…"
sudo pacman -S --needed --noconfirm mkinitcpio

echo "[*] Installing fallout-tty mkinitcpio hook…"
sudo tee /usr/lib/initcpio/hooks/fallout-tty >/dev/null <<'HOOK'
#!/usr/bin/ash
# Minimal, safe: paint console green + header, then exit.
run_hook() {
  # green fg + clear + home
  printf '\033[0;32m\033[2J\033[H' > /dev/console
  cat > /dev/console <<'_EOF_'
========================================
      THEY ARE WATCHING YOU
========================================

    Welcome to the neptune console!
    Please unlock your LUKS partition.


    If not, you will be reported to the owner of this computer.
_EOF_
}
HOOK
sudo chmod 755 /usr/lib/initcpio/hooks/fallout-tty

sudo tee /usr/lib/initcpio/install/fallout-tty >/dev/null <<'INST'
#!/usr/bin/bash
build() {
  add_runscript
}
help() {
  cat <<'_EOH'
fallout-tty: paints the console green and prints a header before 'encrypt'.
Does not modify cryptsetup or unlock logic. Purely cosmetic and safe.
_EOH
}
INST
sudo chmod 755 /usr/lib/initcpio/install/fallout-tty

echo "[*] Backing up /etc/mkinitcpio.conf…"
STAMP="$(date +%Y%m%d-%H%M%S)"
sudo cp -a /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak-fallout-"$STAMP"

if grep -q 'HOOKS=' /etc/mkinitcpio.conf; then
  if grep -q 'fallout-tty' /etc/mkinitcpio.conf; then
    echo "[*] fallout-tty already in HOOKS."
  else
    if grep -q '\bencrypt\b' /etc/mkinitcpio.conf; then
      echo "[*] Inserting fallout-tty before 'encrypt'…"
      sudo sed -i -E 's/(HOOKS=\([^)]*)\bencrypt\b/\1 fallout-tty encrypt/' /etc/mkinitcpio.conf
    else
      echo "[*] No 'encrypt' token found; inserting after 'block'…"
      sudo sed -i -E 's/(HOOKS=\([^)]*)\bblock\b/\1 block fallout-tty/' /etc/mkinitcpio.conf
    fi
  fi
else
  echo "ERROR: /etc/mkinitcpio.conf has no HOOKS= line. Aborting."
  exit 1
fi

echo "[*] Current HOOKS line:"
grep '^HOOKS=' /etc/mkinitcpio.conf || true

echo "[*] Rebuilding initramfs (mkinitcpio -P)…"
sudo mkinitcpio -P

echo
echo "✅ Done. Plymouth is removed. Your LUKS prompt will now appear in Fallout-green text."
echo "   This is cosmetic only; unlock logic is untouched and stock-safe."
