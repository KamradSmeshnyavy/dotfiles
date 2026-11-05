[English](Hyprland-and-Terminals) · **Русский**

# Hyprland и терминалы

## Hyprland (Lua)

Конфиг на Lua поверх настроек Omarchy 4: `hyprland.lua` грузит Omarchy, затем мои `monitors`, `input`, `bindings`,
`windows`, `looknfeel`, `autostart`, `env`. Применять **`hyprctl eval`** или `hyprctl reload` — с Lua
`hyprctl keyword` и обычный `hyprctl dispatch` ничего не делают.

Самые полезные бинды: `Super+Shift+T` Customizer, `Super+M` настройки, `` Super+` `` обзор, `Super+Alt+D` дашборд,
`Super+Esc` меню выключения, `Super+Alt+C/O/U` пресеты шейдера / прозрачности / блюра, `Super+H/J/K/L` умный фокус.
Полный список: [docs/apps/hyprland.ru.md](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/hyprland.ru.md).

## Терминалы

- **Kitty** (основной): по умолчанию Maple Mono NF CN, kitty-scrollback.nvim (`Alt+P`), размытие, тема из Omarchy,
  стиль Customizer (`style.conf`) и профиль шрифтов (`fonts.conf`).
- **Ghostty**: шейдеры и шейдеры курсора (сабмодули), те же подключения темы / стиля / шрифтов.

## Оболочка и утилиты

**Nushell** + **Starship**; Zsh — запасная. Каждая TUI-утилита (yazi, lazygit, btop, tmux, atuin, television, gitui,
rmpc, fastfetch, fzf…) следует теме — см. [Темы и приложения](Themes-and-App-Theming-ru). Neovim (LazyVim) тоже берёт
цветовую схему из темы.
