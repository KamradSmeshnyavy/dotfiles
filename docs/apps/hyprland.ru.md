# Hyprland

[🇬🇧 English](hyprland.md)

Динамический тайлинговый композитор Wayland, конфиг на **Lua** поверх настроек Omarchy 4 (Quattro).

## Пути

- **В репозитории:** `apps/hyprland`
- **Линкуется в:** `~/.config/hypr` (Dotbot, `install/install.conf.yaml`)

## Как собран конфиг

`hyprland.lua` грузит bootstrap и настройки Omarchy (`default.hypr.omarchy`), затем мои переопределения, затем
переключатели Omarchy. Обновления пакета улучшают настройки по умолчанию, не переписывая эти файлы.

| Файл | Что в нём |
|---|---|
| `hyprland.lua` | порядок загрузки: Omarchy → `hypr.monitors`, `input`, `bindings`, `windows`, `looknfeel`, `autostart`, `env` → toggles |
| `bindings.lua` | мои бинды (`o.bind`) и перебинды клавиш, занятых Omarchy 4.5 (`o.rebind`, иначе срабатывают оба действия) |
| `input.lua` | клавиатура, тачпад, жесты на 4 пальца (3 пальца — `drag_3fg`) |
| `looknfeel.lua` | отступы 2/4, рамка 2, `dwindle`, скругление 10, прозрачность неактивных 0.9 + затемнение, блюр (xray, попапы, special), тень |
| `windows.lua` | правила окон и слоёв (блюр под баром, дашбордом, OSD, уведомлениями) |
| `autostart.lua` | KDE Connect, cliphist для текста и картинок, курсор |
| `env.lua` | окружение Wayland (Firefox, GTK portal) |
| `monitors.lua` | мониторы |
| `animations/` | пресеты анимаций (HyDE, ML4W, end-4, …) — их применяет Customizer |
| `scripts/` | `smart_focus.sh`, `focus_float_toggle.sh`, `kbptr-wrapper.sh` |

**Применять через `hyprctl eval`** (или `hyprctl reload`). С Lua-конфигом `hyprctl keyword` и обычный
`hyprctl dispatch` ничего не делают — диспетчеры идут через `hyprctl eval 'hl.dsp…'`.

## Бинды (свои)

| Клавиши | Действие |
|---|---|
| `Super + Return` | терминал в текущей папке |
| `Super + Shift + F` / `Shift + B` | Nautilus / браузер |
| `Super + Shift + T` | **Customizer** (`omarchy-shell shell toggle kamradsmeshnyavy.customizer`) |
| `Super + M` | панель настроек DOT-MATRIX (Wi-Fi, BT, звук, DND, ночной свет) |
| `` Super + ` `` | обзор рабочих столов |
| `Super + Alt + D` | дашборд |
| `Super + Esc` | меню выключения у правого края |
| `Super + Alt + C` / `+ Shift` | шейдер экрана вкл/выкл / следующий (CRT, TFT) |
| `Super + Alt + O` / `+ Shift` | следующий / предыдущий пресет прозрачности |
| `Super + Alt + U` / `+ Shift` | следующий / предыдущий пресет блюра |
| `Super + Alt + W` | переключить раскладку оболочки |
| `Super + Alt + E` / `Super + Shift + V` | эмодзи / буфер обмена |
| `Super + H/J/K/L` | умный фокус (разумно ходит между плавающими и тайловыми) |
| `Super + Shift + H/J/K/L` | поменять окна местами |
| `Super + Ctrl + H/J/K/L` | размер; `Super + R` — режим изменения размера |
| `Super + S` / `Super + .` / `Super + Shift + .` | направление сплита / consume / expel |
| `Super + D` | scratchpad |
| `Super + Tab` | умное переключение float |
| `Super + ;` / `Super + Ctrl + ;` | раскладка рабочего стола / шпаргалка биндов |
| `Pause`, `Scroll_Lock`, `Break` | пауза, следующий, предыдущий трек (и на экране блокировки) |
| `F19` | сменить раскладку клавиатуры (шлёт kanata; `all`, потому что между ними mouseless) |
| 4 пальца ← → / ↑ / ↓ | рабочие столы / обзор / дашборд |

Остальное — стоковые бинды Omarchy (`Super + Ctrl + ;` показывает все).

## Внешний вид

Анимации, прозрачность, блюр и правило углов окон задаются из Customizer и переживают перезагрузку: он пишет
`~/.local/state/omarchy-customizer/animations.lua` и `~/.local/state/hypr/{opacity,blur,screen-shader}` и применяет их
заново после каждого `hyprctl reload`. Чтобы при перезагрузке не мелькали значения по умолчанию, `looknfeel.lua`
подключает хук Customizer `hypr/customizer.lua`.
