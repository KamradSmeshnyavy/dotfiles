# omarchy-shell lock screen: designs

[🇷🇺 Русский](omarchy-shell-lock.ru.md)

> The plugin is a separate repo and a submodule: [omarchy-lock-designs](https://github.com/KamradSmeshnyavy/omarchy-lock-designs).

My own take on [omarchy-lock-explorer](https://github.com/SirJul1337/omarchy-lock-explorer), written from scratch: no
foreign code is used. A clone of the stock `omarchy.lock` (`omarchy plugin clone omarchy.lock`):
`apps/omarchy-shell/plugins/kamradsmeshnyavy.lock/` → `~/.config/omarchy/plugins/kamradsmeshnyavy.lock`.

Choose in the Customizer (Super+Shift+T): groups **Lock** and **Lock Tweaks**.

## Safety

- Password, PAM and fingerprint are the stock `Service.qml` with unchanged logic. Changes are marked `// design:`:
  `LockView` is replaced by `LockHost` in two places, plus the `previewDesign` IPC and closing the preview with Esc.
- A design sees only what the stock `LockView` sees: the state and the typed text, which it hands over with the
  `submitPassword` signal.
- `LockHost` shows the stock `LockView` if a design fails to load, is not found or does not assign the password
  field (`field`) within 0.5 s. The screen is never left without a password input.
- The clone inherits the `authentication` capability from `omarchy.lock`: the shell isolates it the same way.
- Emergency exit if the screen is locked and something broke: a TTY (Ctrl+Alt+F3) →
  `omarchy plugin enable omarchy.lock` or `loginctl unlock-session`.

## Files

| File | What it is |
|---|---|
| `~/.config/omarchy/lock-design.json` | the chosen design and settings (`LockHost` watches it, applied at once) |
| `kamradsmeshnyavy.lock/LockHost.qml` | the design loader with a fallback |
| `kamradsmeshnyavy.lock/designs/designs.json` | the registry: `id`, `file`, `name`, `description`, `tags` |
| `kamradsmeshnyavy.lock/designs/*.qml` | designs and shared parts: `DesignBase`, `PasswordField`, `Wallpaper`, `Avatar` |
| `~/.config/omarchy/lock-designs/*.qml` | your own designs (id `my:<File>.qml`) |
| `~/.cache/omarchy-customizer/lock/*.jpg` | previews for the Customizer (`T` — re-shoot in the current theme's colours) |

## Designs

classic (stock), zen, dock, island, split, sheet, card, cinema, poster, editorial, analog, flip, ring, calendar,
terminal, neon, system, music, aurora, rain, constellation, dotmatrix — plus one per Customizer style (flat, glass,
fluent, paper, neon, neumorph, brutal, retro), picked when a style is applied.

## Settings (`lock-design.json`, Lock Tweaks)

| Key | Default | |
|---|---|---|
| `design` | `classic` | design id |
| `clock24` | `true` | 24-hour format |
| `showSeconds` | `false` | seconds |
| `showDate` | `true` | date |
| `wallpaperBlur` | `1` | wallpaper blur 0–1 |
| `wallpaperDim` | `0` | wallpaper dimming 0–0.9 |
| `reduceMotion` | `false` | no animations (aurora, rain, the second hand) |
| `ownerMessage` | `Hi, $USER` | greeting |
| `avatar` | `~/.face` | avatar picture; none — the first letter of the name |

## Your own design

`~/.config/omarchy/lock-designs/Mine.qml`:

```qml
import QtQuick
import "../plugins/kamradsmeshnyavy.lock/designs"

DesignBase {
  id: root
  field: pw                       // required: otherwise the stock screen is shown
  Wallpaper { anchors.fill: parent; host: root }
  Text { text: root.time; color: root.fg; font.family: root.font; font.pixelSize: 80 }
  PasswordField { id: pw; host: root; anchors.centerIn: parent }
}
```

`DesignBase` provides `time`, `hours`, `minutes`, `dateText`, `now`, `greeting`, `userName`, colours
`bg fg accent muted`, `font`, `withAlpha()`, `opt(key, def)` and the `preview` flag. Test without locking:
`omarchy-shell lock previewDesign my:Mine.qml` (Esc or a click closes it).

## Updating from upstream

`diff -u $OMARCHY_PATH/shell/plugins/lock/Service.qml apps/omarchy-shell/plugins/kamradsmeshnyavy.lock/Service.qml` —
carry the `// design:` blocks over to the new version. After QML edits — `omarchy restart shell`.
