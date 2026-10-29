# Desktop Widgets for omarchy-shell

Widgets that live on the desktop, under your windows: a clock, a now-playing card, a cava visualizer
and system rings. Colours follow the Omarchy theme.

| Widget | Shows | Data |
|---|---|---|
| Clock | styles `big`, `stacked`, `terminal`, `minimal` | a one-second timer |
| Now playing | cover, title, artist, progress, ⏮ ⏯ ⏭ | MPRIS — the playing player, else the first one |
| Visualizer | `bars`, `mirror`, `wave` along the bottom edge | `cava` raw output (pipewire), only while music plays |
| System rings | CPU, RAM, temperature, battery | `/proc` and `/sys` every 2 s |

The windows sit on the Bottom layer: above the wallpaper, below windows. Clicks go through to the desktop
except on the player buttons. cava and the `/proc` probe run once for all monitors.

## Install

```sh
git clone <this repo> ~/.config/omarchy/plugins/kamradsmeshnyavy.widgets
omarchy-shell shell rescanPlugins
omarchy plugin enable kamradsmeshnyavy.widgets
```

Optional: `cava` for the visualizer.

## Settings

`~/.config/omarchy/widgets.json`, re-read live (no file — defaults). The
[Customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) edits it under Desktop → Widgets.

```jsonc
{
  "clock": true, "clockStyle": "big", "clockAnchor": "top-left", "clock24": true, "clockSeconds": false,
  "media": true, "mediaAnchor": "bottom-left",
  "visualizer": true, "visualizerStyle": "bars", "visualizerBars": 48, "visualizerHeight": 140,
  "visualizerAlpha": 0.45, "visualizerIdle": false,   // idle: draw without music too (cava always runs)
  "sysinfo": true, "sysinfoAnchor": "top-right",
  "edgeMargin": 56,
  "tint": "accent",      // a role (accent foreground muted), a colors.toml key or #hex
  "locale": "",          // date language; empty — `lang` from customizer.json, else the system one
  "screens": "all"       // all | primary
}
```

Anchors: `top-left` `top` `top-right` `left` `center` `right` `bottom-left` `bottom` `bottom-right`.

QML changes need `omarchy restart shell`.
