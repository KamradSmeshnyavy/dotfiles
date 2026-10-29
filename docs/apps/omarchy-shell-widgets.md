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

Цвета берутся из темы (`Commons.Color` и `colors.toml`) и меняются вместе с ней.
