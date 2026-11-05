# Ghostty

[🇬🇧 English](ghostty.md)

Быстрый кроссплатформенный терминал с нативным UI и GPU-рендерингом — здесь второй терминал, в основном ради шейдеров.

## Пути

- **В репозитории:** `apps/ghostty` (`shaders/` и `cursors/` — сабмодули)
- **Линкуется в:** `~/.config/ghostty`

## Отличия от настроек по умолчанию

### Внешний вид и шрифты

- `config` держит шрифт stock: **Maple Mono NF CN**, размер 12, с её наборами лигатур `ss01` (`!=`, `===`), `ss02`
  (`<=`, `>=`), `ss03` (`->`), `ss04` (`</>`) и `-calt`.
- Профиль шрифтов (`omarchy-font-profile`) пишет неотслеживаемый `fonts.conf` (`config-file = ?fonts.conf`): сбрасывает
  `font-family` / `font-feature` пустым значением и ставит шрифт профиля, `calt` и размеры.
- Цвета: `theme = theme.conf` — текущая тема Omarchy. `config-file = ?style.conf` — стиль Customizer.
- Свои шейдеры и шейдеры курсора (`shaders/`, `cursors/`, `my_shaders*/`), `custom-shader-animation = true`.

### Поведение

- Разрешены чтение и запись буфера обмена, `copy-on-select = true`.
- Состояние окна запоминается (`window-save-state = always`), без подтверждения при закрытии.
- `start-tmux.sh` — открыть терминал сразу в сессии tmux.
