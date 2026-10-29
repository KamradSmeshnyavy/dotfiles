# Бар omarchy-shell: скины и раскладки

> Плагин — отдельный репо и сабмодуль: [omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) (там README на английском).

Верхний бар — клон стокового `omarchy.bar` (`omarchy plugin clone omarchy.bar`) с прослойкой скинов:
`apps/omarchy-shell/plugins/kamradsmeshnyavy.bar/` → `~/.config/omarchy/plugins/kamradsmeshnyavy.bar`.
Шелл выбирает его через `bar.id` в `~/.config/omarchy/shell.json`; если клон не загрузится, шелл сам
откатится на стоковый бар.

Всё настраивается в Customizer (Super+Shift+T), категории **Bar Skin** (8), **Bar Layout** (9),
**Bar Tweaks** (0).

## Что где лежит

| Файл | Что это |
|---|---|
| `~/.config/omarchy/bar-skin.json` | активный скин; бар следит за файлом и меняется на лету |
| `~/.config/omarchy/shell.json` `.bar` | позиция, секции виджетов, `transparent` (тоже на лету) |
| `kamradsmeshnyavy.bar/skins/*.json` | пресеты скинов |
| `~/.config/omarchy/bar-skins/*.json` → `apps/omarchy-shell/bar-skins/` | свои скины (★ в Bar Skin) |
| `kamradsmeshnyavy.bar/layouts/*.json` | пресеты раскладок (`position`, `centerAnchor`, `layout`) |
| `kamradsmeshnyavy.bar/BarSkin.qml` | чтение скина, дефолты, цвета-роли |
| `kamradsmeshnyavy.bar/SkinFrame.qml` | подложка по форме, маска ввода, exclusive zone |
| `kamradsmeshnyavy.bar/SkinIsland.qml` | острова под секциями |
| `kamradsmeshnyavy.customizer/BarMock.qml` | макет бара в превью Customizer |

## Схема скина

```json
{
  "shape": "floating",        // full floating pill islands notch underline hug frame
  "height": 30,               // 0 = стоковая высота из shell.toml
  "gap": 6,                   // отступ от края экрана
  "margin": 10,               // поля слева/справа
  "width": 1.0,               // доля ширины (floating/pill/notch)
  "radius": 12,
  "padding": -1,              // отступ модулей от краёв подложки; -1 = сток
  "islandGap": 6,             // поля островов
  "background": "bar",        // цвет: роль или #hex
  "backgroundAlpha": 0.85,    // -1 = альфа из темы
  "gradient": "accent",       // второй цвет горизонтального градиента (нет ключа — без градиента)
  "border": "accent", "borderWidth": 1, "borderAlpha": 0.6,
  "text": "bar", "active": "bar",
  "shadow": true,
  "glow": false,              // ореол цвета рамки вместо тени
  "autoHide": false,          // прятать за край, выезжает по наведению (место не резервирует)
  "moduleStyle": "plain",     // plain pills hover — подложка у каждого модуля
  "moduleBackground": "foreground", "moduleAlpha": 0.08,
  "spacing": 0,               // зазор между модулями
  "font": "",                 // пусто = системный шрифт
  "transparent": false,       // стоковый прозрачный режим (пишется в shell.json)
  "note": "подпись для Customizer"
}
```

Цвет — `bar` (стоковый цвет бара из `[bar]` темы), роль шелла (`background`, `foreground`, `accent`,
`muted`, `urgent`), любой ключ `colors.toml` текущей темы (`red`, `cyan`, `lighter_background`, …)
или `#rrggbb`. Роли перекрашиваются вместе с темой.

Формы: `full` — сток; `floating` — полоса с отступами; `pill` — floating с радиусом в полвысоты;
`islands` — отдельный остров под каждой секцией; `notch` — «чёлка» у края; `underline` — линия по
краю; `hug` — полоса во всю ширину с вогнутыми углами под ней (радиус из `radius`, минимум 8); углы видны
на пустом столе и при больших `gaps_out`, окна их перекрывают. `frame` — полоса и рамка цвета бара по
остальным краям экрана (`frameWidth`, по умолчанию 8) со скруглёнными внутренними углами (`radius`, минимум 8):
рамку рисует `ScreenBorder.qml` — окно на весь экран поверх окон (слой Top, клики проходят насквозь) и три
невидимые полоски с `exclusiveZone`, поэтому окна стоят внутри. Compact и autoHide на `frame` не действуют.
Вертикальный бар (left/right) умеет только `full`, `floating` и `frame`, остальное откатывается к `floating`
(`hug` — к `full`).

