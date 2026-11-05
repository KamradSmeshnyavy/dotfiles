<h1 align="center">
  🌌 Omarchy dotfiles — кастомизация плагинами
  <br>
  <img src="https://img.shields.io/github/commit-activity/y/KamradSmeshnyavy/dotfiles?style=for-the-badge&labelColor=%23222436&color=%235771AA" alt="Commit Frequency">
</h1>

<p align="center">
  <i>Arch Linux + <a href="https://omarchy.org">Omarchy</a> (Hyprland), переделанный в <b>15 устанавливаемых плагинов Omarchy</b>
  и <b>Customizer</b>, который меняет весь рабочий стол одним кликом — без правки конфигов.</i>
  <br>
  <a href="README.md">🇬🇧 English</a> · 🇷🇺 Русский · <a href="https://github.com/KamradSmeshnyavy/dotfiles/wiki">📖 Wiki</a>
</p>

<p align="center">
  <img src="assets/demo-preview.webp" alt="Демо: тайлинг, compact-бар, музыка, браузер, переключение workspace, скины лаунчера, Customizer, переход обоев" width="100%">
  <br>
  <sub>🎬 Полное видео со звуком (89 с, 🎵 Lane 8 — Little by Little): тайлинг, compact-бар, workspace, скины лаунчера, Customizer — <a href="assets/demo.mp4">assets/demo.mp4</a></sub>
</p>

<!-- Видео играет прямо в README, если ссылка user-attachments стоит отдельной строкой без <>.
     rumdl (MD034) иначе оборачивает её в <> — отсюда комментарий ниже.
     После обновления assets/demo.mp4 перетащи его в редактор README на GitHub и замени ссылку. -->
<!-- rumdl-disable-next-line MD034 -->
https://github.com/user-attachments/assets/b56f581c-844a-47e7-b27d-a467b0e2e1aa

---

## ✨ Чем этот репозиторий отличается

Обычные dotfiles — это куча конфигов, которые копируешь и потом правишь руками. Здесь внешний вид рабочего стола
собран из **отдельных плагинов оболочки Omarchy**: у каждого свой репозиторий, каждый ставится одной командой —
вместе с остальными dotfiles или без них:

- **Один оверлей на всё.** [Customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) (`Super+Shift+T`)
  переключает темы, обои, скины бара, дизайны экрана блокировки, скины лаунчера, анимации, размытие,
  прозрачность, шейдеры экрана, шрифты и целые *стили* — с живым превью, и выбор переживает перезагрузку.
- **Стили, а не только цвета.** Тема задаёт палитру, **стиль** — форму: Flat, Glass, Fluent, Paper, Neon,
  Neumorph, Brutal, Retro и **DOT-MATRIX** (точечные шрифты в духе Nothing OS, LED-шкалы, «железные» карточки).
  Любой стиль на любой теме.
- **Всё следует теме.** Терминалы, все TUI-приложения, VS Code, GTK/Qt, Firefox и Helium (Dark Reader, Stylus,
  интерфейс Firefox), даже экран загрузки — одна смена темы перекрашивает всё.
- **Профили шрифтов.** Одна команда (или клик в Customizer) меняет шрифты всей системы: стоковый Maple Mono,
  Geist с точечными заголовками в духе Nothing, пиксельные терминалы, рукописный Paper, точки везде…
- **Безопасно пробовать.** Каждый плагин заменяет стоковый и возвращается обратно командой
  `omarchy plugin enable omarchy.<имя>`.

---

## 🧩 Плагины Omarchy

