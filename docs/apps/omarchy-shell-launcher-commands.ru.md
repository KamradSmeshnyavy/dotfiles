# Команды лаунчера omarchy-shell (`>…`)

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
| `>lock` | — | `omarchy-system-lock` |
| `>power` | — | меню выключения (виджеты) |

`>skin`, `>shader`, `>custom` нужны плагин `kamradsmeshnyavy.customizer`, `>dash` и `>power` — `kamradsmeshnyavy.widgets`;
без них эти команды не показываются (так `Commands.js` можно публиковать через `just publish-launcher`).
Списки тем и скинов читаются один раз за открытие меню при первом `>`. Подписи — на языке Customizer.
Новая команда — запись в `catalog()` в `Commands.js`: `name`, `icon`, `desc`, и `action` либо `args()`.
