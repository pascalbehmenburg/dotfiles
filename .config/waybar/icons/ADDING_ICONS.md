# Adding a workspace icon

The custom `workspace-icons` font provides workspace icons for Waybar. Icons are sourced as SVGs and compiled into a TTF font using `fantasticon`.

## Steps

### 1. Download the SVG

Get a filled, single-color SVG from [Simple Icons](https://simpleicons.org/):

```bash
curl -sL "https://cdn.simpleicons.org/<icon-name>" -o .config/waybar/icons/<name>.svg
```

The SVG filename (without extension) becomes the glyph name in the font.

### 2. Assign a codepoint

Edit `.config/waybar/icons/.fantasticonrc.json` and add an entry to the `codepoints` map:

```json
"codepoints": {
    "claude": 60448,
    "discord": 60451,
    "obsidian": 60449,
    "thunderbird": 60452,
    "zen": 60450,
    "newicon": 60453
}
```

Pick the next available decimal codepoint. The current range starts at 60448 (U+EC20). These are in the Unicode Private Use Area, chosen to avoid conflicts with Nerd Font glyphs (which occupy U+E000-E7FF and U+F000-F2FF).

### 3. Rebuild the font

```bash
cd .config/waybar/icons
npx fantasticon -c .fantasticonrc.json
```

This regenerates `.config/waybar/fonts/workspace-icons.ttf` and the `.json` codepoint map.

### 4. Install the font

```bash
cp .config/waybar/fonts/workspace-icons.ttf ~/.local/share/fonts/
fc-cache -fv
```

### 5. Add the icon to Waybar

Edit `.config/waybar/modules.json`. In the `hyprland/workspaces` > `format-icons` block, add the workspace mapping using the Unicode character for your codepoint.

Since these codepoints aren't typeable, use Python to write the file:

```bash
python3 -c "
import json

with open('.config/waybar/modules.json', 'r') as f:
    data = json.load(f)

data['hyprland/workspaces']['format-icons']['6'] = chr(0xEC25)  # newicon (60453 decimal = 0xEC25 hex)

with open('.config/waybar/modules.json', 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')
"
```

To convert between decimal and hex: `python3 -c "print(f'U+{60453:04X}')"` → U+EC25

### 6. Restart Waybar

```bash
killall waybar; sleep 1; waybar &disown
```

## Current icon map

| Glyph name  | Decimal | Hex    | Workspace |
|-------------|---------|--------|-----------|
| claude      | 60448   | U+EC20 | 2         |
| obsidian    | 60449   | U+EC21 | 3         |
| zen         | 60450   | U+EC22 | 1         |
| discord     | 60451   | U+EC23 | 5         |
| thunderbird | 60452   | U+EC24 | 4         |

## Notes

- The font-family `workspace-icons` must be listed first in the `#workspaces button` CSS rule (`.config/waybar/style.css`) so custom glyphs take priority over Nerd Font.
- Avoid codepoints in U+F000-F2FF (FontAwesome) and U+F0000-F1AF0 (Material Design Icons) — Nerd Font uses those ranges and will render wrong glyphs.
- `setup.sh` handles font installation for fresh setups.