В Bar Tweaks: `h`/`l` или `−`/`+` (можно зажать), `x` — сбросить параметр к умолчанию, `⏎` на цвете —
свой цвет, `i` — ввести значение (вне диапазона / не из списка — не применяется, предупреждение под
строкой; то же из терминала: `customizer.sh tweak <ключ> set <значение>`). Параметры разбиты на разделы
(Форма и размер, Цвета, Модули, Эффекты, Workspaces, Compact): `[` / `]` — к разделу, `/цвет` — весь раздел. Под каждой строкой подписано значение по умолчанию, `●` — параметр изменён.

Блюр под полупрозрачным баром — layer rule в `apps/hyprland/windows.lua` (`ignore_alpha = 0.2`).

## Workspaces

`omarchy.workspaces` в этом баре подменяется на `SkinWorkspaces.qml` (раскладки и `shell.json` не меняются).
Настройки — в том же `bar-skin.json`, в Customizer — строки «Workspaces: …» в Bar Tweaks:

| Ключ | Умолч. | Что делает |
|---|---|---|
| `wsLabelStyle` | `omarchy` | подписи: omarchy numbers circled circled-filled circled-sans circled-sans-filled parens fullwidth superscript roman roman-small kanji greek cyrillic braille dots squares diamonds stars triangles hearts hexagons bars none |
| `wsWindowIcons` | `false` | иконки окон внутри workspace |
| `wsIconStyle` | `color` | color mono tinted accent bubble faded glyph letter dots count |
| `wsMaxIcons` | `3` | иконок на workspace, остальные — «+N» |
| `wsDedupe` | `true` | одно приложение — одна иконка |
| `wsShown` | `5` | сколько workspace видно всегда (занятые до 10 — всегда) |
| `wsShowEmpty` | `true` | показывать пустые |
| `wsActivePill` | `false` | плашка цвета акцента под активным |
| `wsActiveColor` | как в стиле | цвет текущего workspace: роль темы или `#hex` (и плашки) |

Колесо мыши над workspaces листает их. Иконки берутся из `.desktop` по appId и грузятся синхронно
(асинхронные темированные иконки уже роняли шелл).

## Compact

Бар сжимается на мониторе, где выполнено условие, и разворачивается обратно по наведению.
Настройки — строки «Compact: …» в Bar Tweaks, пресет `compact-focus`:

| Ключ | Умолч. | Что делает |
|---|---|---|
| `compact` | `off` | `single` — на workspace одно тайловое окно (или полноэкранное); `fullscreen` — только полноэкранное/развёрнутое; `always` |
| `compactHeight` | `22` | высота подложки в compact; `0` — не менять. Виджеты не уменьшаются, а центрируются |
| `compactModules` | `essentials` | `essentials` — меню, workspaces, часы, сеть, звук, питание; `center` — только центр; `minimal` — workspaces + часы; `all` |
| `compactShape` | `full` | форма в compact; `same` — как обычно |
| `compactAlpha` | `-1` | альфа фона в compact; `-1` — как обычно |
| `compactReserve` | `keep` | `keep` — место под баром прежнее (окна не дёргаются, под тонким баром остаётся полоса); `shrink` — окна получают место |
| `compactExpandOnHover` | `true` | разворачивать по наведению и пока открыта панель бара |

Плавающие окна при подсчёте `single` не учитываются. Макет в Customizer показывает бар в обычном виде.

## Новый пресет

- Скин: положить JSON в `skins/` плагина `kamradsmeshnyavy.bar`, он сразу появится в Bar Skin.
- Свой скин: Bar Skin → «💾 Сохранить текущий скин…» — то, что сейчас на баре (с правками из Bar Tweaks),
  ляжет в `~/.config/omarchy/bar-skins/<имя>.json` (в dotfiles — `apps/omarchy-shell/bar-skins/`) и появится
  в списке со ★. Удалить — `D` на строке своего скина (с подтверждением, файл уходит в корзину). `my-glass-islands` — вид бара до рамки (стекло-острова, greek, compact).
  Или собрать в Bar Tweaks и скопировать `~/.config/omarchy/bar-skin.json`.
- Раскладка: в Bar Layout строка «💾 Сохранить текущую как пресет…».

## Обновление апстрима

Правки клона в `Bar.qml` помечены `// skin:`. После обновления Omarchy:

```sh
just bar-upstream-diff   # стоковый Bar.qml против клона
```

Если апстрим поменялся, проще склонировать заново и перенести блоки `// skin:`. После правок QML —
`omarchy restart shell`: клонированные плагины не перезагружаются на лету.
