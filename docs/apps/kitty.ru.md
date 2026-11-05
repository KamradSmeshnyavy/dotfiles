# Kitty

[🇬🇧 English](kitty.md)

Быстрый эмулятор терминала с GPU-ускорением — здесь основной терминал.

## Пути

- **В репозитории:** `apps/kitty`
- **Линкуется в:** `~/.config/kitty`

## Отличия от настроек по умолчанию

### Шрифты

- `kitty.conf` держит шрифт stock: **Maple Mono NF CN** (варианты bold/italic, `font_features +cv01 +ss02 +ss04
  +ss05 +zero` — например, перечёркнутый ноль), размер 14.
- Профиль шрифтов системы (`omarchy-font-profile`) переопределяет семейство, варианты и размер в сгенерированном
  `fonts.conf`, который подключается последним (`globinclude fonts.conf`) и не отслеживается git — смена шрифтов не
  оставляет диффов.

### Интеграция с Neovim (kitty-scrollback.nvim)

- `Alt + P` — открыть весь буфер прокрутки в Neovim.
- `Super + Shift + P` — только вывод последней команды.
- `Ctrl + Shift + правый клик` — открыть кликнутый вывод команды в Neovim.

### Внешний вид и окна

- Размытие фона `background_blur 64`; прозрачность — из темы и пресетов прозрачности Customizer.
- Декорации окна скрыты (`hide_window_decorations titlebar-only`).
- Цвета следуют теме Omarchy: `include ./themes/theme.conf` указывает на текущую тему.
- `globinclude style.conf` — стиль Customizer (отступы окна, форма курсора), пишет `omarchy-app-themes`.

### Системное

- Remote control по сокету (`allow_remote_control socket-only`) — для скриптов и kitty-scrollback.
- macOS: Option работает как Alt (`macos_option_as_alt`), заголовок в цвет фона.
