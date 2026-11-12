# Команды лаунчера omarchy-shell (`>…`)

[🇬🇧 English](omarchy-shell-launcher-commands.md)

Лаунчер — плагин `kamradsmeshnyavy.menu` (`apps/omarchy-shell/plugins/kamradsmeshnyavy.menu/`). Поиск, начинающийся
с `>`, переключает его в режим команд (идея caelestia, написано с нуля, `Commands.js`). Строки команд идут
в тот же список, что и обычные пункты, поэтому выглядят по-своему в каждом скине лаунчера.

| Ввод | Что показывает |
|---|---|
| `>` | все команды с описанием |
| `>th` | команды, чьё имя начинается с `th` |
| `>theme` + Enter | дописывает `>theme ` и показывает аргументы |
| `>theme rose` | аргументы, в которых есть `rose` |

| Команда | Аргументы | Делает |
|---|---|---|
| `>theme` | темы Omarchy (свои и стоковые) | `omarchy-theme-set` |
| `>dynamic` | `tonal-spot` `vibrant` `expressive` `fruit-salad` `monochrome` `light` | тема из обоев (`omarchy-wallpaper-theme`; только если он в `PATH`) |
| `>wall` | следующие / выбрать… | `omarchy-theme-bg-next` / `omarchy-theme-bg-switcher` |
| `>skin` | скины бара: ★ свои и пресеты | `customizer.sh apply bar-skins` |
| `>dash` | — | дашборд виджетов |
| `>dnd` | — | «Не беспокоить» |
| `>shader` | — | шейдер экрана (crt-toggle) |
| `>custom` | — | Customizer |
| `>ocr` | — | текст из области экрана (`omarchy-capture-text`) |
| `>qr` | — | распознать QR-код в области экрана (`omarchy-capture-qr`, ещё Super+Alt+Print) |
| `>curtain` | — | шторка для стрима: окна скрыты из трансляции (`omarchy-curtain`, Super+Ctrl+Alt+S) |
| `>reading` | — | режим чтения |
| `>lock` | — | `omarchy-system-lock` |
| `>power` | — | меню выключения (виджеты) |

`>skin`, `>shader`, `>custom` нужны плагин `kamradsmeshnyavy.customizer`, `>dash` и `>power` — `kamradsmeshnyavy.widgets`;
без них эти команды не показываются (так `Commands.js` можно публиковать через `just publish-launcher`).
Списки тем и скинов читаются один раз за открытие меню при первом `>`. Подписи — на языке Customizer.
Новая команда — запись в `catalog()` в `Commands.js`: `name`, `icon`, `desc`, и `action` либо `args()`.

## Быстрые режимы (`= : @ ! ;`)

Первый символ поиска включает быстрый режим (`Modes.js`; идеи из Vitreus и glyph-rice, код свой). Строки — обычные
строки лаунчера, поэтому работают во всех скинах.

| Ввод | Режим | Enter |
|---|---|---|
| `=2^10`, `=5 km to mi`, `=100 usd to eur` | калькулятор, единицы и валюты (`qalc`) | скопировать результат |
| `:fire`, `:k cat`, `:s arrow` | эмодзи, каомодзи (`:k`), символы (`:s` — стрелки, математика, валюты, рамки, греческие…) | скопировать |
| `@`, `@fire` | открытые окна (заголовок / класс) | перейти к окну |
| `!g …`, `!yt …`, `!gh …`, `!aw …` | веб-поиск; bang: `g` `d` `yt` `gh` `w` `aw` `aur` `pkg` `r` `so` `mdn` `tr` `m` `ya`; без bang — DuckDuckGo | открыть в браузере |
| `;`, `;http` | история буфера обмена (`cliphist`) | вернуть в буфер |

Эмодзи и символы — из базы Unicode, встроенной в Python (`scripts/gen-charms.py` → `charms.json`): одиночные кодовые
точки с английскими именами, без последовательностей ZWJ, флагов и оттенков кожи. Каомодзи — свой список с английскими
и русскими метками (`:k кот`). Нужны `qalc`, `cliphist`, `wl-copy`.
