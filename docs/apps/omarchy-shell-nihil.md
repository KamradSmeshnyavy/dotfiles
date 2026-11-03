# Стиль Nihil (dot-matrix)

Вид Nothing OS, портированный из [poligle/Nihil-Shell](https://github.com/poligle/Nihil-Shell) (MIT) в свои плагины
omarchy-shell. Это стиль, а не тема: он работает на любой omarchy-теме.

## Где что

| Часть | Ключ | Файл |
|---|---|---|
| Бар | скин `nihil` (роли `nihil.*`), раскладка `nihil`, `wsLabelStyle: leds` | `~/.config/omarchy/bar-skin.json` |
| Трей, Wi-Fi, BT, звук в баре | клоны `kamradsmeshnyavy.{tray,network,bluetooth,audio}` | `shell.json` `.bar.layout` |
| Виджеты, дашборд | `widgetStyle`, `dashStyle` = `nihil` | `~/.config/omarchy/widgets.json` |
| Панель настроек | Super+M, IPC `widgets toggleSettings` / `widgets openSettingsSection wifi\|bt\|audio` | — |
| OSD | `osdStyle: nihil` | `~/.config/omarchy/osd.json` |
| Уведомления | `notifyCards: nihil` | `~/.config/omarchy/notify-style.json` |
| Экран блокировки | дизайн `nihil` | `~/.config/omarchy/lock-design.json` |
| Лаунчер | скин `nihil` | `~/.config/omarchy/extensions/menu-skin.json` |
| Glyph, Dotify, звуки | `kamradsmeshnyavy.customizer` | `glyph.json`, `dotify.json`, `sounds.json` |

## Палитра

Цвета и шрифты задаёт `nihil/Palette.qml` — синглтон (`qmldir`), одинаковая копия в плагинах widgets, osd,
notifications, bar, menu, lock и customizer. Правка — во все копии (проверка: `md5sum */nihil/Palette.qml`).

- `~/.config/omarchy/nihil.json` `{"palette": "theme"}` (по умолчанию) — роли текущей темы: `bg`/`fg`/`muted` из
  `Commons.Color`, `signal` = `accent`, `danger` = `urgent`; переключение темы применяется сразу.
- `{"palette": "mono"}` — оригинальные `#000000` / `#f2f2f2` / `#d71921` на любой теме.
- Переключатель — Customizer → Рабочий стол → Виджеты → «Палитра Nihil».
- Там же «Цвета Nihil»: каждую роль (`nihilBg`, `nihilFg`, `nihilDim`, `nihilMuted`, `nihilLine`,
  `nihilSurface`, `nihilLit`, `nihilSignal`, `nihilDanger` в `nihil.json`) можно задать ролью шелла, ключом
  `colors.toml` темы (`red`, `blue`, …) или hex. `default` — автоматический цвет. `lit` — горящие LED,
  ползунки, включённые кнопки (по умолчанию = текст).
- В конфигах цвета пишутся ролями `nihil.bg`, `nihil.fg`, `nihil.line`, `nihil.signal`, `nihil.danger` — их
  понимают BarSkin, BarStyle, превью бара и Glyph.
- Шрифты Doto, Space Grotesk, Space Mono (OFL) лежат в `kamradsmeshnyavy.customizer/fonts` и линкуются в
  `~/.local/share/fonts/nihil`; без них Nihil-компоненты берут шрифт Omarchy.

Шторки (дашборд, панель настроек, OSD) берут заливку у BarStyle — цвет бара. Шов с рамкой рисуется только когда
шторка прикреплена к бару (`*Attach`), иначе это отдельная карточка с замкнутым контуром.

## Трей и меню Wi-Fi / Bluetooth / звука

Функции берутся у Omarchy, а не пишутся заново. Стоковые виджеты бара клонированы (`omarchy plugin clone`) в
`apps/omarchy-shell/plugins/kamradsmeshnyavy.{tray,network,bluetooth,audio}`. Правки помечены `// nihil:`:
цвета и шрифты из палитры Nihil-бара (`import "../kamradsmeshnyavy.bar/nihil"`), карточка — `Palette.restyleCard`.
Логика (`Model.js`, скрипты `omarchy-*`) стоковая: при обновлении Omarchy новые версии переносятся diff'ом
против `/usr/share/omarchy/shell/plugins/{bar/widgets,panels/*}`. IPC-цели остались стоковыми
(`omarchy.network`, `omarchy.audio`…), поэтому бинды Omarchy (Super+Alt+A и т.п.) открывают Nihil-панели.

- Трей: ЛКМ — активировать, ПКМ — меню приложения с подменю, СКМ — вторичное действие, колесо — прокрутка.
  Параметры виджета: `collapse` (false — все значки видны, «⋯» открывает менеджер pin/hide; true — стоковый
  выдвижной ящик), `monochrome` (серые значки, цвет при наведении).
- Панель настроек (Super+M): раскрытые Wi-Fi / BT / звук (`widgets/nihil/{Wifi,Bt,Audio}Section.qml`) повторяют
  панели Omarchy: сведения о подключении, скорость (LED-осциллограф), пинг, диапазон, DNS, сети с паролем /
  802.1X / «забыть», QR и тест скорости; сопряжение, подключение, «забыть» и вывод звука на BT-устройство;
  выходы и входы, громкость приложений. Разделы берут `Model.js` клонов; кнопка ⚙ открывает панель у значка в баре.

## Виджеты бара в Customizer

Customizer → Бар → «Виджеты бара»: все виджеты текущей раскладки по секциям, затем «Не на баре» и «Параметры
виджетов». h / l — сдвинуть раньше / позже (на краю — в соседнюю секцию, через `omarchy-shell shell
moveBarWidget`), ⏎ или x — убрать с бара / вернуть. Убранный виджет с настройками и местом хранится в
`~/.config/omarchy/customizer/bar-hidden.json`; стоковые добавляются через `putBarWidget`. Стоковый виджет, у
которого есть клон, в «Не на баре» не показывается: его включение сняло бы клон. Правки идут в живой
`shell.json`; сохранить раскладку как свою — «Раскладка бара» → «Сохранить».

## Шрифты: Nihil Dot, Nihil Mono, Nihil Pixel и профили

Генераторы лежат в `kamradsmeshnyavy.customizer/scripts/` и запускаются через `uv run --with fonttools`. Все три
шрифта — изменённые OFL-шрифты, поэтому у них свои имена (Reserved Font Name исходников).

- **Nihil Dot** — Doto с кириллицей и точечными лигатурами (`fonts/NihilDot.ttf`, `nihil-dot.py`, в git).
  - Буквы собраны из точек Doto вместе с их вариациями, поэтому толщина (`wght` 100–900) и округлость
    (`ROND`) работают и у кириллицы.
  - Лигатуры `== === != !== -> <- => ::` нарисованы точками той же сетки.
  - Палитра: `fontDot` = Nihil Dot → Doto → шрифт Omarchy.
- **Nihil Mono** (`nihil-mono.py`) — официальный Geist Mono, у которого лигатуры (набор `ss11`) подключены
  ещё и к `calt`, поэтому включены везде по умолчанию.
- **Nihil Pixel** (`nihil-pixel.py`) — Terminess Nerd Font (Terminus).
  - Русские строчные: «в д» из официального варианта Terminus `alt/dv1` (у Terminus по умолчанию они
    болгарские: «в» = маленькая «B», «д» = «g»), «и й» построены из «И» с диагональю (было «u ŭ»).
  - Курсив сдвигает строки пикселей и не выходит из ячейки: терминал больше не обрезает буквы.
  - Пиксельные лигатуры: `!= == === -> <- => <= >= -- :: // || ++ >> <<`.
  - Правки сделаны и в контурах, и во встроенных битмапах 12–32 px: на этих размерах FreeType берёт битмап.
    У ghostty 12 pt при масштабе 2 — это 32 px.
  - Исходники Terminus скачиваются с SourceForge (sha256 сверяется) в `~/.cache/nihil-fonts`.
- Nihil Mono и Nihil Pixel собираются в `~/.local/share/fonts/nihil-build` (не в git): `just nihil-fonts`.
  Профиль, которому они нужны, собирает их сам. Значки Nerd Font терминалы берут из Symbols Nerd Font
  (`ttf-nerd-fonts-symbols`).
- **Профили шрифтов системы** — `omarchy-font-profile` (`scripts/bin`), Customizer → Рабочий стол → Виджеты →
  «Шрифты системы». Состояние — `~/.config/omarchy/fonts.json`.

  | Профиль | Текст | Код / терминал | Точками |
  |---|---|---|---|
  | `stock` | Maple Mono NF CN | Maple Mono NF CN | только Nihil-виджеты (часы, цифры) |
  | `nothing` | Geist | Nihil Mono | часы, цифры; в браузере h1–h2 |
  | `dot` | Geist | Nihil Mono | + заголовки уведомлений и панелей, трек, запрос лаунчера; в браузере h1–h3, th |
  | `pixel` | Geist | Nihil Pixel | как `dot`; в браузере `code`/`pre` — Nihil Pixel |

  Что применяет профиль:
  - терминалы (kitty, ghostty, alacritty, foot) и fontconfig `monospace` — как `omarchy font set`, но без
    перезапуска оболочки;
  - лигатуры в ghostty: блок `font-feature` между метками `omarchy-font-profile` — для своих шрифтов `calt`,
    для stock исходные строки Maple;
  - fontconfig `sans-serif` (`conf.d/60-nihil-fonts.conf`), GTK (`gsettings`);
  - VS Code — первая гарнитура в `editor`/`terminal`/`debug`/`markdown` fontFamily;
  - браузеры: шрифты страниц Helium и Firefox, Dark Reader, Stylus (usercss «Nihil fonts»), Surfingkeys, вид
    интерфейса Firefox (`omarchy-firefox-chrome`: stock — прежний, остальные — Nihil);
  - Nihil-палитру (`dotLayer`, `fontSans`, `fontMono`).
- Geist скачивается сам (официальный релиз vercel/geist-font, кэш `~/.cache/nihil-fonts`); Terminess Nerd Font —
  пакет `ttf-terminus-nerd`.

## Пресет NIHIL

Customizer → Пресеты → NIHIL применяет тему `nihil`, обои, геометрию окон, анимации и все части стиля. Что именно
применять — переключатели «Что применять из пресетов» в той же группе (`~/.config/omarchy/customizer/preset-apply.json`).
Например, без темы и обоев получается Nihil-стиль поверх своей темы. «Восстановить прежнюю настройку» —
резервная копия, снятая перед первым пресетом. «Сбросить геометрию окон» убирает отступы/рамки/тень из пресета.

**Углы окон** (Customizer → Пресеты → «Углы окон», `~/.config/omarchy/customizer/windows.json`):
- правило окон Hyprland из `hypr/customizer.lua`, а не `decoration.rounding`. Поэтому скругление действует и
  при переключателе Omarchy «без отступов» (Super+Shift+Backspace);
- `float` (по умолчанию) — плавающие и pop-окна. Тайловые остаются прямыми: внешние углы скругляет рамка экрана,
  стыки остаются сплошными. `all` — все окна; при нулевых отступах на стыках видны щели. `off` — как в конфиге;
- радиус 16 (меньше рамки 20 и карточек Nihil 18). Форма `rounding_power` 2.5 — мягкий скругло-квадрат;
- изменение применяется `hyprctl reload`: правило окон иначе не снять.

## Совместимость с Omarchy

- Блокировка, выход, перезагрузка и выключение — через `omarchy-system-*`, ночной свет — `omarchy-toggle-nightlight`
  (демон hyprsunset не убивается).
- Тема `omarchy-themes/nihil` — только цвета и обои; Plymouth и SDDM лежат отдельно в `omarchy-themes/nihil-boot`
  и ставятся вручную.
