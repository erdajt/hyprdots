#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="$HOME/.cache/wallpaper-selector"
STATE_FILE="$HOME/.config/hypr/.theme-state"
THEME="$(cat "$STATE_FILE" 2>/dev/null || echo everforest)"

declare -A WALL_DIRS=(
    [everforest]="$HOME/Wallpapers/everforest"
    [tokyo-night]="$HOME/Wallpapers/tokyonight"
    [tokyo-dracula]="$HOME/Wallpapers/tokyonight"
    [dracula]="$HOME/Wallpapers/dracula"
    [catppuccin-mocha]="$HOME/Wallpapers/catppuccin"
    [rose-pine]="$HOME/Wallpapers/rose-pine"
)

declare -A WOFI_THEME=(
    [everforest]="$HOME/.config/wofi/themes/everforest.css"
    [tokyo-night]="$HOME/.config/wofi/themes/tokyo-night.css"
    [tokyo-dracula]="$HOME/.config/wofi/themes/tokyo-night.css"
    [dracula]="$HOME/.config/wofi/themes/dracula.css"
    [catppuccin-mocha]="$HOME/.config/wofi/themes/catppuccin-mocha.css"
    [rose-pine]="$HOME/.config/wofi/themes/rose-pine.css"
)

WALLPAPER_DIR="${WALL_DIRS[$THEME]:-$HOME/Wallpapers}"
[[ -d "$WALLPAPER_DIR" ]] || WALLPAPER_DIR="$HOME/Wallpapers"
WOFI_STYLE="${WOFI_THEME[$THEME]:-$HOME/.config/wofi/themes/active.css}"
THUMB_SIZE="300x169"

mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

check_deps() {
    local missing=()
    command -v magick >/dev/null || missing+=("imagemagick")
    command -v wofi >/dev/null || missing+=("wofi")
    command -v swaybg >/dev/null || missing+=("swaybg")

    if [ ${#missing[@]} -gt 0 ]; then
        notify-send "Error" "Missing packages: ${missing[*]}" 2>/dev/null || true
        exit 1
    fi
}
check_deps

generate_fallback_menu() {
    echo "Random Wallpaper"
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -printf "%f\n"
}

gen_image_menu() {
    echo "img:random|Random Wallpaper"
    while IFS= read -r -d $'\0' img; do
        thumb="${CACHE_DIR}/$(basename "$img").thumb"
        if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
            magick convert "$img" -thumbnail "$THUMB_SIZE" -gravity center -extent "$THUMB_SIZE" "$thumb" || continue
        fi
        echo "img:${thumb}|$(basename "$img")"
    done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0)
}

select_wallpaper() {
    local -a wofi_args=(--show dmenu --allow-images --columns 3 --width 1000 --height 420 --prompt "Wallpaper")
    [[ -f "$WOFI_STYLE" ]] && wofi_args+=(--style "$WOFI_STYLE")

    if gen_image_menu | wofi "${wofi_args[@]}"; then
        return 0
    fi

    generate_fallback_menu | wofi "${wofi_args[@]}"
}

apply_wallpaper() {
    local choice="$1" selected
    if [[ "$choice" == "Random Wallpaper" || "$choice" == "img:random|Random Wallpaper" ]]; then
        mapfile -d $'\0' selected < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) -print0)
        [[ ${#selected[@]} -gt 0 ]] || return
        choice="${selected[RANDOM % ${#selected[@]}]}"
    else
        choice="$(find "$WALLPAPER_DIR" -type f -name "${choice#img:*|}" -print -quit)"
    fi

    if [ -f "$choice" ]; then
        killall swaybg 2>/dev/null || true
        swaybg -i "$choice" -m fill &
        notify-send "Wallpaper Set" "$(basename "$choice")" -i "$choice" 2>/dev/null || true
    fi
}

choice="$(select_wallpaper)"
[ -n "$choice" ] && apply_wallpaper "$choice"
