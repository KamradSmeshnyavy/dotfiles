# Темы CLI/TUI-приложений для тем Omarchy

[🇬🇧 English](APP-THEMING.en.md)

`scripts/omarchy-app-themes` (запускается из `hooks/theme-set` и `hooks/font-set`) красит приложения, которые Omarchy сам не трогает.

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
| `fastfetch.jsonc` | `~/.config/fastfetch/config.jsonc` | fastfetch читает сам |
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
| `vesktop.css.tpl` | `~/.config/vesktop/themes/omarchy.css` | скрипт сам включает `omarchy.css` + `omarchy-fonts.css` (см. ниже) |
| `mpv-osc.conf.tpl` | `~/.config/mpv/script-opts/osc.conf` | встроенный OSC mpv читает сам |
| `qt6ct-colors.conf.tpl` | `~/.config/qt6ct/colors/omarchy.conf` | нужен пакет `qt6ct`: тогда скрипт пишет `qt6ct.conf` (Fusion + иконки темы), а `env.lua` ставит `QT_QPA_PLATFORMTHEME=qt6ct` |

Шаблон попадает в тему только при `omarchy theme set` (`just theme <имя>`), не при `just app-themes`.

## GUI-приложения: генераторы

Для этих приложений у темы может быть свой файл `apps/<файл>` (сделанный руками); если его нет, скрипт собирает его
из `colors.toml` в `~/.local/state/omarchy/app-themes/generated-<файл>`. Роли цветов (фон, поверхность, выделение,
акцент…) у всех генераторов общие — `scripts/theme_palette.py`. Шрифты берутся из fontconfig (`sans-serif`,
`monospace`), поэтому после `omarchy font set` (хук `hooks/font-set`) и `omarchy-font-profile` скрипт тоже запускается.

| файл темы | генератор | куда | когда видно |
|---|---|---|---|
| `gtk4.css` | `omarchy-gtk-theme` | `~/.config/gtk-4.0/gtk.css` (переменные libadwaita) | новые окна GTK4 (Nautilus, порталы) |
| `gtk3.css` | `omarchy-gtk-theme --gtk3` | `~/.config/gtk-3.0/gtk.css` (`@define-color`) | новые окна; нужна тема `adw-gtk3` (пакет `adw-gtk-theme`) — скрипт ставит её вместо Adwaita |
| `ghidra.theme` | `omarchy-ghidra-theme` | `~/.config/ghidra/ghidra_*/themes/omarchy.theme` + `Theme=` в `preferences` | при следующем запуске Ghidra; пока она запущена, `preferences` не трогается |
| `telegram.tdesktop-theme` | `omarchy-telegram-theme` | `~/.local/state/omarchy/app-themes/omarchy.tdesktop-theme` | сразу, после одного ручного применения (ниже) |

Ghidra: цвета FlatLaf (`[laf.color]Panel.background` и др. — `system.color.bg.control` панели не красит),
листинг, декомпилятор, закладки; `font.standard` / `font.monospaced` — шрифты системы, кегль 13.

**Telegram** хранит тему у себя, но за файлом применённой темы следит (`QFileSystemWatcher`) и перечитывает его.
Поэтому применить нужно один раз: `omarchy-app-themes telegram` открывает в Telegram «Переслать…» с этим файлом →
отправить в «Избранное» → нажать на файл → «Применить». Дальше файл обновляется на месте при каждой смене темы.
Telegram 7 не открывает `.tdesktop-theme` из командной строки как предпросмотр — только как «Переслать».
Ключи палитры — `scripts/data/telegram-palette.tsv` (из lib_ui; обновить: `omarchy-telegram-theme --update-palette`):
серые светлой темы по умолчанию идут на шкалу фон…текст, цветные — на ближайший по оттенку цвет темы, исходящие
сообщения — на акцент. Просмотр медиа и звонки (тёмные по замыслу) не трогаются.

**Vesktop**: `omarchy-fonts.css` (шрифты системы) пишет скрипт; `enabledThemes` = `omarchy.css` + `omarchy-fonts.css`
выставляется, только когда Vesktop закрыт. Vencord не замечает смену файла за симлинком, поэтому скрипт делает
`touch -h` на ссылку — тема меняется без перезапуска. Стоковый `discord` CSS не принимает.

**Qt**: `qt6ct.conf` получает и шрифты (`[Fonts]`). Нужен пакет `qt6ct` и перелогин. Telegram — Qt, но рисует себя сам.

Не перекрашиваются: Signal и Bitwarden (только светлая/тёмная — следуют `color-scheme`), Spotify (только через
spicetify), LibreOffice/OnlyOffice (частично — GTK3).

## Курсор

`<тема>/apps/cursor` — строка `ИМЯ РАЗМЕР`; без неё `app-defaults/cursor` (или `cursor-light` для `mode = "light"`).
Применяется сразу (`hyprctl setcursor`, gsettings) и сохраняется в `~/.local/state/omarchy/app-themes/cursor`,
откуда его берёт `apps/hyprland/env.lua` при входе.

## Тема из обоев

`just theme-from-wallpaper [обои] [--scheme vibrant|expressive|…] [--mode light]` (`scripts/omarchy-wallpaper-theme`,
в `PATH` как `omarchy-wallpaper-theme`) прогоняет обои через matugen и пишет тему
`~/.config/omarchy/themes/dynamic`: только `colors.toml` (Material You + ANSI-цвета, смещённые к цвету обоев),
`icons.theme` (Yaru по оттенку акцента) и сами обои. Остальное — терминалы, btop, nvim, Hyprland, шаблоны выше,
слоты, браузеры — генерирует `omarchy-theme-set`. В Customizer → Тема — строки «🎨 Тема из обоев».

## Загрузка

`just boot-theme` (`scripts/omarchy-boot-theme`, нужен sudo) перекрашивает шапку `/boot/limine.conf`
(копия — `limine.conf.bak-boot-theme`) и экран Plymouth (`omarchy-plymouth-set-by-theme`). Из хука не
запускается; `just boot-theme --dry-run` показывает diff.

## Новая тема

Положить нужные файлы в `<тема>/apps/` — остальные приложения останутся на `app-defaults`.
