# Темы CLI/TUI-приложений для тем Omarchy

`scripts/omarchy-app-themes` (запускается из `hooks/theme-set`) красит приложения, которые Omarchy сам не трогает.

## Слоты

Каждое приложение читает тему из одного файла-слота. Это симлинк (в `.gitignore`), который скрипт при каждой смене
темы направляет на `apps/<файл>` текущей темы, а если у темы такого файла нет — на `app-defaults/<файл>`
(прежнее поведение: цвета терминала / встроенная тема приложения).

| файл темы | слот | подключён в |
|---|---|---|
| `yazi.toml` | `~/.config/yazi/theme.toml` | yazi читает сам |
| `lazygit.yml` | `~/.config/lazygit/theme.yml` | `LG_CONFIG_FILE` в `env.nu` / `.zshrc` |
| `atuin.toml` | `~/.config/atuin/themes/omarchy.toml` | `[theme] name = "omarchy"` |
| `lla.toml` | `~/.config/lla/themes/omarchy.toml` | `theme = "omarchy"` |
| `television.toml` | `~/.config/television/themes/omarchy.toml` | `theme = "omarchy"` |
| `gitui.ron` | `~/.config/gitui/theme.ron` | gitui читает сам |
| `rmpc.ron` | `~/.config/rmpc/themes/omarchy.ron` | `theme: "omarchy"` |
| `nushell.nu` | `~/.config/nushell/themes/omarchy.nu` | `source` в `config.nu` |
| `tmux.conf` | `~/.config/tmux/om-app-theme.conf` | `tmux.conf` после `om-theme.conf`; перечитывается сразу |

`env` (строки `KEY=VALUE`, `{theme}` — путь к текущей теме) превращается в
`~/.local/state/omarchy/app-theme.json` (nushell, `load-env` в `env.nu`) и `app-theme.zsh` (`.zshrc`).

Кроме tmux, новая тема видна в новом окне терминала / при следующем запуске приложения.

## Новая тема

Положить нужные файлы в `<тема>/apps/` — остальные приложения останутся на `app-defaults`.
