# CLAUDE.md

Этот файл даёт Claude Code (claude.ai/code) указания по работе с этим репозиторием.
Полная база знаний — в `AGENTS.md`.

## Обзор

Личные dotfiles для Arch Linux + Omarchy (Hyprland), macOS — вторичная платформа. Симлинки раскладывает
[Dotbot](https://github.com/anishathalye/dotbot) по `install/install.conf.yaml`, команды — в `justfile`.
Репозиторий публичный; комментарии и документация на русском.

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
├── omarchy-themes/      # темы Omarchy, хуки и скрипты синхронизации тем
├── scripts/             # bin/ → ~/.local/bin, check-links, install-skill.nu
├── skills/              # AI-скиллы + linux_install_map.json
├── macos/               # nix-darwin flake
├── docs/                # описание каждого конфига
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
`omarchy-themes/thinkpad-boot-screen`. После клонирования: `git submodule update --init --recursive`.

Свои плагины omarchy-shell — тоже сабмодули, это отдельные публичные репо (правка = коммит и пуш в
сабмодуле, затем коммит нового указателя в dotfiles): `kamradsmeshnyavy.bar` → omarchy-bar-skins,
`.lock` → omarchy-lock-designs, `.background` → omarchy-wallpaper-fx, `.image-picker` →
omarchy-image-picker-styles. Лаунчер `kamradsmeshnyavy.menu` остаётся в dotfiles (в нём порты без
лицензии); публичная копия без портов — `just publish-launcher` в клон `~/src/omarchy-launcher-skins`.
Customizer — только в dotfiles.
