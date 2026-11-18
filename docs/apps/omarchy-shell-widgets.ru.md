# Виджеты рабочего стола omarchy-shell

[🇬🇧 English](omarchy-shell-widgets.md)

> Плагин — отдельный репо и сабмодуль: [omarchy-desktop-widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets).

Свой плагин `kamradsmeshnyavy.widgets` (`kind: service`): `apps/omarchy-shell/plugins/kamradsmeshnyavy.widgets/` →
`~/.config/omarchy/plugins/kamradsmeshnyavy.widgets`. Включение: `omarchy plugin enable kamradsmeshnyavy.widgets`
(после `omarchy-shell shell rescanPlugins`), правки QML — только после `omarchy restart shell`.

Окна на слое Bottom: над обоями и под окнами, видны на пустом рабочем столе. Клики проходят насквозь,
кроме кнопок плеера и интерактивных карточек (todo, цитата, фото).

| Виджет | Что показывает | Откуда данные |
|---|---|---|
| Часы | стили `big`, `stacked`, `terminal`, `minimal`, `dotmatrix`; дата на языке Customizer | `Timer` раз в секунду |
| Сейчас играет | обложка, название, исполнитель, прогресс, ⏮ ⏯ ⏭ | MPRIS (`Quickshell.Services.Mpris`), играющий плеер или первый |
| Визуализатор | `bars`, `mirror`, `wave` во всю ширину у нижнего края | cava в raw-режиме (pipewire), запускается только пока играет музыка |
| Кольца системы | CPU, RAM, температура, батарея; красные при перегреве и ≤15 % | `/proc/stat`, `/proc/meminfo`, `/sys/class/thermal`, `/sys/class/power_supply` раз в 2 с |
| Сеть | интерфейс по умолчанию, скорость ↓ / ↑ и точечный осциллограф | опрос раз в 2 с |
| Todo | список из `~/.config/omarchy/widgets-todo.json`; клик по квадратику — сделано, правый клик — удалить, «+» — добавить (окно zenity: слой рабочего стола не берёт клавиатуру) | файл |
| Цитата | цитата дня: встроенные пословицы и изречения + свои строки из `~/.config/omarchy/widgets-quotes.txt` («текст — Автор», по одной на строку); клик — следующая | раз в сутки |
| Фоторамка | картинка из `photoDir`, смена раз в `photoInterval` минут и по клику; без папки — текущие обои. Рамка по стилю (Бумага — полароид со скотчем, Ретро — кант, Неон — свечение) | папка |

cava и опрос `/proc` запускаются один раз на все мониторы; выключенный виджет не тратит ничего. `desktopWidgets: false` выключает все виджеты рабочего стола (слой не создаётся).

Виджеты стола тоже следуют райсу (`widgetStyle: style`): на Unit-3 карточка — лист NieR (фон 92 %, черта 1 px, сетка
и уголки-скобки), на Cozytile, Rumda, surface и Glyph — карточка дашборда этого райса. У Bruteon, yami, Vitreus и
DOT-MATRIX её даёт материал (brutal, pixel, стекло, своя карточка). Карточка, слитая с баром или рамкой, остаётся
карточкой стиля — она умеет рисовать стык.

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

### Вид дашборда и меню выключения

Customizer → Рабочий стол → **Дашборд** (ключи в `widgets.json`). Стиль считает `BarStyle.qml`:

| Ключ | По умолчанию | |
|---|---|---|
| `dashStyle` | `default` | `default` или `dotmatrix` (часы Doto, точечная обложка, LED-спектр 24×6, LED-шкалы CPU/RAM/°C, LED-осциллограф сети) |
| `dashFollowBar` | `true` | цвет, прозрачность, рамка и скругление как у бара; у прозрачного бара — стекло (0.72 под размытием Hyprland, 0.92 без него) |
| `dashAttach` | `auto` | `auto` — прилипать вогнутыми углами только к сплошному бару у края (`frame`, `hug`, `full`), иначе плавающая карточка с отступом и тенью; `attached` / `floating` — принудительно |
| `dashBackground`, `dashAlpha`, `dashRadius`, `dashBorder` | `background`, `0.94`, `22`, `false` | свой вид, когда `dashFollowBar: false` |
| `dashMedia`, `dashCalendar`, `dashWeather`, `dashStats` | `true` | блоки; ширина подстраивается |
| `dashAnimation`, `dashDuration` | `grow`, `340` | `grow` / `slide` / `fade`, мс |

## Панель настроек

`Super+M` (`omarchy-shell widgets toggleSettings`, `widgets openSettingsSection wifi|bt|audio`) — «железная» шторка
DOT-MATRIX у правого края, вырастает из угла рамки: круглые плитки 3×2 (Wi-Fi, Bluetooth, звук, микрофон, DND, ночной
свет), LED-ползунки на 24 сегмента, раскрывающиеся списки Wi-Fi/Bluetooth/звука (подробно —
[omarchy-shell-dotmatrix.ru.md](omarchy-shell-dotmatrix.ru.md)), история уведомлений, действия сессии с красным
подтверждением вторым кликом.

