# dotfiles

CachyOS (Arch-based) + Hyprland desktop configuration.

## Theme

Source of truth: [`.config/alacritty/alacritty.toml`](.config/alacritty/alacritty.toml)

| Role       | Hex       |
|------------|-----------|
| Background | `#111113` |
| Bg alt     | `#1a1a1e` |
| Bg deep    | `#0d0d0f` |
| Bg code    | `#01060e` |
| Text       | `#c8c8c8` |
| Muted      | `#686868` |
| Blue       | `#53bdfa` |
| Cyan       | `#90e1c6` |
| Green      | `#91b362` |
| Yellow     | `#e6b450` |
| Red        | `#f07178` |

Applied to: Alacritty, Waybar, Obsidian (CSS snippet), Hyprland colors.

### Light / dark / auto

The waybar theme button ([`.config/hypr/scripts/theme`](.config/hypr/scripts/theme)) cycles
light -> dark -> auto. Auto switches to light at sunrise and dark at sunset (location set via
`LAT`/`LON` at the top of the script). It swaps the portal color-scheme, GTK theme, Kvantum
theme, Alacritty colors (`themes/{dark,light}.toml`), Waybar colors (`themes/{dark,light}.css`),
Hyprland border/shadow colors (`hypr/config/themes/{dark,light}.conf`), swaync notifications
(`swaync/themes/`) and the lock screen (`swaylock/themes/`). wofi and wlogout import Waybar's
`colors.css`, so they follow automatically.

## Repository structure

```
.config/
  alacritty/        Terminal emulator config
  fish/             Shell config, completions, functions
  hypr/             Hyprland WM (keybinds, autostart, monitors, animations)
  obsidian/         CSS snippets for Obsidian vault theming
  waybar/           Bar config, modules, style, custom icon font
  swaylock/         Lock screen config
  wlogout/          Logout menu
  wofi/             App launcher
easyeffects/
  output/           EasyEffects output presets (bass boost)
  input/            EasyEffects input presets (mic noise reduction)
desktop.webp        Wallpaper (swaybg)
.gitconfig          Git identity & credential helper
setup.sh            Interactive setup script
```

## Tools

| Tool      | Purpose                    |
|-----------|----------------------------|
| Hyprland  | Wayland compositor / WM    |
| Waybar    | Status bar                 |
| Alacritty | Terminal emulator          |
| Fish      | Shell                      |
| Wofi      | Application launcher       |
| Mako      | Notification daemon        |
| Swaylock  | Lock screen                |
| Wlogout   | Logout / power menu        |
| Swaybg    | Wallpaper                  |
| EasyEffects | Audio effects (PipeWire) |

## Workspace layout

| WS | App              | Icon |
|----|------------------|------|
| 1  | Zen Browser      | Custom font glyph |
| 2  | Claude Code (x3) | Custom font glyph |
| 3  | Obsidian + Lazygit | Custom font glyph |
| 4  | Thunderbird      | Nerd Font mail |
| 5  | Discord          | Nerd Font discord |
| 8  | Bitwarden        | Default |

Workspace icons use a custom `workspace-icons` font built from Simple Icons SVGs (Zen, Anthropic, Obsidian) via `fantasticon`. The font is stored at `.config/waybar/fonts/workspace-icons.ttf`.

## Setup

```bash
git clone <this-repo> ~/repos/dotfiles
cd ~/repos/dotfiles
./setup.sh
```

The script prompts for each step:

1. Copy `.gitconfig` to `$HOME`
2. Symlink `.config/*` entries into `~/.config/`
3. Install `workspace-icons` font to `~/.local/share/fonts/`
4. Symlink Obsidian CSS snippets into vault (`~/repos/notes/notes/.obsidian/snippets/`)
5. Symlink EasyEffects presets into `~/.local/share/easyeffects/`
6. Install all packages via `paru`
7. Optional: Rustup, Docker, WireGuard, CIFS mount

After setup, enable the Obsidian theme: **Settings > Appearance > CSS snippets > toggle `alacritty-theme`**.

## Customization

- Edit `.gitconfig` with your name/email before running setup
- Monitor config: `.config/hypr/config/monitor.conf`
- Keybinds: `.config/hypr/config/keybinds.conf`
- Autostart apps: `.config/hypr/config/autostart.conf`
- Package list: categorized array in `setup.sh`
- Audio effects: `easyeffects/output/bass-boost.json` (low shelf +5 dB at 100 Hz plus a limiter) and `easyeffects/input/mic-denoise.json` (high-pass, RNNoise, gate, compressor, limiter). Load with `easyeffects -l <preset>`, tweak in the GUI, then re-save the preset to write the file back.
