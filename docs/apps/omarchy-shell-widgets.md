# Виджеты рабочего стола omarchy-shell

Свой плагин `kamradsmeshnyavy.widgets` (`kind: service`): `apps/omarchy-shell/plugins/kamradsmeshnyavy.widgets/` →
`~/.config/omarchy/plugins/kamradsmeshnyavy.widgets`. Включение: `omarchy plugin enable kamradsmeshnyavy.widgets`
(после `omarchy-shell shell rescanPlugins`), правки QML — только после `omarchy restart shell`.

Окна на слое Bottom: над обоями и под окнами, видны на пустом рабочем столе. Клики проходят насквозь,
кроме кнопок плеера.

| Виджет | Что показывает | Откуда данные |
|---|---|---|
| Часы | стили `big`, `stacked`, `terminal`, `minimal`; дата на языке Customizer | `Timer` раз в секунду |
| Сейчас играет | обложка, название, исполнитель, прогресс, ⏮ ⏯ ⏭ | MPRIS (`Quickshell.Services.Mpris`), играющий плеер или первый |
| Визуализатор | `bars`, `mirror`, `wave` во всю ширину у нижнего края | cava в raw-режиме (pipewire), запускается только пока играет музыка |
| Кольца системы | CPU, RAM, температура, батарея; красные при перегреве и ≤15 % | `/proc/stat`, `/proc/meminfo`, `/sys/class/thermal`, `/sys/class/power_supply` раз в 2 с |

cava и опрос `/proc` запускаются один раз на все мониторы; выключенный виджет не тратит ничего.

## Дашборд

`Super+Alt+D` (`omarchy-shell widgets toggleDashboard`, есть `openDashboard` / `closeDashboard`) —
панель «вырастает» из-под бара у верхнего края экрана с фокусом (идея caelestia, написано с нуля):
вогнутые углы сверху переходят в полосу бара, высота растёт от нуля. С формой бара `frame` или `hug`
и непрозрачным фоном — цвет и радиус углов бара; у прозрачных скинов — цвет попапов темы.
Закрывается Esc или кликом мимо (`HyprlandFocusGrab`).

Внутри: плеер (обложка, время, кнопки, визуализатор cava), календарь месяца (‹ › листают), погода
(open-meteo без ключа: город — `weatherCity`, обновление раз в 20 минут и только при открытии), графики
CPU/RAM за 2 минуты, температура и батарея. Пока дашборд открыт, данные собираются, даже если
виджеты на рабочем столе выключены.

## Меню выключения

`Super+Esc` (`omarchy-shell widgets togglePower`; было стоковое System-меню — оно осталось в лаунчере) —
столбец кнопок, выезжающий из правого края / рамки, того же цвета, что дашборд. Пункты и команды — как в
стоковом System-меню: блокировка, сон (если не отключён `suspend-off`), гибернация (если
`omarchy-hibernation-available`), выход, перезагрузка, выключение. Последние три срабатывают со второго
нажатия в течение 3 секунд (первое красит кнопку: «ещё раз»). Клавиши: `j`/`k` или ↑↓, Enter, `1`–`6`, Esc;
клик мимо закрывает. Открытие меню закрывает дашборд и наоборот.

## Обзор рабочих столов и жесты

`Super+`` ` (`omarchy-shell widgets toggleOverview`) — сетка рабочих столов (1…5, больше — если заняты)
с обоями и живыми превью окон (`ScreencopyView`). Клик по столу — перейти, по окну — фокус на нём;
перетащить окно на другой стол — перенести его туда, не уходя с текущего. Клавиши: ←→↑↓ / `hjkl`,
Enter, `1`–`9`, Esc; клик по пустому месту закрывает. Диспетчеры идут через `hyprctl eval`
(`hl.dsp.window.move({ workspace, follow = false, window = "address:0x…" })`) — под Lua-конфигом
обычный `hyprctl dispatch` ничего не делает.

Жесты тачпада (`apps/hyprland/input.lua`) — на четыре пальца, потому что три заняты `drag_3fg`:
в стороны — рабочие столы, вверх — обзор, вниз — дашборд.

## Настройки

Customizer (Super+Shift+T) → Рабочий стол → **Виджеты**: `h`/`l` меняют значение, `x` сбрасывает.
Пишется в `~/.config/omarchy/widgets.json` (нет файла — значения по умолчанию), плагин подхватывает сразу.

| Ключ | По умолчанию | |
|---|---|---|
| `clock`, `media`, `visualizer`, `sysinfo` | `true` | включить виджет |
| `clockStyle` | `big` | `big` `stacked` `terminal` `minimal` |
| `clockAnchor`, `mediaAnchor`, `sysinfoAnchor` | `top-left`, `bottom-left`, `top-right` | `top-left` … `bottom-right`, `center` |
| `clock24`, `clockSeconds` | `true`, `false` | |
| `visualizerStyle` | `bars` | `bars` `mirror` `wave` |
| `visualizerBars`, `visualizerHeight`, `visualizerAlpha` | `48`, `140`, `0.45` | |
| `visualizerIdle` | `false` | рисовать и без музыки (cava тогда работает всегда) |
| `edgeMargin` | `56` | отступ от краёв экрана |
| `tint` | `accent` | роль (`accent` `foreground` `muted`), ключ `colors.toml` или `#hex` |
| `locale` | `""` | язык даты; пусто — `lang` из `customizer.json`, иначе системный |
| `screens` | `all` | `all` или `primary` |
| `weatherCity` | `""` | город для погоды в дашборде |
| `weatherUnits` | `celsius` | `celsius` или `fahrenheit` |

Цвета берутся из темы (`Commons.Color` и `colors.toml`) и меняются вместе с ней.
