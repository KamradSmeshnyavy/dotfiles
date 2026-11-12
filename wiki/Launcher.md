**English** · [Русский](Launcher-ru)

# Launcher

Full-screen skins for the Omarchy menu and app launcher. Every menu, search and action works as before — the skin only
decides how the list is drawn, recoloured from the theme each time it opens. Repo:
[omarchy-launcher-skins](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-launcher-skins --enable
omarchy restart shell
echo '{"skin": "constellation"}' > ~/.config/omarchy/extensions/menu-skin.json
```

| Skin | |
|---|---|
| `constellation` | apps as stars on a sky map |
| `terminal` | a theme-tinted CRT shell prompt |
| `tarot` | a fan of cards (`tarot-hack` deals them from `xxd`) |
| `orrery` | apps orbiting a sun |
| `aquarium` | apps as fish |
| `lanterns` | floating lanterns under the moon |
| `metro` | a subway line map |
| `drum` | a rotating drum |
| `bookshelf` | apps as books |
| `matrix` | falling code |
| `list` | the stock card |

Pick in Customizer → Pickers → Launcher. The file is watched — skins switch even while the menu is open. Open it as
usual: Super+Space (menu), Super+Alt+Space (apps).

Keys: ↑↓ / Ctrl+J/K along the list or the ring, ←→ / PgUp/PgDn pages, Alt+1…9 quick-launch, Enter / Backspace / Esc.

**Commands:** type `>` for command mode — `>theme`, `>wall`, `>skin`, `>dash`, `>dnd`, `>shader`, `>custom`, `>lock`,
`>power`; quick modes: `=` calculator and units, `:` emoji / kaomoji / symbols, `@` windows, `!` web search with
bangs, `;` clipboard history ([reference](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-launcher-commands.md)).

Back to the stock menu: `omarchy plugin enable omarchy.menu`.
