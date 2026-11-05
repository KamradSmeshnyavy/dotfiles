[English](Themes-and-App-Theming) · **Русский**

# Темы и приложения

Тема Omarchy задаёт цвета и обои. Здесь **одна смена темы перекрашивает всё**, а не только то, что трогает сам Omarchy.

```sh
just theme                  # список
just theme nothing          # применить (то же, что `omarchy theme set nothing`)
just theme-from-wallpaper   # «динамическая» тема из текущих обоев (matugen; --scheme vibrant, --mode light)
```

Или в Customizer: Рабочий стол → Тема (с превью палитры), или `>theme` в лаунчере.

## Мои темы

Темы ручной работы в [`omarchy-themes/`](https://github.com/KamradSmeshnyavy/dotfiles/tree/main/omarchy-themes): Nothing,
DOT-MATRIX, Rose Pine Hacker / Hacker24, Pastel Hacker, Catppuccin Mocha (Efter, Lavender), Nord, Black Arch… Каждая
может нести свои темы приложений в `apps/`, звуки в `apps/sounds/`, цветовую схему Neovim в `nvim/`.

## Что следует теме

| Что | Как |
|---|---|
| kitty, ghostty | `theme.conf` текущей темы; стиль Customizer добавляет `style.conf` |
| yazi, lazygit, atuin, lla, television, gitui, rmpc, nushell, tmux, fastfetch, fzf | **слоты тем** — игнорируемые git симлинки, которые `omarchy-app-themes` перенаправляет при каждой смене темы ([APP-THEMING](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/omarchy-themes/APP-THEMING.md)) |
| Neovim | собственная схема темы из `~/.local/state/omarchy/current/theme/nvim` |
| Zsh | `omarchy-zsh-colors` |
| VS Code | стоковый `omarchy-theme-set-vscode` |
| GTK, Qt (qt6ct), Ghidra, Vesktop, Telegram | генерирует `omarchy-app-themes` |
| Firefox, Helium | Dark Reader, Stylus, Surfingkeys, `userChrome.css` Firefox — см. [Браузеры](Browsers-ru) |
| Плагины оболочки | цвета Quickshell из темы; палитра DOT-MATRIX тоже следует ей |
| Загрузка | `just boot-theme` — Limine и Plymouth в цветах темы (нужен sudo) |

Всё это запускает хук Omarchy `theme-set` (`omarchy-themes/hooks/theme-set`), руками ничего делать не нужно.

## Своя тема

Цвета темы — в `colors.toml`; файлы для приложений — в `apps/` темы (`yazi.toml`, `lazygit.yml`, `tmux.conf`, …). Тема
без них берёт `omarchy-themes/app-defaults`. После правок `just app-themes` перенаправит слоты. **Сами файлы слотов не
править** — менять файл внутри темы.
