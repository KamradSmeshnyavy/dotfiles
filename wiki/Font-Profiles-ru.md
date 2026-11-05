[English](Font-Profiles) · **Русский**

# Профили шрифтов

`omarchy-font-profile` меняет шрифты **всей системы** разом: терминалы (kitty, ghostty, alacritty, foot), fontconfig
`monospace` / `sans-serif`, GTK, VS Code, шрифты страниц в Firefox и Helium (а также Dark Reader, Stylus, Surfingkeys и
интерфейс Firefox) и палитру DOT-MATRIX плагинов оболочки.

```sh
omarchy-font-profile             # текущий профиль
omarchy-font-profile list        # все профили с описанием
omarchy-font-profile nothing     # применить
```

Или в Customizer: Рабочий стол → Виджеты → **Шрифты системы**. Стили тоже ставят профиль (DOT-MATRIX → `pixel`, Retro →
`retro`, Paper — бумажные).

> Скрипт и шрифты DotMatrix — часть полных dotfiles (`scripts/bin/omarchy-font-profile`); если стоят только плагины,
> строка в Customizer скрыта.

## Профили

| Профиль | Текст | Код / терминал | Идея |
|---|---|---|---|
| `stock` | Maple Mono NF CN | Maple Mono NF CN | как в Omarchy; точки только в DOT-MATRIX-виджетах |
| `nothing` | Geist | DotMatrix Mono | как Nothing OS: точками только часы, цифры, крупные заголовки |
| `dot` | Geist | DotMatrix Mono | точечный слой во всём крупном и коротком (бар, заголовки, лаунчер, блокировка, OSD, заголовки страниц) |
| `pixel` | Geist | DotMatrix Pixel | `dot` плюс пиксельный терминал с лигатурами |
| `dot-accents` | Geist | DotMatrix Pixel | `pixel` плюс точками заголовки и элементы сайтов, жирный текст терминала и подписи оболочки |
| `dots-all` | DotMatrix LED | DotMatrix LED | каждый знак — точками |
| `lumen` | DotMatrix Lumen Sans | DotMatrix Lumen Mono | точки 5×7 для мелкого текста, DotMatrix Dot только для крупного |
| `dots-all-lumen` | DotMatrix Lumen Sans | DotMatrix Lumen Mono | выверенные «точки везде» с размерами по сетке |
| `dots-all-test-a…f` | DotMatrix Board A…F | DotMatrix Board A…F Mono | шесть форм точки для сравнения (круглая / квадратная, 65–80 %) |
| `paper-shell` / `paper-ui` / `paper-hand` / `paper-all` | Maple → Pangolin → Caveat | Maple → Monaspace Radon → Caveat | от «рукописное только в оболочке» до «всё рукописное» |
| `retro` | Pixelify Sans | DotMatrix Pixel | всё пиксельное |
| `nothing-os-test`, `ndot-test` | NType 82 / Ndot 57 | Lettera Mono / Board Mono | пробы со шрифтами Nothing (ставятся вручную, в репо их нет) |

## Шрифты DotMatrix

Собираются из открытых (OFL) исходников скриптами Customizer: **DotMatrix Dot** (Doto + кириллица + точечные лигатуры),
**DotMatrix Mono** (Geist Mono с лигатурами всегда), **DotMatrix Pixel** (Terminus с исправленной кириллицей, курсивом в
ячейке, пиксельными лигатурами), **DotMatrix Board / Lumen** (Matrix Sans, перерисованный настоящими круглыми точками на
сетке 5×7). Профиль, которому они нужны, собирает их при первом применении; вручную — `just dotmatrix-fonts`.

Точки ровнее всего, когда шаг точки — целое число пикселей экрана, поэтому профили по сетке ставят терминалам 15 pt,
VS Code 20 px, GTK 11.25 pt (при масштабе 2); прежние размеры возвращаются при смене профиля.

## Git остаётся чистым

Шрифты терминалов уходят в сгенерированные, игнорируемые git файлы `fonts.conf`, которые `kitty.conf` / конфиг ghostty
подключают последними; ключи шрифтов VS Code прячет clean-фильтр. Смена профиля никогда не оставляет диффов в репо.

Справочник: [docs/apps/omarchy-shell-dotmatrix.ru.md](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-dotmatrix.ru.md).
