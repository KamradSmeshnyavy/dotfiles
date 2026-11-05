# Стиль DOT-MATRIX (dot-matrix)

[🇬🇧 English](omarchy-shell-dotmatrix.md)

Вид Nothing OS, портированный из [poligle/Nihil-Shell](https://github.com/poligle/Nihil-Shell) (MIT) в свои плагины
omarchy-shell. Это стиль, а не тема: он работает на любой omarchy-теме.

## Где что

| Часть | Ключ | Файл |
|---|---|---|
| Бар | скин `dotmatrix` (роли `dotmatrix.*`), раскладка `dotmatrix`, `wsLabelStyle: leds` | `~/.config/omarchy/bar-skin.json` |
| Трей, Wi-Fi, BT, звук, дисплей, агенты в баре | панели `kamradsmeshnyavy.{tray,network,bluetooth,audio,monitor,agents}` | `shell.json` `.bar.layout` |
| Виджеты, дашборд | `widgetStyle`, `dashStyle` = `dotmatrix` | `~/.config/omarchy/widgets.json` |
| Панель настроек | Super+M, IPC `widgets toggleSettings` / `widgets openSettingsSection wifi\|bt\|audio` | — |
| OSD | `osdStyle: dotmatrix` | `~/.config/omarchy/osd.json` |
| Уведомления | `notifyCards: dotmatrix` | `~/.config/omarchy/notify-style.json` |
| Экран блокировки | дизайн `dotmatrix` | `~/.config/omarchy/lock-design.json` |
| Лаунчер | скин `dotmatrix` | `~/.config/omarchy/extensions/menu-skin.json` |
| Glyph, Dotify, звуки | `kamradsmeshnyavy.customizer` | `glyph.json`, `dotify.json`, `sounds.json` |

## Палитра

Цвета и шрифты задаёт `dotmatrix/Palette.qml` — синглтон (`qmldir`), одинаковая копия в плагинах widgets, osd,
notifications, bar, menu, lock, customizer и шести DOT-MATRIX-панелях. Правка — во все копии (проверка: `md5sum */dotmatrix/Palette.qml`).

- `~/.config/omarchy/dotmatrix.json` `{"palette": "theme"}` (по умолчанию) — роли текущей темы: `bg`/`fg`/`muted` из
  `Commons.Color`, `signal` = `accent`, `danger` = `urgent`; переключение темы применяется сразу.
- `{"palette": "mono"}` — оригинальные `#000000` / `#f2f2f2` / `#d71921` на любой теме.
- Переключатель — Customizer → Рабочий стол → Виджеты → «Палитра DOT-MATRIX».
- Там же «Цвета DOT-MATRIX»: каждую роль (`dotmatrixBg`, `dotmatrixFg`, `dotmatrixDim`, `dotmatrixMuted`, `dotmatrixLine`,
  `dotmatrixSurface`, `dotmatrixLit`, `dotmatrixSignal`, `dotmatrixDanger` в `dotmatrix.json`) можно задать ролью шелла, ключом
  `colors.toml` темы (`red`, `blue`, …) или hex. `default` — автоматический цвет. `lit` — горящие LED,
  ползунки, включённые кнопки (по умолчанию = текст).
- В конфигах цвета пишутся ролями `dotmatrix.bg`, `dotmatrix.fg`, `dotmatrix.line`, `dotmatrix.signal`, `dotmatrix.danger` — их
  понимают BarSkin, BarStyle, превью бара и Glyph.
- Шрифты Doto, Space Grotesk, Space Mono (OFL) лежат в `kamradsmeshnyavy.customizer/fonts` и линкуются в
  `~/.local/share/fonts/dotmatrix`; без них DOT-MATRIX-компоненты берут шрифт Omarchy.

Шторки (дашборд, панель настроек, OSD) берут заливку у BarStyle — цвет бара. Шов с рамкой рисуется только когда
шторка прикреплена к бару (`*Attach`), иначе это отдельная карточка с замкнутым контуром.

## Трей и меню Wi-Fi / Bluetooth / звука

Функции берутся у Omarchy, а не пишутся заново. Стоковые виджеты бара клонированы (`omarchy plugin clone`) в
`apps/omarchy-shell/plugins/kamradsmeshnyavy.{tray,network,bluetooth,audio,monitor,agents}`. Правки помечены `// dotmatrix:`:
цвета и шрифты из своей копии палитры (`import "dotmatrix"`), карточка — `Palette.restyleCard`. Каждая панель — отдельное репо `omarchy-dotmatrix-<имя>` (сабмодуль).
Логика (`Model.js`, скрипты `omarchy-*`) стоковая: при обновлении Omarchy новые версии переносятся diff'ом
против `/usr/share/omarchy/shell/plugins/{bar/widgets,panels/*}`. IPC-цели остались стоковыми
(`omarchy.network`, `omarchy.audio`…), поэтому бинды Omarchy (Super+Alt+A и т.п.) открывают DOT-MATRIX-панели.

- Трей: ЛКМ — активировать, ПКМ — меню приложения с подменю, СКМ — вторичное действие, колесо — прокрутка.
  Параметры виджета: `collapse` (false — все значки видны, «⋯» открывает менеджер pin/hide; true — стоковый
  выдвижной ящик), `monochrome` (серые значки, цвет при наведении).
- Панель настроек (Super+M): раскрытые Wi-Fi / BT / звук (`widgets/dotmatrix/{Wifi,Bt,Audio}Section.qml`) повторяют
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

## Шрифты: DotMatrix Dot, DotMatrix Mono, DotMatrix Pixel и профили

Генераторы лежат в `kamradsmeshnyavy.customizer/scripts/` и запускаются через `uv run --with fonttools`. Все три
шрифта — изменённые OFL-шрифты, поэтому у них свои имена (Reserved Font Name исходников).

- **DotMatrix Dot** — Doto с кириллицей и точечными лигатурами (`fonts/DotMatrixDot.ttf`, `dotmatrix-dot.py`, в git).
  - Буквы собраны из точек Doto вместе с их вариациями, поэтому толщина (`wght` 100–900) и округлость
    (`ROND`) работают и у кириллицы.
  - Лигатуры `== === != !== -> <- => ::` нарисованы точками той же сетки.
  - Палитра: `fontDot` = DotMatrix Dot → Doto → шрифт Omarchy.
- **DotMatrix Mono** (`dotmatrix-mono.py`) — официальный Geist Mono, у которого лигатуры (набор `ss11`) подключены
  ещё и к `calt`, поэтому включены везде по умолчанию.
- **DotMatrix Pixel** (`dotmatrix-pixel.py`) — Terminess Nerd Font (Terminus).
  - Русские строчные: «в д» из официального варианта Terminus `alt/dv1` (у Terminus по умолчанию они
    болгарские: «в» = маленькая «B», «д» = «g»), «и й» построены из «И» с диагональю (было «u ŭ»).
  - Курсив сдвигает строки пикселей и не выходит из ячейки: терминал больше не обрезает буквы.
  - Пиксельные лигатуры: `!= == === -> <- => <= >= -- :: // || ++ >> <<`.
  - Правки сделаны и в контурах, и во встроенных битмапах 12–32 px: на этих размерах FreeType берёт битмап.
    У ghostty 12 pt при масштабе 2 — это 32 px.
  - Исходники Terminus скачиваются с SourceForge (sha256 сверяется) в `~/.cache/dotmatrix-fonts`.
- **DotMatrix Board** (Mono и Sans, `dotmatrix-board.py`) — «точки везде» профилей `dots-all-test-a…f`. Пока идёт
  выбор, собираются шесть вариантов точки (`BOARD_VARIANTS` в `omarchy-font-profile`): семейства «DotMatrix Board A…F»,
  A/B/C — круглая 65/72/80 % шага, D/E/F — квадратная (LCD) с теми же размерами.
  - Источник — [Matrix Sans / Matrix Mono](https://github.com/FriedOrange/MatrixSans) (FriedOrange, OFL 1.1, без
    Reserved Font Name): сетка 5×7 со строчными, полная кириллица. Релиз скачивается в `~/.cache/dotmatrix-fonts`.
  - Берётся вариант Screen: в нём каждая точка — отдельный квадрат на сетке 100 единиц. Генератор снимает центры
    точек и ставит на их место свою точку `.dot`: `--dot` — диаметр в долях шага (0.72), `--shape round|square`.
    Жирное — точка крупнее, курсив — сдвиг рядов.
  - Своё: псевдографика, блоки и Брайль (графики btop) на той же сетке, линии соседних ячеек стыкуются. Остальное,
    чего нет в Matrix (₽, ≠, стрелки), — из DejaVu Sans Mono на 8 ppem. Значки Nerd Font — сплошные из Symbols Nerd Font.
  - Почему не DotMatrix LED: у того сетка Terminus 8×16 — 16 точек на em и точка 96 % шага. На 14 pt при масштабе 2
    шаг 2.3 px, зазор 0.1 px, и глаз видит обычный Terminus. У 5×7 точка — 10 % кегля: на тех же 37 px шаг 3.7 px.
  - Ровнее всего, когда шаг — целое число физических пикселей: 15 pt (40 px, шаг 4) в терминалах, 20 px в VS Code,
    11.25 pt (30 px, шаг 3) в GTK. Эти размеры ставят `dots-all-test-*`; прежние возвращаются при смене профиля.
- **DotMatrix Lumen** — «идеальный» вариант для профиля `dots-all-lumen`, тот же генератор: круглая точка 74 %,
  Sans с разрядкой в полточки (`--track 50`), Mono с лигатурами `-> <- => == !=` точками (`--ligatures`; `--> === <=>`
  намеренно без лигатур). Заголовки — DotMatrix Dot: мелкая сетка Doto красива только на крупном кегле.
- **Семейство Lumen** — профиль `lumen` на тех же файлах: сетка зависит от размера текста. Всё мелкое — 5×7 (интерфейс
  и заголовки панелей Lumen Sans, код и метки Lumen Mono), DotMatrix Dot — только крупное (часы, OSD, lock, h1–h2 на
  сайтах). Палитра не включает `dotLayer` (имя не `dots-all*`): заголовки панелей Omarchy — 14 px, Doto там сливается.
- Ловушка fontconfig: `fonts.conf` профиля (как и у `omarchy font set`) ставит моно-шрифт профиля впереди любого
  запроса, к которому fontconfig приписал `monospace`, — `fc-match "JetBrains Mono"` отдаёт шрифт профиля. Для «точек
  везде» это даже удобно, но образцы чужих моно-шрифтов рендерить с отдельным `FONTCONFIG_FILE` без правил пользователя.
- DotMatrix Mono и DotMatrix Pixel собираются в `~/.local/share/fonts/dotmatrix-build` (не в git): `just dotmatrix-fonts`.
  Профиль, которому они нужны, собирает их сам. Значки Nerd Font терминалы берут из Symbols Nerd Font
  (`ttf-nerd-fonts-symbols`).
- **Профили шрифтов системы** — `omarchy-font-profile` (`scripts/bin`), Customizer → Рабочий стол → Виджеты →
  «Шрифты системы». Состояние — `~/.config/omarchy/fonts.json`. Все 21 профиль — `omarchy-font-profile list`.

  | Профиль | Текст | Код / терминал | Точками |
  |---|---|---|---|
  | `stock` | Maple Mono NF CN | Maple Mono NF CN | только DOT-MATRIX-виджеты (часы, цифры) |
  | `nothing` | Geist | DotMatrix Mono | часы, цифры; в браузере h1–h2 |
  | `dot` | Geist | DotMatrix Mono | + заголовки уведомлений и панелей, трек, запрос лаунчера; в браузере h1–h3, th |
  | `pixel` | Geist | DotMatrix Pixel | как `dot`; в браузере `code`/`pre` — DotMatrix Pixel |

  Что применяет профиль:
  - kitty и ghostty — **не** в `kitty.conf` / `config` из репозитория: они держат шрифт stock (Maple, её ss01–ss04)
    и последним подключают сгенерированный `fonts.conf` (`globinclude fonts.conf` / `config-file = ?fonts.conf`,
    в `.gitignore`). Скрипт пишет его целиком: семейство, варианты (`auto`, у `dot-accents` жирное DotMatrix Dot
    Black), в ghostty сброс `font-family = ""` / `font-feature = ""` и `calt`, размеры по сетке. Смена профиля
    не оставляет диффов в git;
  - alacritty, foot и fontconfig `monospace` — как `omarchy font set`, но без перезапуска оболочки;
  - `omarchy font set` (меню Omarchy) правит `font_family` прямо в `kitty.conf` — хук `hooks/font-set` вызывает
    `omarchy-font-profile mono <шрифт>`: строка возвращается к stock, шрифт уходит в `fonts.conf`;
  - fontconfig `sans-serif` (`conf.d/60-dotmatrix-fonts.conf`), GTK (`gsettings`);
  - VS Code — первая гарнитура в `editor`/`terminal`/`debug`/`markdown` fontFamily и размеры. `settings.json`
    отслеживается git, поэтому эти ключи и `workbench.colorTheme` (его пишет Omarchy при смене темы) прячет
    clean-фильтр `scripts/git-filters/vscode-local` (`.gitattributes`, настраивает `just link`): в индекс идут
    канонические значения из `CANON` в фильтре. `vscode-local-refresh` (после профиля и в хуке `theme-set`)
    обновляет stat-кэш индекса, иначе `git status` показывал бы файл из-за другого размера;
  - браузеры: шрифты страниц Helium и Firefox, Dark Reader, Stylus (usercss «DOT-MATRIX fonts»), Surfingkeys, вид
    интерфейса Firefox (`omarchy-firefox-chrome`: stock — прежний, остальные — DOT-MATRIX);
  - DOT-MATRIX-палитру (`dotLayer`, `fontSans`, `fontMono`).
- Geist скачивается сам (официальный релиз vercel/geist-font, кэш `~/.cache/dotmatrix-fonts`); Terminess Nerd Font —
  пакет `ttf-terminus-nerd`.

## Стиль и пресет DOT-MATRIX

Три оси: тема — цвета и обои, **стиль** — форма, пресет — тема + стиль + обои.

Customizer → Пресеты → **Стиль** → DOT-MATRIX (`styles/dotmatrix.json` в customizer) — DOT-MATRIX поверх текущей темы: геометрия
окон, бар, локскрин, лаунчер, виджеты, OSD, уведомления, анимации, прозрачность, блюр, звуки, Glyph и профиль
шрифтов `pixel`, тоггл «без отступов» (окна вплотную к рамке-бортику, без рамок окон; другие стили его выключают). Собран из пресета
`nothing-hacking`. Разделы вливаются в текущие настройки (какие виджеты видны — не трогается). Там же Flat, Стекло,
Fluent, Paper, Neon, Neumorph, Brutal, Retro и свои стили; что применять — переключатели под списком (`~/.config/omarchy/customizer/style-apply.json`).

Customizer → Пресеты → DOT-MATRIX ссылается на стиль (`"style": "dotmatrix"`) и дополнительно ставит тему `dotmatrix` и обои.
Переключатели пресета — `~/.config/omarchy/customizer/preset-apply.json`. «Восстановить прежнюю настройку» —
резервная копия, снятая перед первым пресетом или стилем. «Сбросить геометрию окон» убирает отступы/рамки/тень.

**Углы окон** (Customizer → Пресеты → «Углы окон», `~/.config/omarchy/customizer/windows.json`):
- правило окон Hyprland из `hypr/customizer.lua`, а не `decoration.rounding`. Поэтому скругление действует и
  при переключателе Omarchy «без отступов» (Super+Shift+Backspace);
- `float` (по умолчанию) — плавающие и pop-окна. Тайловые остаются прямыми: внешние углы скругляет рамка экрана,
  стыки остаются сплошными. `all` — все окна; при нулевых отступах на стыках видны щели. `off` — как в конфиге;
- радиус 16 (меньше рамки 20 и карточек DOT-MATRIX 18). Форма `rounding_power` 2.5 — мягкий скругло-квадрат;
- изменение применяется `hyprctl reload`: правило окон иначе не снять.

## Совместимость с Omarchy

- Блокировка, выход, перезагрузка и выключение — через `omarchy-system-*`, ночной свет — `omarchy-toggle-nightlight`
  (демон hyprsunset не убивается).
- Тема `omarchy-themes/dot-matrix` — только цвета и обои; Plymouth и SDDM лежат отдельно в `omarchy-themes/dot-matrix-boot`
  и ставятся вручную.
