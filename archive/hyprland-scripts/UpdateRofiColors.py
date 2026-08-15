#!/usr/bin/env python3
import sys, os, re

if len(sys.argv) < 2:
    print("Usage: UpdateRofiColors.py <theme_name>")
    sys.exit(1)

theme_name = sys.argv[1]
# Omarchy themes are in ~/.config/omarchy/themes/
theme_path = os.path.expanduser(f"~/.config/omarchy/themes/{theme_name}/colors.toml")

if not os.path.exists(theme_path):
    # Try lowercase with hyphens if exact match fails
    theme_name_alt = theme_name.lower().replace(" ", "-")
    theme_path = os.path.expanduser(f"~/.config/omarchy/themes/{theme_name_alt}/colors.toml")
    if not os.path.exists(theme_path):
        print(f"Theme {theme_name} not found.")
        sys.exit(1)

colors = {}
with open(theme_path, 'r') as f:
    for line in f:
        m = re.match(r'([a-zA-Z0-9_]+)\s*=\s*"([^"]+)"', line.strip())
        if m:
            colors[m.group(1)] = m.group(2)

rofi_colors = f"""* {{
active-background: {colors.get('color12', '#784CA0')};
active-foreground: {colors.get('foreground', '#FAE8E1')};
normal-background: {colors.get('background', '#181519')};
normal-foreground: {colors.get('foreground', '#FAE8E1')};
urgent-background: {colors.get('color13', '#CC659A')};
urgent-foreground: {colors.get('foreground', '#FAE8E1')};

alternate-active-background: {colors.get('color11', '#914B4B')};
alternate-active-foreground: {colors.get('foreground', '#FAE8E1')};
alternate-normal-background: {colors.get('background', '#181519')};
alternate-normal-foreground: {colors.get('foreground', '#FAE8E1')};
alternate-urgent-background: {colors.get('background', '#181519')};
alternate-urgent-foreground: {colors.get('foreground', '#FAE8E1')};

selected-active-background: {colors.get('color13', '#CC659A')};
selected-active-foreground: {colors.get('foreground', '#FAE8E1')};
selected-normal-background: {colors.get('color13', '#CC659A')};
selected-normal-foreground: {colors.get('foreground', '#FAE8E1')};
selected-urgent-background: {colors.get('color12', '#784CA0')};
selected-urgent-foreground: {colors.get('foreground', '#FAE8E1')};

background-color: {colors.get('background', '#181519')};
background: rgba(0,0,0,0.7);
foreground: {colors.get('foreground', '#FAE8E1')};
border-color: {colors.get('color12', '#784CA0')};

color0: {colors.get('color0', '#3F3C40')};
color1: {colors.get('color1', '#1A1022')};
color2: {colors.get('color2', '#492E61')};
color3: {colors.get('color3', '#6D3838')};
color4: {colors.get('color4', '#5A3978')};
color5: {colors.get('color5', '#994C74')};
color6: {colors.get('color6', '#B58E80')};
color7: {colors.get('color7', '#F0D6CC')};
color8: {colors.get('color8', '#A8958F')};
color9: {colors.get('color9', '#23152D')};
color10: {colors.get('color10', '#613D81')};
color11: {colors.get('color11', '#914B4B')};
color12: {colors.get('color12', '#784CA0')};
color13: {colors.get('color13', '#CC659A')};
color14: {colors.get('color14', '#F2BDAA')};
color15: {colors.get('color15', '#F0D6CC')};
}}
"""

rofi_path = os.path.expanduser("~/dotfiles/apps/rofi/wallust/colors-rofi.rasi")
os.makedirs(os.path.dirname(rofi_path), exist_ok=True)
with open(rofi_path, 'w') as f:
    f.write(rofi_colors)

# Write waybar colors
waybar_colors = f"""
@define-color background {colors.get('background', '#181519')};
@define-color foreground {colors.get('foreground', '#FAE8E1')};
@define-color color0 {colors.get('color0', '#3F3C40')};
@define-color color1 {colors.get('color1', '#1A1022')};
@define-color color2 {colors.get('color2', '#492E61')};
@define-color color3 {colors.get('color3', '#6D3838')};
@define-color color4 {colors.get('color4', '#5A3978')};
@define-color color5 {colors.get('color5', '#994C74')};
@define-color color6 {colors.get('color6', '#B58E80')};
@define-color color7 {colors.get('color7', '#F0D6CC')};
@define-color color8 {colors.get('color8', '#A8958F')};
@define-color color9 {colors.get('color9', '#23152D')};
@define-color color10 {colors.get('color10', '#613D81')};
@define-color color11 {colors.get('color11', '#914B4B')};
@define-color color12 {colors.get('color12', '#784CA0')};
@define-color color13 {colors.get('color13', '#CC659A')};
@define-color color14 {colors.get('color14', '#F2BDAA')};
@define-color color15 {colors.get('color15', '#F0D6CC')};
"""

waybar_path = os.path.expanduser("~/dotfiles/apps/waybar/wallust/colors-waybar.css")
os.makedirs(os.path.dirname(waybar_path), exist_ok=True)
with open(waybar_path, 'w') as f:
    f.write(waybar_colors)


# Write swaync colors
# Convert background hex to rgba for transparency
def hex_to_rgba(hex_color, alpha):
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 6:
        r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        return f"rgba({r}, {g}, {b}, {alpha})"
    return hex_color

bg_rgba = hex_to_rgba(colors.get('background', '#000000'), 0.8)

swaync_colors = f"""
@define-color noti-bg {bg_rgba};
@define-color noti-border-color {colors.get('color12', '#784CA0')};
@define-color noti-bg-alt {colors.get('color8', '#3F3C40')};
@define-color noti-bg-hover {colors.get('background', '#181519')};
@define-color text-color {colors.get('foreground', '#FAE8E1')};
"""

swaync_path = os.path.expanduser("~/dotfiles/apps/swaync/wallust/colors-swaync.css")
os.makedirs(os.path.dirname(swaync_path), exist_ok=True)
with open(swaync_path, 'w') as f:
    f.write(swaync_colors)

print(f"Colors updated for {theme_name}")
