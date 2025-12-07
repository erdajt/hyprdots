<div align="center">

# Hyprdots

*Hyprland rice with seamless theme switching*

One command transforms your entire desktop: window borders, status bars, terminals, notifications, and browser.

[Features](#features) • [Themes](#themes) • [Installation](#installation) • [Usage](#usage)

---

</div>

## Themes

<div align="center">

### Rose Pine
*Soft muted palette with warm accents*

<table>
<tr>
<td width="50%">

![Rose Pine](screenshots/rose-pine/theme.png)

</td>
<td width="50%">

![Rose Pine Details](screenshots/rose-pine/theme2.png)

</td>
</tr>
</table>

Moon-like terminal background with pink cursor highlights and purple-teal waybar.

---

### Nord
*Arctic frost-inspired colors*

<table>
<tr>
<td width="50%">

![Nord](screenshots/nord/theme.png)

</td>
<td width="50%">

![Nord Details](screenshots/nord/theme2.png)

</td>
</tr>
</table>

Clean ice-blue highlights with excellent readability.

---

### Tokyo Dracula
*Fusion of neon vibes and vampiric aesthetics*

<table>
<tr>
<td width="50%">

![Tokyo Dracula](screenshots/tokyo-dracula/theme.png)

</td>
<td width="50%">

![Tokyo Dracula Details](screenshots/tokyo-dracula/theme2.png)

</td>
</tr>
</table>

Rich purples with electric accents for late-night sessions.

---

### Everforest
*Natural forest-inspired calm*

<table>
<tr>
<td width="50%">

![Everforest](screenshots/everforest/theme.png)

</td>
<td width="50%">

![Everforest Details](screenshots/everforest/theme2.png)

</td>
</tr>
</table>

Warm greens and earthy tones, easy on the eyes. **Default theme.**

---

### Catppuccin Mocha
*Soothing pastel sophistication*

<table>
<tr>
<td width="50%">

![Catppuccin](screenshots/catppuccin/theme.png)

</td>
<td width="50%">

![Catppuccin Details](screenshots/catppuccin/theme2.png)

</td>
</tr>
</table>

Dark mocha background with balanced accent colors.

---

### Tokyo Night
*Neon-lit streets after dark*

<table>
<tr>
<td width="50%">

![Tokyo Night](screenshots/tokyonight/theme.png)

</td>
<td width="50%">

![Tokyo Night Details](screenshots/tokyonight/theme2.png)

</td>
</tr>
</table>

Deep blues and purples with vibrant highlights.

---

### Dracula
*Classic vampire elegance*

<table>
<tr>
<td width="50%">

![Dracula](screenshots/dracula/theme.png)

</td>
<td width="50%">

![Dracula Details](screenshots/dracula/theme2.png)

</td>
</tr>
</table>

Purple backgrounds with pink-cyan accents. High contrast.

</div>

---

## Features

### Unified Theme System
One command switches everything. No manual edits, no restarts.

**What changes:**
- Hyprland window borders and decorations
- Waybar panels and widgets
- Alacritty terminal colors and cursor
- Wofi launcher and menus
- Dunst notifications
- Firefox browser theme
- Neovim default colorscheme

**What persists:**
- Per-theme wallpaper memory
- Theme state across reboots
- All Neovim themes remain available

### Wallpaper Management
Each theme remembers your last wallpaper. Switch back to Rose Pine and your wallpaper is already set.

```
~/Wallpapers/           Shared across all themes
~/Wallpapers/rose-pine/ Rose Pine exclusives
~/Wallpapers/nord/      Nord exclusives
~/Wallpapers/tokyonight/Tokyo Night exclusives
```

Theme wallpapers appear first in the picker, then shared wallpapers.

### Notification Theming
Dunst notifications match your active theme and follow your mouse across monitors.

### Launcher & Pickers
Wofi menus fully themed with solid backgrounds and consistent spacing.

---

## Installation

### Dependencies
```bash
hyprland waybar alacritty wofi dunst firefox neovim imagemagick
```

### Setup
```bash
cd ~
git clone <your-repo-url> P9/dump/hyprdots

cd ~/.config
ln -sf ~/P9/dump/hyprdots/hypr hypr
ln -sf ~/P9/dump/hyprdots/waybar waybar
ln -sf ~/P9/dump/hyprdots/alacritty alacritty
ln -sf ~/P9/dump/hyprdots/wofi wofi
ln -sf ~/P9/dump/hyprdots/dunst dunst
ln -sf ~/P9/dump/hyprdots/.zshrc ~/.zshrc

mkdir -p ~/Wallpapers/{rose-pine,nord,tokyonight,everforest,catppuccin,dracula,tokyo-dracula}
rsync -av ~/P9/dump/hyprdots/Wallpapers/ ~/Wallpapers/
```

Set default theme:
```bash
~/.config/hypr/scripts/theme-toggle.sh --theme everforest --no-menu
```

---

## Usage

### Theme Switching

**Interactive picker:**
```bash
~/.config/hypr/scripts/theme-toggle.sh
```

**Direct switch:**
```bash
~/.config/hypr/scripts/theme-toggle.sh --theme rose-pine --no-menu
~/.config/hypr/scripts/theme-toggle.sh --theme nord --no-menu
~/.config/hypr/scripts/theme-toggle.sh --theme tokyo-dracula --no-menu
```

**Available themes:**
`everforest` • `rose-pine` • `nord` • `tokyo-night` • `tokyo-dracula` • `dracula` • `catppuccin-mocha`

### Wallpaper Picker
```bash
~/.config/hypr/scripts/wallpicker.sh
```
Theme wallpapers first, then shared. Choice remembered per theme.

### Neovim Integration
System theme sets the Neovim default via `~/.config/nvim/.theme`. All themes remain accessible.

**Manual switch:**
```vim
:colorscheme catppuccin-mocha
:colorscheme rose-pine
:colorscheme tokyonight
```

**Available:**
`nightfox` • `github` • `eldritch` • `rose-pine` • `zenbones` • `tokyo` • `everforest` • `catppuccin` • `dracula` • `nord` • `sonokai`

---

## Customization

### Adding a Theme

1. `~/.config/hypr/themes/<theme-name>.conf` - Window border colors
2. `~/.config/waybar/themes/<theme-name>.css` - Status bar styling
3. `~/.config/alacritty/themes/<theme-name>.toml` - Terminal palette
4. `~/.config/wofi/themes/<theme-name>.css` - Launcher styling
5. `~/.config/dunst/themes/<theme-name>.conf` - Notification colors
6. `~/Wallpapers/<theme-name>/` - Theme wallpapers

Add to picker in `theme-toggle.sh`.

### Keybinds
Edit `~/.config/hypr/keybinds.conf`:
```
bind = SUPER, T, exec, ~/.config/hypr/scripts/theme-toggle.sh
bind = SUPER, W, exec, ~/.config/hypr/scripts/wallpicker.sh
```

### Waybar Layout
Customize modules in `~/.config/waybar/config.jsonc` and per-theme styling in `~/.config/waybar/themes/`.

---

## File Structure
```
hyprdots/
├── alacritty/       Terminal emulator config
├── boot/            Bootloader theming scripts
├── dunst/           Notification daemon config
├── hypr/            Hyprland compositor config
│   ├── scripts/     Theme toggle, wallpaper picker
│   └── themes/      Per-theme border colors
├── waybar/          Status bar config
│   └── themes/      Per-theme CSS
├── wofi/            Launcher config
│   └── themes/      Per-theme CSS
├── Wallpapers/      Wallpaper collection
│   ├── rose-pine/
│   ├── nord/
│   └── ...
└── .zshrc           Shell configuration
```

---

<div align="center">

## Credits

**Themes** • [Everforest](https://github.com/sainnhe/everforest) • [Rose Pine](https://rosepinetheme.com/) • [Nord](https://www.nordtheme.com/) • [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) • [Dracula](https://draculatheme.com/) • [Catppuccin](https://github.com/catppuccin/catppuccin)

**Tools** • [Hyprland](https://hyprland.org/) • [Waybar](https://github.com/Alexays/Waybar) • [Wofi](https://hg.sr.ht/~scoopta/wofi) • [Dunst](https://dunst-project.org/)

</div>
