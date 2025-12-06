#!/usr/bin/env bash
set -euo pipefail

THEMES=(everforest tokyo-night tokyo-dracula dracula catppuccin-mocha rose-pine)
STATE_FILE="$HOME/.config/hypr/.theme-state"
NVIM_THEME_FILE="$HOME/.config/nvim/.theme"

ALACRITTY_ACTIVE="$HOME/.config/alacritty/themes/active.toml"
WAYBAR_ACTIVE="$HOME/.config/waybar/themes/active.css"
WOFI_ACTIVE="$HOME/.config/wofi/themes/active.css"
HYPR_ACTIVE="$HOME/.config/hypr/themes/active.conf"

declare -A ALACRITTY_THEME=(
    [everforest]="$HOME/.config/alacritty/themes/everforest.toml"
    [tokyo-night]="$HOME/.config/alacritty/themes/tokyo-night.toml"
    [tokyo-dracula]="$HOME/.config/alacritty/themes/tokyo-dracula.toml"
    [dracula]="$HOME/.config/alacritty/themes/dracula.toml"
    [catppuccin-mocha]="$HOME/.config/alacritty/themes/catppuccin-mocha.toml"
    [rose-pine]="$HOME/.config/alacritty/themes/rose-pine.toml"
)

declare -A WAYBAR_THEME=(
    [everforest]="$HOME/.config/waybar/themes/Everforest.css"
    [tokyo-night]="$HOME/.config/waybar/themes/Tokyo-Night.css"
    [tokyo-dracula]="$HOME/.config/waybar/themes/Tokyo-Night.css"
    [dracula]="$HOME/.config/waybar/themes/Dracula.css"
    [catppuccin-mocha]="$HOME/.config/waybar/themes/Catppuccin-Mocha.css"
    [rose-pine]="$HOME/.config/waybar/themes/Rose-Pine.css"
)

declare -A WOFI_THEME=(
    [everforest]="$HOME/.config/wofi/themes/everforest.css"
    [tokyo-night]="$HOME/.config/wofi/themes/tokyo-night.css"
    [tokyo-dracula]="$HOME/.config/wofi/themes/tokyo-night.css"
    [dracula]="$HOME/.config/wofi/themes/dracula.css"
    [catppuccin-mocha]="$HOME/.config/wofi/themes/catppuccin-mocha.css"
    [rose-pine]="$HOME/.config/wofi/themes/rose-pine.css"
)

declare -A HYPR_THEME=(
    [everforest]="$HOME/.config/hypr/themes/everforest.conf"
    [tokyo-night]="$HOME/.config/hypr/themes/tokyo-night.conf"
    [tokyo-dracula]="$HOME/.config/hypr/themes/tokyo-night.conf"
    [dracula]="$HOME/.config/hypr/themes/dracula.conf"
    [catppuccin-mocha]="$HOME/.config/hypr/themes/catppuccin-mocha.conf"
    [rose-pine]="$HOME/.config/hypr/themes/rose-pine.conf"
)

declare -A FIREFOX_THEME=(
    [everforest]="{0e5c8ff0-b54b-4bd1-b33e-d5e016e066f0}"
    [tokyo-night]="{4520dc08-80f4-4b2e-982a-c17af42e5e4d}"
    [tokyo-dracula]="{4520dc08-80f4-4b2e-982a-c17af42e5e4d}"
    [dracula]="{7c7f5097-d453-4951-8638-d1055726a76b}"
    [catppuccin-mocha]="{f5525f34-4102-4f6e-8478-3cf23cfeff7a}"
)

declare -A WALL_DIRS=(
    [everforest]="$HOME/Wallpapers/everforest"
    [tokyo-night]="$HOME/Wallpapers/tokyonight"
    [tokyo-dracula]="$HOME/Wallpapers/tokyonight"
    [dracula]="$HOME/Wallpapers/dracula"
    [catppuccin-mocha]="$HOME/Wallpapers/catppuccin"
    [rose-pine]="$HOME/Wallpapers/rose-pine"
)

declare -A WALL_DEFAULT=(
    [everforest]="$HOME/Wallpapers/arch-everforest.jpg"
)

