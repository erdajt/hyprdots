#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="$HOME/.cache/wallpaper-selector"
STATE_FILE="$HOME/.config/hypr/.theme-state"
WALL_STATE="$HOME/.config/hypr/.wallpaper-state"
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
WOFI_CONF="$HOME/.config/wofi/wallpaper.conf"
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

read_wall_state() {
    [[ -f "$WALL_STATE" ]] || return 1
    awk -F= -v t="$THEME" '$1==t{print $2}' "$WALL_STATE"
}

write_wall_state() {
    local path="$1" tmp
    tmp="$(mktemp)"
    touch "$WALL_STATE"
    awk -F= -v t="$THEME" -v p="$path" 'BEGIN{found=0} $1==t{print t"="p; found=1; next} {print $0} END{if(!found)print t"="p}' "$WALL_STATE" > "$tmp"
    mv "$tmp" "$WALL_STATE"
}

collect_files() {
    FILES=()
    local theme_dir="${WALL_DIRS[$THEME]:-}"
    if [[ -d "$theme_dir" ]]; then
        mapfile -t FILES < <(find "$theme_dir" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | sort)
    fi
    if [[ -d "$HOME/Wallpapers" ]]; then
        local others=()
        mapfile -t others < <(find "$HOME/Wallpapers" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | sort)
        FILES+=("${others[@]}")
    fi
}

generate_fallback_menu() {
    echo "Random Wallpaper"
    for img in "${FILES[@]}"; do
        basename "$img"
    done
}

gen_image_menu() {
    echo "img:random|Random Wallpaper"
    for img in "${FILES[@]}"; do
        thumb="${CACHE_DIR}/$(echo -n "$img" | md5sum | cut -d' ' -f1).png"
        if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
            magick convert "$img" -thumbnail "$THUMB_SIZE" -gravity center -extent "$THUMB_SIZE" -quality 90 -strip "$thumb" || continue
        fi
        echo "img:${thumb}|$(basename "$img")"
    done
}

select_wallpaper() {
    local -a wofi_args=(--show dmenu --allow-images --image-size "$THUMB_SIZE" --allow-markup --columns 3 --width 1000 --height 420 --prompt "Wallpaper")
    [[ -f "$WOFI_CONF" ]] && wofi_args+=(--conf "$WOFI_CONF")
    [[ -f "$WOFI_STYLE" ]] && wofi_args+=(--style "$WOFI_STYLE")

    if gen_image_menu | wofi "${wofi_args[@]}"; then
        return 0
    fi

    generate_fallback_menu | wofi "${wofi_args[@]}"
}

apply_wallpaper() {
    local choice="$1" selected
    if [[ "$choice" == "Random Wallpaper" || "$choice" == "img:random|Random Wallpaper" ]]; then
        [[ ${#FILES[@]} -gt 0 ]] || return
        choice="${FILES[RANDOM % ${#FILES[@]}]}"
    else
        for img in "${FILES[@]}"; do
            if [[ "$(basename "$img")" == "${choice#img:*|}" ]]; then
                choice="$img"
                break
            fi
        done
    fi

    if [ -f "$choice" ]; then
        killall swaybg 2>/dev/null || true
        swaybg -i "$choice" -m fill &
        notify-send "Wallpaper Set" "$(basename "$choice")" -i "$choice" 2>/dev/null || true
        write_wall_state "$choice"
    fi
}

collect_files
choice="$(select_wallpaper)"
[ -n "$choice" ] && apply_wallpaper "$choice"
