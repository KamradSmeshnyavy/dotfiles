# Yazi

[🇬🇧 English](yazi.md)

Очень быстрый терминальный файловый менеджер на Rust с асинхронным вводом-выводом и превью.

## Пути

- **В репозитории:** `tui/yazi`
- **Линкуется в:** `~/.config/yazi`

## Отличия от настроек по умолчанию

Сильно расширен плагинами и Lua-скриптами (`init.lua`).

### Плагины (`package.toml`)

- **Системы:** `git` / `vcs-files` — статус файлов, `mactag` — теги macOS.
- **Вид:** `full-border`, `max-preview`.
- **Удобство:** `smart-enter`, `chmod`, `clipboard`, `mount`, `ouch` (архивы любых форматов).
- Нечёткий поиск `television`.

### Тема и UI

- **Цвета следуют теме Omarchy:** `theme.toml` — слот на `yazi.toml` текущей темы, flavor — `omarchy`
  (`flavors/omarchy.yazi`), плагин статус-бара yatline (`yatline-omarchy.yazi`) тоже по теме.
- Свой статус-бар на Lua (`init.lua`) с прогрессом и метаданными.

### Клавиши (`keymap.toml`)

Большой keymap: Vim-навигация и быстрый доступ к плагинам (архивы, поиск, git).