**Space** (по мотивам стиля Space из [elifouts/Dotfiles](https://github.com/elifouts/Dotfiles), GPL-3.0): дашборд — визор (`DashSpace.qml` — уголки, часы, плашки со срезанным углом: система, процессор, память, видеокарта, связь, музыка, шкалы из клеток), Super+M — бортовой компьютер (`menus/MenuSpace.qml` — корабль в центре, разделы — планеты на наклонной орбите; колесо или `[` `]` крутят её, выбранная планета подлетает и разворачивается в плашку HUD), плеер — плашка NOW PLAYING (`players/PlayerSpace.qml`), обзор столов — звёздная карта (`OverviewStarmap.qml`, `overviewStyle: starmap` — столы — звёзды, окна — планеты со снимком окна; hjkl / Tab — полёт, Enter — посадка; посадка на неизведанную систему перекрашивает рабочий стол в её мир). Подписи проступают через шум (`SpaceDecode.qml`, копия барной).

Меню райсов (`settingsPanel` bruteon / yami / cozytile / rumda / glassring / instrument / space, `menus/` на общих
`menus/SectionBody.qml` и `MenuData.qml`) показывают одно и то же содержимое разделов. **Wi-Fi**: сохранённая сеть
подключается своим профилем NetworkManager, без пароля; новая просит пароль в поле прямо под строкой, а неудачная
попытка удаляет профиль, который создал nmcli, — неверный пароль не запоминается. Строка состояния показывает
«connecting…» или ошибку nmcli. `›` у сохранённой сети (или клик по подключённой) открывает её карточку: адрес, шлюз,
действующий DNS, подключить / отключить, автоподключение, **DNS** — пресеты (роутер, Cloudflare, Google, Quad9, AdGuard,
Яндекс) или свои адреса (IPv4 и IPv6 вперемешку), применяются сразу через `nmcli dev reapply` без переподключения, —
показать пароль, новый пароль, забыть сеть (второе нажатие подтверждает). Под списком — сохранённые сети вне зоны,
скрытая сеть (имя, потом пароль) и пересканировать. **Bluetooth**: новое устройство одним нажатием сопрягается,
становится доверенным и подключается, заряд — в строке; `›` — подключить, доверять (автоподключение), забыть.
**Звук**: громкость, микрофон и его уровень, выходы и входы. Esc — шаг назад (поле → карточка → раздел → меню).
Unit-3 (NieR) и surface Hub оставили свои списки, но сохранённые сети тоже подключают без пароля.

Клавиатура (`KeyNav.qml`, все меню и дашборды): цель в прокручиваемом списке докручивается в видимую часть, рамка
выбора прячется, а не рисуется поверх панели, если колесо увело цель за край, а после пересборки списка выбор остаётся
на строке на том же месте.

`edgeHover: true` — горячие зоны у краёв экрана: задержка курсора открывает дашборд, панель настроек и лаунчер.

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
| `desktopWidgets` | `true` | `false` — никаких виджетов на рабочем столе |
| `clock`, `media`, `visualizer`, `sysinfo`, `network`, `todo`, `quote`, `photo` | по виджету | включить виджет |
| `widgetStyle` | `default` | `default` или `dotmatrix` |
| `clockStyle` | `big` | `big` `stacked` `terminal` `minimal` |
| `clockAnchor`, `mediaAnchor`, `sysinfoAnchor`, `networkAnchor`, `todoAnchor`, `quoteAnchor`, `photoAnchor` | по виджету | `top-left` `top` `top-right` `left` `center` `right` `bottom-left` `bottom` `bottom-right` |
| `clock24`, `clockSeconds` | `true`, `false` | |
| `visualizerStyle` | `bars` | `bars` `mirror` `wave` |
| `visualizerBars`, `visualizerHeight`, `visualizerAlpha` | `48`, `140`, `0.45` | |
| `visualizerIdle` | `false` | рисовать и без музыки (cava тогда работает всегда) |
| `todoMax` | | сколько строк todo показывать |
| `photoDir`, `photoInterval` | `""`, минуты | папка с фото (`~` раскрывается) и интервал смены |
| `edgeMargin` | `56` | отступ от краёв экрана |
| `edgeHover` | `false` | горячие зоны у краёв |
| `tint` | `accent` | роль (`accent` `foreground` `muted`), ключ `colors.toml` или `#hex` |
| `locale` | `""` | язык даты; пусто — `lang` из `customizer.json`, иначе системный |
| `screens` | `all` | `all` или `primary` |
| `weatherCity` | `""` | город для погоды в дашборде |
| `weatherUnits` | `celsius` | `celsius` или `fahrenheit` |

Цвета берутся из темы (`Commons.Color` и `colors.toml`) и меняются вместе с ней.
