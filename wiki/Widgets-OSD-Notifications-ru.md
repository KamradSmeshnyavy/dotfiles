[English](Widgets-OSD-Notifications) · **Русский**

# Виджеты, OSD, уведомления

## Виджеты рабочего стола

[omarchy-desktop-widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets) — один сервисный плагин для слоя рабочего стола и нескольких
оверлеев:

- **Виджеты** под окнами: часы (5 стилей, в том числе точечный), сейчас играет, визуализатор cava, системные шкалы,
  сеть, todo, цитата дня, фоторамка. Customizer → Рабочий стол → Виджеты показывает их на мини-столе и отмечает
  наложения.
- **Дашборд** (`Super+Alt+D`) — вырастает из-под бара: плеер, календарь, погода, графики CPU/RAM; или LED-дашборд
  DOT-MATRIX.
- **Панель настроек** (`Super+M`) — шторка DOT-MATRIX: Wi-Fi, Bluetooth, звук, микрофон, DND, ночной свет, LED-ползунки
  и история уведомлений.
- **Меню выключения** (`Super+Esc`) — у правого края; перезагрузка и выключение — со второго нажатия.
- **Обзор рабочих столов** (`` Super+` ``) — живые превью окон; окно можно перетащить на другой стол.

Необязательно: `cava`, `zenity`. Жесты (4 пальца): вверх — обзор, вниз — дашборд.

## Edge OSD

[omarchy-edge-osd](https://github.com/KamradSmeshnyavy/omarchy-edge-osd) — громкость / яркость / микрофон слайдером, выезжающим из края экрана и
растущим из рамки скина бара `frame`; или LED-шкала DOT-MATRIX на 16 точек. Customizer → Окна → OSD и уведомления.

## Уведомления-шторка

[omarchy-drawer-notifications](https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications) — тосты в одной шторке цвета бара в углу или
«железные» карточки DOT-MATRIX с пробегом Glyph; звук на тост. Демон, DND и история — стоковые.

## Панели DOT-MATRIX

Стоковые панели бара, перерисованные в стиле DOT-MATRIX, — каждая свой плагин, логика и бинды как в стоке:
[Tray](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-tray) · [Wi-Fi](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-network) · [Bluetooth](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-bluetooth) ·
[Sound](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-audio) · [Display](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-monitor) · [Agents](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-agents).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-audio --enable   # спросит секцию бара
```

Всё это следует текущему стилю (`~/.config/omarchy/style.json`) и теме. Справочник:
[виджеты](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-widgets.ru.md), [OSD и уведомления](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-osd.ru.md),
[DOT-MATRIX](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-dotmatrix.ru.md).
