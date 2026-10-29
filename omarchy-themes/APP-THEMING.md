# Темы CLI/TUI-приложений для тем Omarchy

[🇬🇧 English](APP-THEMING.en.md)

`scripts/omarchy-app-themes` (запускается из `hooks/theme-set`) красит приложения, которые Omarchy сам не трогает.

## Слоты

Каждое приложение читает тему из одного файла-слота. Это симлинк (в `.gitignore`), который скрипт при каждой смене
темы направляет на `apps/<файл>` текущей темы, а если у темы такого файла нет — на `app-defaults/<файл>`
(прежнее поведение: цвета терминала / встроенная тема приложения).

| файл темы | слот | подключён в |
|---|---|---|
| `yazi.toml` | `~/.config/yazi/theme.toml` | yazi читает сам |
| `yazi-flavor/` (каталог) | `~/.config/yazi/flavors/omarchy.yazi` | `dark = "omarchy"` в `yazi.toml` темы |
| `yatline.lua` | `~/.config/yazi/plugins/yatline-omarchy.yazi/main.lua` | `init.lua`: `require("yatline-omarchy"):setup()` |
| `lazygit.yml` | `~/.config/lazygit/theme.yml` | `LG_CONFIG_FILE` в `env.nu` / `.zshrc` |
| `atuin.toml` | `~/.config/atuin/themes/omarchy.toml` | `[theme] name = "omarchy"` |
| `lla.toml` | `~/.config/lla/themes/omarchy.toml` | `theme = "omarchy"` |
| `television.toml` | `~/.config/television/themes/omarchy.toml` | `theme = "omarchy"` |
| `gitui.ron` | `~/.config/gitui/theme.ron` | gitui читает сам |
| `rmpc.ron` | `~/.config/rmpc/themes/omarchy.ron` | `theme: "omarchy"` |
| `nushell.nu` | `~/.config/nushell/themes/omarchy.nu` | `source` в `config.nu` |
| `tmux.conf` | `~/.config/tmux/om-app-theme.conf` | `tmux.conf` после `om-theme.conf`; перечитывается сразу |
| `fzf.opts` | `~/.local/state/omarchy/app-themes/fzf.opts` | `FZF_DEFAULT_OPTS_FILE` в `env.nu` / `.zshrc` |

Если у темы нет `apps/yatline.lua` или `apps/fzf.opts`, скрипт генерирует их из её `colors.toml`
(`scripts/omarchy-yatline-theme`, `scripts/omarchy-fzf-theme` → `~/.local/state/omarchy/app-themes/generated-*`);
`apps/yatline-palette.toml` (ключи как в `colors.toml`) перекрывает цвета — так сделаны rose-pine-hacker*.

delta не задаёт `syntax-theme`, поэтому берёт `BAT_THEME` из `env` темы (efter — Catppuccin Mocha, остальные — ansi).

`env` (строки `KEY=VALUE`, `{theme}` — путь к текущей теме) превращается в
`~/.local/state/omarchy/app-theme.json` (nushell, `load-env` в `env.nu`) и `app-theme.zsh` (`.zshrc`).

Кроме tmux, новая тема видна в новом окне терминала / при следующем запуске приложения.

## GUI-приложения: шаблоны Omarchy

`themed/*.tpl` (ссылки в `~/.config/omarchy/themed`) рендерит сам `omarchy-theme-set` из `colors.toml` в корень
темы — синтаксис `{{ accent }}`, `{{ accent_strip }}`, `{{ mix a b 30% }}`. Скрипт направляет на них слоты:

| шаблон | слот | подключение |
|---|---|---|
| `vesktop.css.tpl` | `~/.config/vesktop/themes/omarchy.css` | один раз включить `omarchy.css` в Vesktop → Themes |
| `mpv-osc.conf.tpl` | `~/.config/mpv/script-opts/osc.conf` | встроенный OSC mpv читает сам |
| `qt6ct-colors.conf.tpl` | `~/.config/qt6ct/colors/omarchy.conf` | нужен пакет `qt6ct`: тогда скрипт пишет `qt6ct.conf` (Fusion + иконки темы), а `env.lua` ставит `QT_QPA_PLATFORMTHEME=qt6ct` |

Шаблон попадает в тему только при `omarchy theme set` (`just theme <имя>`), не при `just app-themes`.

## Курсор

`<тема>/apps/cursor` — строка `ИМЯ РАЗМЕР`; без неё `app-defaults/cursor` (или `cursor-light` для `mode = "light"`).
Применяется сразу (`hyprctl setcursor`, gsettings) и сохраняется в `~/.local/state/omarchy/app-themes/cursor`,
откуда его берёт `apps/hyprland/env.lua` при входе.

## Загрузка

`just boot-theme` (`scripts/omarchy-boot-theme`, нужен sudo) перекрашивает шапку `/boot/limine.conf`
(копия — `limine.conf.bak-boot-theme`) и экран Plymouth (`omarchy-plymouth-set-by-theme`). Из хука не
запускается; `just boot-theme --dry-run` показывает diff.

## Новая тема

Положить нужные файлы в `<тема>/apps/` — остальные приложения останутся на `app-defaults`.