Любой ставится на чистый Omarchy 4 — dotfiles не нужны. Плагины поданы в официальный каталог
[plugins.omarchy.org](https://plugins.omarchy.org).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-customizer --enable
```

| Плагин | Что даёт |
| :--- | :--- |
| [**Customizer**](https://github.com/KamradSmeshnyavy/omarchy-customizer) | центр управления: пресеты и стили, темы, обои, перекраска (lutgen), Dotify, 19 пресетов анимаций, прозрачность, размытие, шейдеры CRT/TFT, звуки, подсветка Glyph — и настройки всех плагинов ниже |
| [Bar Skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) | верхний бар: 24 скина, 10 раскладок, компактный режим с раскрытием по наведению, LED- и glyph-стили рабочих столов |
| [Lock Designs](https://github.com/KamradSmeshnyavy/omarchy-lock-designs) | 23 дизайна экрана блокировки и дизайны под стили, поверх стокового PAM |
| [Launcher Skins](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins) | полноэкранные скины лаунчера: звёздная карта, CRT-терминал, оррерий, аквариум, таро, metro… |
| [Wallpaper FX](https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx) | 24 перехода обоев на одном шейдере |
| [Image Picker Styles](https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles) | шесть стилей выбора темы и обоев |
| [Desktop Widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets) | часы, сейчас играет, cava, системные шкалы, todo, цитаты, фоторамка, дашборд, меню выключения, обзор рабочих столов |
| [Edge OSD](https://github.com/KamradSmeshnyavy/omarchy-edge-osd) | громкость и яркость выезжают из края экрана (или LED-шкала DOT-MATRIX) |
| [Drawer Notifications](https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications) | уведомления выдвижной панелью или «железными» тостами DOT-MATRIX |
| Панели DOT-MATRIX: [Tray](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-tray) · [Wi-Fi](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-network) · [Bluetooth](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-bluetooth) · [Sound](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-audio) · [Display](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-monitor) · [Agents](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-agents) | стоковые панели бара, перерисованные в стиле DOT-MATRIX |

Customizer сам находит остальные плагины. Всё сразу — его
[install.sh](https://github.com/KamradSmeshnyavy/omarchy-customizer/blob/main/README.ru.md#установка) с `--all`.

---

## 📸 Галерея

| Рабочий стол (Hyprland + свой бар) | Терминал (Kitty + Nushell + fastfetch) |
| :---: | :---: |
| ![Desktop](assets/desktop-hyprland.webp) | ![Terminal](assets/kitty-terminal.webp) |
| **Customizer** (Super+Shift+T) | **Лаунчер** (скин terminal, Super+Alt+Space) |
| ![Customizer](assets/customizer.webp) | ![Launcher](assets/launcher.webp) |
| **Neovim** | **Yazi** |
| ![Neovim](assets/neovim-editor.webp) | ![Yazi](assets/yazi-filemanager.webp) |
| **Музыка** (Spotifast + cava) | **Браузер** (Firefox в цветах темы через Dark Reader / Stylus) |
| ![Music](assets/music.webp) | ![Browser](assets/browser.webp) |

---

## 🚀 Что внутри dotfiles

| Категория | Что используется |
| :--- | :--- |
| 🪟 **WM** | **Hyprland** с конфигом на Lua (`apps/hyprland/`), применяется через `hyprctl eval`. macOS (вторичная) — yabai / AeroSpace / skhd / SketchyBar. |
| 🎨 **Темы** | Свои темы Omarchy в `omarchy-themes/` (Nothing, DOT-MATRIX, Rose Pine Hacker, Pastel Hacker, Catppuccin Mocha, Nord, Black Arch, …) и тема из любых обоев (matugen). TUI-приложения следуют теме через слоты ([APP-THEMING](omarchy-themes/APP-THEMING.md)), браузеры — через Dark Reader, Stylus и Surfingkeys ([BROWSER-THEMING](omarchy-themes/BROWSER-THEMING.md)), Limine и Plymouth тоже. |
| 🔤 **Шрифты** | `omarchy-font-profile` — 21 профиль шрифтов всей системы (терминалы, GTK, VS Code, браузеры, оболочка), свои шрифты DotMatrix из OFL-исходников. |
| 🖥️ **Терминалы** | **Kitty** (основной), Ghostty (шейдеры и курсоры — сабмодули). |
| 🐚 **Оболочки** | **Nushell** (основная), Zsh, Fish; промпт — **Starship**. |
| 📝 **Редакторы** | **Neovim** (Lua), Helix, **VS Code** со своим CSS. |
| 🗃️ **Мультиплексоры** | **tmux**, Zellij. |
| 🛠️ **CLI / TUI** | yazi, lazygit / gitui / delta, bat, eza / lla, btop / procs, fzf / television, zoxide, atuin, glow, rmpc / cava, fastfetch. |
| 🌐 **Браузеры** | Firefox и Helium: расширения в цветах темы, сгенерированный `userChrome.css`, трёхсторонняя синхронизация закладок между ними (`bookmarks-sync`). |
| ⌨️ **Ввод** | kanata, mouseless, wl-kbptr; на macOS — Karabiner и Hammerspoon. |

### 🧰 Утилиты

Каждая TUI-утилита берёт цвета текущей темы Omarchy (`just app-themes`).

| Delta | LazyGit |
| :---: | :---: |
| [![delta](assets/delta.webp)](assets/delta.webp) | [![lazygit](assets/lazygit.webp)](assets/lazygit.webp) |
| **eza и lla** | **bat** |
| [![eza_lla](assets/eza_lla.webp)](assets/eza_lla.webp) | [![bat](assets/bat.webp)](assets/bat.webp) |
| **tmux** | **fzf** |
| [![tmux](assets/tmux.webp)](assets/tmux.webp) | [![fzf](assets/fzf.webp)](assets/fzf.webp) |
| **btop** | **procs** |
| [![btop](assets/btop.webp)](assets/btop.webp) | [![procs](assets/procs.webp)](assets/procs.webp) |
| **Television** | **Scooter** |
| [![television](assets/television.webp)](assets/television.webp) | [![scooter](assets/scooter.webp)](assets/scooter.webp) |

---

## 🛠️ Установка всей системы

```sh
# 1. Клонировать с сабмодулями
git clone --recursive https://github.com/KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Пакеты + симлинки (меню: только пакеты / только dotfiles / всё)
./install/bootstrap.sh

# Только симлинки (Dotbot) + git hooks + git-фильтры + AI-скиллы, если пакеты уже стоят
just link
just check-links      # ручные симлинки, которых нет в install/install.conf.yaml
just app-themes       # перенаправить слоты тем приложений на текущую тему
```

Предпросмотр: `python3 install/install.py --dry-run`. Все команды — `just` без аргументов.
По шагам — [docs/INSTALL.ru.md](docs/INSTALL.ru.md) и [wiki](https://github.com/KamradSmeshnyavy/dotfiles/wiki).

Нужны `git`, `python3`, `just`, `base-devel` и Nerd Font (по умолчанию **Maple Mono NF CN**).

---

## 📁 Структура

```text
dotfiles/
├── justfile           # все команды (рецепты разделены на Linux / macOS)
├── install/           # bootstrap.sh, install.py, install.conf.yaml (Dotbot), packages/
├── apps/              # GUI и окружение: hyprland, omarchy-shell (плагины — сабмодули), kitty, ghostty, vscode, …
├── tui/               # терминальные инструменты: nvim, helix, git, lazygit, yazi, tmux, …
├── shells/            # nushell, zshrc, fish, starship.toml
├── cli/               # ssh, p10k, todo
├── omarchy-themes/    # темы Omarchy, хуки и скрипты синхронизации тем
├── scripts/           # bin/ → ~/.local/bin, git-фильтры, check-links, install-skill.nu
├── skills/            # AI-скиллы для агентов
├── macos/             # nix-darwin flake
├── docs/              # по странице на конфиг: docs/{apps,tui,shells,cli}/<имя>.md (английский, + .ru.md)
├── wiki/              # исходники GitHub Wiki (EN + -ru), публикация — `just wiki-sync`
└── assets/            # скриншоты и демо
```

📖 Гайды — [wiki](https://github.com/KamradSmeshnyavy/dotfiles/wiki). Заметки для AI-агентов (Claude Code, Codex, …) —
[AGENTS.md](AGENTS.md).

## Лицензия

MIT — см. [LICENSE](LICENSE). У плагинов свои лицензии (MIT; Customizer — GPL-3.0).
