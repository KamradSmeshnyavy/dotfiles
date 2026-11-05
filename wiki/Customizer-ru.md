[English](Customizer) · **Русский**

# Customizer

Один оверлей на весь внешний вид Omarchy — `Super+Shift+T`. У всего живое превью, выбор переживает перезагрузку, а
группы других плагинов появляются сами, как только плагины установлены.

Репозиторий: [omarchy-customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) (GPL-3.0).

![Customizer](https://raw.githubusercontent.com/KamradSmeshnyavy/omarchy-customizer/main/screenshots/desktop.webp)

## Группы

| Группа | Что внутри |
|---|---|
| **Пресеты** | снимки всего рабочего стола (встроенный DOT-MATRIX + свои, ★), **Стиль** (см. [Стили](Styles-ru)), углы окон, «Восстановить прежнюю настройку» |
| **Рабочий стол** | Тема (палитра + превью), Обои, Recolor (любая картинка в цвета текущей темы через lutgen), Dotify (LED-обои и генератор глифа Arch), Wallpaper FX\*, Виджеты\*, Дашборд\*, Шрифты системы ([Профили шрифтов](Font-Profiles-ru)) |
| **Бар\*** | Bar Skin (свои ★), Bar Layout, Bar Tweaks (41 параметр, у каждого значение по умолчанию и живое превью), Виджеты бара |
| **Окна** | Окна (отступы, рамки, скругление, тень, затемнение, раскладка), Анимации (19 пресетов), Прозрачность, Размытие, OSD и уведомления\* (наборы звуков, звуки окон и рабочих столов Hyprland), Glyph (подсветка краёв в духе Nothing), Шейдер (CRT / TFT / Paper / Neon) |
| **Блокировка\*** | дизайн экрана блокировки с превью в текущей теме, Lock Tweaks |
| **Пикеры\*** | стиль выбора темы и обоев, кэш миниатюр, скины лаунчера\* |

\* — появляется, когда установлен соответствующий плагин.

## Клавиши

| Клавиши | |
|---|---|
| Tab / 1–6 | группы |
| j k · l ⏎ · h | движение · открыть · назад |
| / | поиск |
| h l, − + | изменить параметр · x — сбросить · i — ввести значение |
| p | проиграть / показать вживую (переходы, дизайны блокировки, пикер) |
| r | удиви меня |
| ? · q / Esc | все клавиши · закрыть |

Открыть сразу на нужной группе: `omarchy-shell shell toggle kamradsmeshnyavy.customizer '{"category":"windows"}'`.

## Как выбор переживает перезагрузку

Анимации — в `~/.local/state/omarchy-customizer/animations.lua`; прозрачность, размытие и шейдер — в
`~/.local/state/hypr/{opacity,blur,screen-shader}`. Customizer применяет их при старте оболочки и после каждого
`hyprctl reload`. Чтобы при перезагрузке не мелькали значения по умолчанию, подключите его хук в конфиге Hyprland
(например, в конце `~/.config/hypr/looknfeel.lua`):

```lua
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/hypr/customizer.lua")
```

Скрипты работают и сами по себе:

```lua
o.bind("SUPER + ALT + O", "Next transparency preset", "~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/opacity.sh next")
o.bind("SUPER + ALT + U", "Next blur preset", "~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/blur.sh next")
o.bind("SUPER + ALT + C", "Toggle screen shader", "~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/crt-toggle.sh")
```

## Из терминала

Любой параметр можно задать без оверлея: `customizer.sh tweak <ключ> set <значение>` (в папке плагина). Свои пресеты,
анимации и шейдеры — в `~/.config/omarchy/customizer/{presets,animations,shaders}/`, см. [Своё](Make-Your-Own-ru).

## Язык

Английский и русский: `"lang"` в `~/.config/omarchy/customizer.json`, иначе `$LANG`. Переводы — `i18n/<lang>.json`,
ключ — английская строка; новый язык — ещё один файл.
