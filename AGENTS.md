# База знаний по dotfiles

Документ для AI-агентов (Claude Code, Codex, OpenCode и др.): устройство репозитория, соглашения и типовые задачи.

## Обзор

Личные dotfiles для **Arch Linux + [Omarchy](https://omarchy.org)** (Hyprland). Основная платформа — Linux;
macOS-конфиги (nix-darwin, yabai, skhd, aerospace, sketchybar, karabiner) сохранены и подключаются только на Darwin.
Симлинки раскладывает [Dotbot](https://github.com/anishathalye/dotbot), команды собраны в `justfile`.
Комментарии, документация и рецепты — на русском.

Репозиторий **публичный**: секреты не коммитить (стоит pre-commit хук с gitleaks).

## Структура

```
dotfiles/
├── apps/               # GUI-приложения и окружение: hyprland (Lua), kitty, ghostty, vscode, rofi,
│                       #   kanata, mouseless, wl-kbptr, omarchy-shell, browser, qutebrowser, wezterm;
│                       #   macOS: aerospace, yabai, skhd, sketchybar (сабмодуль), karabiner, borders, hammerspoon
├── tui/                # TUI/CLI-инструменты: nvim, helix, git, lazygit, gitui, yazi, tmux, zellij,
│                       #   bat, btop, atuin, lla, eza, television, rmpc, mpd, ncmpcpp, cava, …
├── shells/             # nushell (основной), zshrc, fish, fsh, starship.toml, ohmyposh
├── cli/                # ssh, p10k, todo
├── omarchy-themes/     # Свои темы Omarchy + скрипты синхронизации тем приложений и браузеров
│   ├── <тема>/         #   catppuccin-mocha-efter, pastel-hacker*, rose-pine-hacker*, nord, black-arch-*
│   ├── app-defaults/   #   фолбэк-файлы для слотов тем приложений
│   ├── scripts/        #   omarchy-app-themes, omarchy-tmux-theme, omarchy-darkreader, omarchy-stylus, …
│   ├── hooks/          #   theme-set, post-boot.d/ → ~/.config/omarchy/hooks
│   ├── APP-THEMING.md  #   как TUI-приложения следуют теме (слоты)
│   └── BROWSER-THEMING.md
├── scripts/            # bin/ (→ ~/.local/bin), check-links, install-skill.nu, обои через lutgen
├── skills/             # AI-скиллы + linux_install_map.json (какой скилл в какой агент)
├── install/            # install.py, install.conf.yaml (Dotbot), bootstrap/setup-скрипты, packages/
├── macos/              # nix, nix-darwin (flake)
├── docs/               # Описание каждого конфига: docs/{apps,tui,shells,cli}/<имя>.md, INSTALL.md
├── archive/            # Старые конфиги — не трогать и не подключать
├── mics/               # Разное (tlp.conf, шаблоны)
├── .dotbot/            # Dotbot (сабмодуль)
├── .githooks/          # pre-commit: gitleaks
└── justfile            # Точка входа для всех команд
```

## Установка и команды

```sh
just                 # список рецептов для текущей ОС
just link            # install/install.py → Dotbot, core.hooksPath=.githooks, install-skill
just check-links     # найти ручные симлинки на ~/dotfiles, которых нет в install.conf.yaml
just theme [имя]     # omarchy theme set / list
just app-themes      # перенаправить слоты тем приложений на текущую тему
just yazi-plugins    # ya pkg install
just install-skill   # раскидать skills/ по агентам (--dry-run, --copy)

python3 install/install.py --dry-run   # предпросмотр Dotbot; флаги передаются в Dotbot как есть
```

`install.py` синхронизирует сабмодули, затем запускает Dotbot с `install/install.conf.yaml`.
В конце Dotbot выполняет `bat cache --build`.

## Симлинки (Dotbot)

`install/install.conf.yaml` сопоставляет путь в системе → путь в репо. Почти всё идёт в `~/.config/` (XDG).
Платформенные ссылки защищены `if`:

```yaml
~/.config/hypr:
  path: apps/hyprland
  if: "[ `uname` = Linux ]"
```

Любая симлинка на `~/dotfiles` должна быть описана здесь, иначе на новой машине её не будет.
`just check-links` это проверяет.

### Добавить новый конфиг

1. Положить файлы в нужную категорию (`apps/`, `tui/`, `shells/`, `cli/`).
2. Добавить запись в `install/install.conf.yaml` (с `if:` для Linux/Darwin-only).
3. Если появляются генерируемые или содержащие состояние файлы — в `.gitignore`.
4. По желанию: `docs/<категория>/<имя>.md`.
5. `just link`, затем `just check-links`.

## Система тем

Тема задаётся Omarchy (`omarchy theme set`). Свои темы лежат в `omarchy-themes/<тема>/` и линкуются
в `~/.config/omarchy/themes/`. Файлы темы: `colors.toml`, `kitty.conf`, `ghostty.conf`, `neovim.lua`,
`btop.theme`, `waybar.css`, `hyprland.conf`, `backgrounds/` и т. д.

При смене темы хук `omarchy-themes/hooks/theme-set` вызывает скрипты из `omarchy-themes/scripts/`:
tmux, zsh, app-themes, Dark Reader, Stylus, Surfingkeys.

**Слоты тем приложений** (подробно — `omarchy-themes/APP-THEMING.md`): yazi, lazygit, atuin, lla,
television, gitui, rmpc, nushell, tmux, fzf читают тему из файла-слота. Слот — симлинка (в `.gitignore`),
которую `omarchy-app-themes` направляет на `apps/<файл>` текущей темы или на `app-defaults/<файл>`.
Не коммитить слоты и не править их напрямую — правьте файл в теме.

Браузеры (Helium, Firefox): `omarchy-themes/BROWSER-THEMING.md`.

## Оболочки

- **Nushell** — основная: `shells/nushell/{config.nu,env.nu}`, `aliases/`, `completions/`, `themes/`, `platform/`.
- Zsh: `shells/zshrc/.zshrc` (→ `~/.zshrc`), prompt — `shells/starship.toml`.
- Fish, fsh, oh-my-posh — запасные.

## Hyprland

Конфиг на **Lua** (`apps/hyprland/*.lua`, точка входа `hyprland.lua`): `bindings.lua`, `looknfeel.lua`,
`monitors.lua`, `input.lua`, `windows.lua`, `autostart.lua`. Применять изменения через `hyprctl eval`,
а не `hyprctl keyword`. Шейдеры переключаются скриптом, а не правкой конфига.

## AI-скиллы

`skills/<имя>/` — скиллы для агентов. `skills/linux_install_map.json` указывает, в каких агентов
(`claude`, `codex`, `opencode`) ставить каждый скилл. Установка — `just install-skill`.

## Git

- Conventional Commits: `type(scope): описание`, `!` для заметных изменений —
  `feat(theme)!: rose-pine`, `fix(vscode): …`, `chore(install): …`.
- Коммиты подписываются SSH-ключом (`tui/git/`).
- pre-commit: `gitleaks` (`.githooks/pre-commit`); обходить `--no-verify` только при ложном срабатывании.
- Сабмодули (`.gitmodules`): `.dotbot`, `apps/ghostty/shaders`, `apps/ghostty/cursors`, `apps/sketchybar`,
  `omarchy-themes/thinkpad-boot-screen`. После клонирования: `git submodule update --init --recursive`.
- Плагины omarchy-shell `kamradsmeshnyavy.{bar,lock,background,image-picker}` — сабмодули, отдельные
  публичные репо (omarchy-bar-skins, omarchy-lock-designs, omarchy-wallpaper-fx,
  omarchy-image-picker-styles). Правка: коммит и пуш внутри сабмодуля, потом коммит указателя в dotfiles.
  README репо — на английском (+ README.ru.md), их тоже держать в актуальном виде.
- Лаунчер `kamradsmeshnyavy.menu` не сабмодуль: 17 скинов портированы из omlauch / omarchy-quickapps
  без лицензии. Публичная копия без них — omarchy-launcher-skins, обновляется `just publish-launcher`
  (`scripts/publish-launcher`) в клон `~/src/omarchy-launcher-skins`.

## Подводные камни

- В интерактивной оболочке `cat` — это `bat`, `curl` — `curlie`. В скриптах использовать `command cat`
  и `command curl`.
- Не делать `rm` по путям, собранным из переменных; для временных файлов — свежий `mktemp -d`.
- Многие конфиги — симлинки в `~/.config`: правьте файл в репо, а не копию.
- Не трогать `archive/` и `*.bak`; `history.txt`, `lazy-lock.json`, `state.*` — в `.gitignore`.
- Не линковать `~/.config/chromium` целиком: на Linux это профиль браузера. Конфиги браузеров — в
  `apps/browser/`, линкуются отдельными файлами (`chromium-flags.conf`, `helium-flags.conf`, tridactyl).

## Ссылки

- Установка: `docs/INSTALL.md`
- Описание конфигов: `docs/apps/`, `docs/tui/`, `docs/shells/`, `docs/cli/`
- Темы приложений: `omarchy-themes/APP-THEMING.md`
- Темы браузеров: `omarchy-themes/BROWSER-THEMING.md`
- nix-darwin: `macos/nix-darwin/README.md`