theme_label() {
    case "$1" in
        everforest) echo "Everforest" ;;
        tokyo-night) echo "Tokyo Night" ;;
        tokyo-dracula) echo "Tokyo/Dracula Mix" ;;
        dracula) echo "Dracula" ;;
        catppuccin-mocha) echo "Catppuccin Mocha" ;;
        rose-pine) echo "Rose Pine" ;;
        *) echo "$1" ;;
    esac
}

choose_theme() {
    local current="$1" selection
    if ${NO_MENU:-false}; then
        selection="$current"
    elif command -v wofi >/dev/null; then
        selection="$(printf '%s\n' "${THEMES[@]}" | wofi --dmenu --prompt "Theme" || true)"
    else
        selection=""
    fi
    selection="${selection//$'\n'/}"
    selection="${selection//$'\r'/}"
    selection="${selection## }"
    selection="${selection%% }"
    [[ -n "$selection" ]] && echo "$selection" || echo ""
}

pick_wallpaper() {
    local theme="$1"
    local -a candidates files
    candidates=("${WALL_DIRS[$theme]:-}" "$HOME/Wallpapers")

    for dir in "${candidates[@]}"; do
        [[ -n "$dir" && -d "$dir" ]] || continue
        mapfile -d '' files < <(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \) -print0)
        if [[ ${#files[@]} -gt 0 ]]; then
            printf '%s\n' "${files[RANDOM % ${#files[@]}]}"
            return 0
        fi
    done
    return 1
}

apply_theme() {
    local theme="$1" profile_dir firefox_pref wp

    [[ -f "${ALACRITTY_THEME[$theme]}" ]] || return 1
    [[ -f "${WAYBAR_THEME[$theme]}" ]] || return 1
    [[ -f "${HYPR_THEME[$theme]:-}" ]] || return 1
    [[ -f "${WOFI_THEME[$theme]:-}" ]] || return 1

    mkdir -p "$(dirname "$ALACRITTY_ACTIVE")" "$(dirname "$WAYBAR_ACTIVE")" "$(dirname "$WOFI_ACTIVE")" "$(dirname "$HYPR_ACTIVE")"
    cp "${ALACRITTY_THEME[$theme]}" "$ALACRITTY_ACTIVE"
    cp "${WAYBAR_THEME[$theme]}" "$WAYBAR_ACTIVE"
    cp "${WOFI_THEME[$theme]}" "$WOFI_ACTIVE"
    cp "${HYPR_THEME[$theme]}" "$HYPR_ACTIVE"

    echo "$theme" > "$STATE_FILE"
    echo "$theme" > "$NVIM_THEME_FILE"

    alacritty msg config-reload >/dev/null 2>&1 || true
    pkill -SIGUSR2 waybar 2>/dev/null || true
    hyprctl reload >/dev/null 2>&1 || true

    wp="${WALL_DEFAULT[$theme]:-}"
    if [[ -z "$wp" || ! -f "$wp" ]]; then
        wp="$(pick_wallpaper "$theme" || true)"
    fi

    if command -v swaybg >/dev/null && [[ -n "${wp:-}" && -f "$wp" ]]; then
        killall swaybg 2>/dev/null || true
        swaybg -i "$wp" -m fill >/dev/null 2>&1 &
    fi

    profile_dir="$(awk -F= '/^Default=/{print $2; exit}' "$HOME/.mozilla/firefox/profiles.ini" 2>/dev/null)"
    firefox_pref="${FIREFOX_THEME[$theme]:-}"
    if [[ -n "$firefox_pref" && -n "$profile_dir" && -d "$HOME/.mozilla/firefox/$profile_dir" ]]; then
        cat > "$HOME/.mozilla/firefox/$profile_dir/user.js" <<EOF
user_pref("extensions.activeThemeID", "$firefox_pref");
EOF
    fi

    notify-send "Theme switched" "$(theme_label "$theme")" >/dev/null 2>&1 || true
}

main() {
    local current next
    current="$(cat "$STATE_FILE" 2>/dev/null || echo "${THEMES[0]}")"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --apply-current) NO_MENU=true ;;
            --theme) shift; next="$1" ;;
            --no-menu) NO_MENU=true ;;
        esac
        shift
    done

    if [[ -z "${next:-}" ]]; then
        next="$(choose_theme "$current")"
    fi

    if [[ -z "${next:-}" ]]; then
        exit 0
    fi

    apply_theme "$next"
}

main "$@"
