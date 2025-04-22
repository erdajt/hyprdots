#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-selector"
THUMB_SIZE="300x169"

mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

check_deps() {
    local missing=()
    command -v magick >/dev/null || missing+=("imagemagick")
    command -v wofi >/dev/null || missing+=("wofi")
    command -v swaybg >/dev/null || missing+=("swaybg")

    if [ ${#missing[@]} -gt 0 ]; then
        notify-send "Error" "Missing required packages: ${missing[*]}"
        exit 1
    fi
}
check_deps

generate_fallback_menu() {
    echo "🎲 Random Wallpaper"
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) -printf "%f\n"
}

select_wallpaper() {
    if gen_image_menu | wofi --show dmenu --allow-images --columns 3 --width 1000 --height 400; then
        return 0
    fi

    generate_fallback_menu | wofi --show dmenu --prompt "Select Wallpaper"
}

gen_image_menu() {
    echo "img:🎲|Random Wallpaper"
    while IFS= read -r -d $'\0' img; do
        thumb="${CACHE_DIR}/$(basename "$img").thumb"
        if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
            magick convert "$img" -thumbnail "$THUMB_SIZE" -gravity center -extent "$THUMB_SIZE" "$thumb" || continue
        fi
        echo "img:${thumb}|$(basename "$img")"
    done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) -print0)
}

apply_wallpaper() {
    local choice="$1"
    if [ "$choice" = "🎲 Random Wallpaper" ] || [ "$choice" = "img:🎲|Random Wallpaper" ]; then
        local wallpapers=()
        mapfile -d $'\0' wallpapers < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) -print0)
        choice="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    else
        choice="$(find "$WALLPAPER_DIR" -type f -name "${choice#img:*|}" -print -quit)"
    fi

    if [ -f "$choice" ]; then
        killall swaybg 2>/dev/null || true
        swaybg -i "$choice" -m fill &
        notify-send "Wallpaper Set" "$(basename "$choice")" -i "$choice"
    fi
}

choice="$(select_wallpaper)"
[ -n "$choice" ] && apply_wallpaper "$choice"
