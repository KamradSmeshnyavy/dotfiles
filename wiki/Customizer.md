**English** · [Русский](Customizer-ru)

# Customizer

One overlay for the whole look of Omarchy — `Super+Shift+T`. Everything has a live preview, every choice survives a
reload, and the groups of other plugins appear on their own once those plugins are installed.

Repo: [omarchy-customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) (GPL-3.0).

![Customizer](https://raw.githubusercontent.com/KamradSmeshnyavy/omarchy-customizer/main/screenshots/desktop.webp)

## Groups

| Group | What's inside |
|---|---|
| **Presets** | whole-desktop snapshots (bundled DOT-MATRIX + your own, ★), **Style** (see [Styles](Styles)), window corners, "Restore the previous setup" |
| **Desktop** | Theme (palette + preview), Wallpaper, Recolor (any image into the current theme with lutgen), Dotify (LED dot-matrix wallpapers and an Arch glyph generator), Wallpaper FX\*, Widgets\*, Dashboard\*, System fonts ([Font profiles](Font-Profiles)) |
| **Bar\*** | Bar Skin (save your own ★), Bar Layout, Bar Tweaks (41 settings, each with a default and a live preview), Bar widgets |
| **Windows** | Windows (gaps, borders, rounding, shadow, dimming, layout), Animations (19 presets), Transparency, Blur, OSD and notifications\* (sound packs, Hyprland window/workspace sounds), Glyph (Nothing-style edge lighting), Shader (CRT / TFT / Paper / Neon) |
| **Lock\*** | Lock design with previews in the current theme, Lock Tweaks |
| **Pickers\*** | theme / wallpaper picker style, thumbnail cache, Launcher\* skins |

\* — appears when the matching plugin is installed.

## Keys

| Keys | |
|---|---|
| Tab / 1–6 | groups |
| j k · l ⏎ · h | move · open · back |
| / | search |
| h l, − + | change a tweak · x — reset it · i — type a value |
| p | play / show live (transitions, lock designs, picker) |
| r | surprise me |
| ? · q / Esc | all keys · close |

Open it on a given group: `omarchy-shell shell toggle kamradsmeshnyavy.customizer '{"category":"windows"}'`.

## How choices survive a reload

Animations go to `~/.local/state/omarchy-customizer/animations.lua`; transparency, blur and the shader to
`~/.local/state/hypr/{opacity,blur,screen-shader}`. The Customizer re-applies them when the shell starts and after
every `hyprctl reload`. For a reload without a flash of the defaults, load its hook from your Hyprland config (e.g. at
the end of `~/.config/hypr/looknfeel.lua`):

```lua
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/hypr/customizer.lua")
```

The scripts work on their own too:

```lua
o.bind("SUPER + ALT + O", "Next transparency preset", "~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/opacity.sh next")
o.bind("SUPER + ALT + U", "Next blur preset", "~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/blur.sh next")
o.bind("SUPER + ALT + C", "Toggle screen shader", "~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/crt-toggle.sh")
```

## From a terminal

Every tweak can be set without the overlay: `customizer.sh tweak <key> set <value>` (in the plugin folder). Your own
presets, animations and shaders live in `~/.config/omarchy/customizer/{presets,animations,shaders}/` — see
[Make your own](Make-Your-Own).

## Language

English and Russian: `"lang"` in `~/.config/omarchy/customizer.json`, otherwise `$LANG`. Translations are
`i18n/<lang>.json` with the English string as the key — a new language is one more file.
