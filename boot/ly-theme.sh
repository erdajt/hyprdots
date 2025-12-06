#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DROPIN_DIR="/etc/systemd/system/ly.service.d"
DROPIN_FILE="${DROPIN_DIR}/10-fallout.conf"
HELPER="/usr/local/bin/fallout-tty-palette"
LY_CFG="/etc/ly/config.ini"
LY_CFG_BAK="/etc/ly/config.ini.bak-fallout"

# Require systemd and the ly service unit to exist
command -v systemctl >/dev/null || { echo "systemd not available."; exit 1; }
if ! systemctl list-unit-files | grep -q '^ly\.service'; then
  echo "ly.service not found. Install/enable ly first: sudo pacman -S ly && sudo systemctl enable ly"
  exit 1
fi

echo "[*] Writing helper: ${HELPER}"
sudo tee "${HELPER}" >/dev/null <<'SH'
#!/usr/bin/env bash
# Fallout TTY palette + banner for Linux console

seqs=(
  "\e]P0000000"  # P0  black
  "\e]P11b5e20"  # P1  dim red/green
  "\e]P239ff14"  # P2  main green
  "\e]P3b58900"  # P3  amber
  "\e]P400ff66"  # P4  aqua-green
  "\e]P5a3ff7a"  # P5  mint
  "\e]P600aa55"  # P6  teal
  "\e]P7a7ffbf"  # P7  dim white/green
  "\e]P8393939"  # P8  br black
  "\e]P9ff6f6f"  # P9  br red
  "\e]PA98ff98"  # PA  br green
  "\e]PBffcf7a"  # PB  br yellow/amber
  "\e]PC33ffaa"  # PC  br aqua
  "\e]PDc4ffd5"  # PD  br mint
  "\e]PE27d27d"  # PE  br cyan→green
  "\e]PFdffff0"  # PF  br white (pale green)
)
for s in "${seqs[@]}"; do printf "%b" "$s" > /dev/console; done

# reset attrs, clear, home
printf '\e[0m\e[2J\e[H' > /dev/console

# console size (fallback 80x24)
cols=80 rows=24
if command -v stty >/dev/null 2>&1; then
  if read -r rows cols < <(stty size < /dev/console 2>/dev/null); then :; fi
fi

title="FALLOUT BOOT INTERFACE"
subtitle="LY AUTH TERMINAL"
legend="ENTER CREDENTIALS TO CONTINUE"

bw=$(( ${#title} + 8 )); (( bw < 56 )) && bw=56
bh=9
startx=$(( (cols - bw) / 2 )); (( startx < 1 )) && startx=1
starty=$(( (rows - bh) / 2 - 2 )); (( starty < 1 )) && starty=1

mv() { printf '\e[%d;%dH' "$1" "$2" > /dev/console; }
dim='\e[0;32m'; bright='\e[1;32m'; reset='\e[0m'
hline=$(printf '═%.0s' $(seq 1 $((bw-2))))
space=$(printf ' %.0s' $(seq 1 $((bw-2))))

mv "$starty" "$startx";           printf "${bright}╔%s╗${reset}" "$hline" > /dev/console
mv $((starty+bh-1)) "$startx";    printf "${bright}╚%s╝${reset}" "$hline" > /dev/console
for r in $(seq $((starty+1)) $((starty+bh-2))); do
  mv "$r" "$startx";              printf "${bright}║${reset}${dim}%s${bright}║${reset}" "$space" > /dev/console
done

center() { local y="$1" txt="$2"; local x=$(( startx + (bw - ${#txt})/2 )); mv "$y" "$x"; }
center $((starty+2)) "${bright}${title}${reset}"
center $((starty+3)) "${dim}${subtitle}${reset}"
center $((starty+5)) "${dim}${legend}${reset}"

# subtle scanline
mv $((starty-1)) "$startx"; printf "${dim}%-${bw}s${reset}" "$(printf '▀%.0s' $(seq 1 $bw))" > /dev/console

# leave default green so ly UI inherits
printf '\e[0;32m' > /dev/console
SH
sudo chmod +x "${HELPER}"

echo "[*] Creating systemd drop-in"
sudo mkdir -p "${DROPIN_DIR}"
sudo tee "${DROPIN_FILE}" >/dev/null <<EOF
[Service]
ExecStartPre=${HELPER}
EOF

echo "[*] Backing up /etc/ly/config.ini (once)…"
if [ -f "${LY_CFG}" ] && [ ! -f "${LY_CFG_BAK}" ]; then
  sudo cp -a "${LY_CFG}" "${LY_CFG_BAK}"
fi

echo "[*] Ensuring ly reapplies palette on every tty reset"
sudo mkdir -p "$(dirname "${LY_CFG}")"
sudo touch "${LY_CFG}"
if grep -q '^term_reset_cmd' "${LY_CFG}"; then
  sudo sed -i -E "s|^term_reset_cmd *=.*|term_reset_cmd = ${HELPER}|" "${LY_CFG}"
else
  {
    echo ""
    echo "# Fallout palette reapply on reset"
    echo "term_reset_cmd = ${HELPER}"
  } | sudo tee -a "${LY_CFG}" >/dev/null
fi

echo "[*] Reloading systemd and bouncing ly (if running)"
sudo systemctl daemon-reload
# don’t fail if it’s not active
sudo systemctl try-restart ly.service || true

echo "✅ Done. At the login TTY, ly should now show the Fallout palette + banner."
echo "   If ly isn’t enabled yet: sudo systemctl enable ly --now"
