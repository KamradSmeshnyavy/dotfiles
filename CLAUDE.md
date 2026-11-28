# CLAUDE.md

Этот файл даёт Claude Code (claude.ai/code) указания по работе с этим репозиторием.
Полная база знаний — в `AGENTS.md`.

## Обзор

Личные dotfiles для Arch Linux + Omarchy (Hyprland), macOS — вторичная платформа. Симлинки раскладывает
[Dotbot](https://github.com/anishathalye/dotbot) по `install/install.conf.yaml`, команды — в `justfile`.
Репозиторий публичный. Документация — на английском (`name.md`) с русским переводом рядом (`name.ru.md`, переключатель
языка вверху); правка доки — в обоих файлах. Комментарии в коде и сообщения коммитов — на русском.

## Установка

```sh
just link                              # Dotbot + git hooks + AI-скиллы
python3 install/install.py --dry-run   # предпросмотр; флаги идут в Dotbot как есть
python3 install/install.py --only link
just check-links                       # ручные симлинки, не описанные в install.conf.yaml
```

После установки Dotbot выполняет `bat cache --build`.

## Структура

```
dotfiles/
├── justfile             # все команды (рецепты разделены на [linux] / [macos])
├── install/             # install.py, install.conf.yaml, setup-скрипты, packages/
├── .dotbot/             # Dotbot (сабмодуль)
├── apps/                # GUI и окружение (hyprland на Lua, kitty, ghostty, vscode, …)
├── tui/                 # терминальные инструменты (nvim, helix, git, lazygit, yazi, tmux, …)
├── shells/              # nushell (основной), zshrc, fish, starship.toml
├── cli/                 # ssh, p10k, todo
├── omarchy-themes/      # темы Omarchy, хуки и скрипты синхронизации тем; rices/ — сабмодуль omarchy-rices (темы райсов)
├── scripts/             # bin/ → ~/.local/bin, check-links, install-skill.nu
├── skills/              # AI-скиллы + linux_install_map.json
├── macos/               # nix-darwin flake
├── docs/                # описание каждого конфига (EN + .ru.md)
├── wiki/                # исходники GitHub Wiki (EN + -ru), публикация — just wiki-sync
└── archive/             # старое, не трогать
```

## Как работают симлинки

`install/install.conf.yaml` сопоставляет путь в системе → путь в репо. Linux/Darwin-only ссылки защищены
``if: "[ `uname` = Linux ]"`` / ``if: "[ `uname` = Darwin ]"``.

Новый конфиг: создать каталог в нужной категории, добавить `link` в `install/install.conf.yaml`, запустить
`just link` и `just check-links`. Ручная симлинка без записи в конфиге — это баг.

## Ключевые конфиги

- **Оболочка**: Nushell (`shells/nushell/` → `~/.config/nushell`); Zsh — `shells/zshrc/.zshrc`
- **Редактор**: Neovim (`tui/nvim/`), VS Code (`apps/vscode/`)
- **Git**: `tui/git/` → `~/.config/git` (SSH-подпись коммитов); UI — lazygit
- **WM**: Hyprland, конфиг на Lua (`apps/hyprland/` → `~/.config/hypr`); применять через `hyprctl eval`
- **Терминал**: Kitty, Ghostty (шейдеры — сабмодули)
- **Темы**: `omarchy-themes/`; TUI-приложения следуют теме через слоты (`omarchy-themes/APP-THEMING.md`)

## Правила

- Слоты тем (симлинки из `.gitignore`, например `tui/lazygit/theme.yml`) не править и не коммитить —
  менять файл внутри темы и запускать `just app-themes`.
- Не коммитить секреты; pre-commit прогоняет gitleaks.
- Коммиты — Conventional Commits: `feat(theme)!: …`, `fix(vscode): …`, `chore(install): …`.
- `cat` здесь — `bat`, `curl` — `curlie`: в командах использовать `command cat` / `command curl`.
- Не делать `rm` по путям из переменных.

## Сабмодули

`.dotbot`, `apps/ghostty/shaders`, `apps/ghostty/cursors`, `apps/sketchybar`,
`omarchy-themes/thinkpad-boot-screen`, `omarchy-themes/rices`. После клонирования: `git submodule update --init --recursive`.

Темы райсов (vitreus, unit3, yami, bruteon, cozytile, rumda, surface, nothing/Glyph, dot-matrix), их генераторы и
`omarchy-rice-dynamic` (+ Iris) — сабмодуль `omarchy-themes/rices` = публичный репо omarchy-rices (GPL-3.0; у него свой
`install.sh`, ставит Customizer компаньоном `rices`). Правка темы райса = коммит и пуш в сабмодуле, затем указатель.
Оригинальные обои райсов (`0-original.*`, `0r-*`) в его git не входят — скачиваются при сборке.

Свои плагины omarchy-shell — тоже сабмодули, это отдельные публичные репо (правка = коммит и пуш в
сабмодуле, затем коммит нового указателя в dotfiles): `kamradsmeshnyavy.bar` → omarchy-bar-skins,
`.lock` → omarchy-lock-designs, `.background` → omarchy-wallpaper-fx, `.image-picker` →
omarchy-image-picker-styles, `.customizer` → omarchy-customizer (GPL-3.0: пресеты анимаций из HyDE/ML4W/end-4;
в нём же шейдеры экрана, opacity/blur, перекраска обоев, хук `hypr/customizer.lua` и i18n — строки на
английском, перевод в `i18n/ru.json`, язык из `~/.config/omarchy/customizer.json`; бэкенд — Python в `backend/`
(один процесс `serve`, пока открыт overlay), описания настроек — `settings.json`; правку бэкенда сверять
`tests/compare_*.py` с эталоном `tests/legacy/customizer.sh`), `.widgets` →
omarchy-desktop-widgets (виджеты, дашборд, меню выключения, обзор столов), `.osd` → omarchy-edge-osd,
`.notifications` → omarchy-drawer-notifications (оба — клоны стока, правки помечены `// edge:` / `// drawer:`).
`BarStyle.qml`, `StyleCard.qml`, `LiquidGlass.qml` (+ `shaders/liquidglass.frag`, его копия есть и в bar), `MergeFillet.qml`, `MergeInfo.qml` и `BaseDecor.qml` одинаковые в widgets/osd/notifications — правку переносить во все три (BarStyle читает
токены стиля из `~/.config/omarchy/style.json`, их пишет Customizer → Пресеты → Стиль). Так же `dotmatrix/Palette.qml`
(палитра стиля DOT-MATRIX, `docs/apps/omarchy-shell-dotmatrix.md`) одинаковый в widgets/osd/notifications/bar/menu/lock/customizer
и шести DOT-MATRIX-панелях:
цвета DOT-MATRIX — только через него, не hex.
Райс Quest (пиксельный, свой; `omarchy-themes/rices/quest`, общий набор `rices/pixel/kit.py`): `QuestPal.qml` и `QuestWin.qml`
одинаковые в bar/modules, widgets, osd, notifications/components, lock/designs, image-picker (только Pal) и menu —
правку переносить во все; цвета окон — из `quest.json` темы.
Клоны стоковых виджетов бара в стиле DOT-MATRIX — `kamradsmeshnyavy.{tray,network,bluetooth,audio,monitor,agents}` —
тоже сабмодули, репо `omarchy-dotmatrix-<имя>` (правки помечены `// dotmatrix:`, у каждого своя копия `dotmatrix/Palette.qml`). Лаунчер `kamradsmeshnyavy.menu` остаётся в dotfiles (в нём порты без
лицензии); публичная копия без портов — `just publish-launcher` в клон `~/src/omarchy-launcher-skins`.
