[English](Wallpapers-and-Pickers) · **Русский**

# Обои и пикеры

## Wallpaper FX

**24 перехода обоев** на одном своём шейдере: slant, fade, wipe, wave, grow, outer, diamond, clock, blinds, doors,
mosaic, dissolve, pixelize, ripple, swirl, crosszoom, slide, zoom, glitch, burn, waterdrop, hexagon, random, none.
Репозиторий: [omarchy-wallpaper-fx](https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx --enable
omarchy restart shell
```

Customizer → Рабочий стол → **Wallpaper FX**: эффект, длительность, кривая, угол, откуда (центр / курсор / случайно),
мягкость края; `p` проигрывает текущий эффект. Из терминала: `omarchy-shell background replay`. Настройки:
`~/.config/omarchy/wallpaper-transition.json`.

## Стили пикера

Шесть стилей выбора темы и обоев: `slices` (сток), `cards`, `coverflow`, `strip`, `wide`, `polaroid`. Репозиторий:
[omarchy-image-picker-styles](https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles). Customizer → Пикеры. Открывать как обычно:
Super+Shift+Ctrl+Space (темы), Super+Ctrl+Space (обои).

**Пикер тормозит?** Индекс миниатюр Omarchy растёт при каждой смене темы. Customizer → Пикеры → «⚡ Закэшировать
миниатюры» и «🧹 Очистить неиспользуемые»; autoCache кэширует в фоне после каждой смены темы
([почему](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-wallpaper.ru.md)).

## Инструменты для обоев в Customizer

- **Recolor** — любая картинка в палитру текущей темы (lutgen).
- **Dotify** — LED-обои из точек и генератор глифа Arch.
- **Тема из обоев** — `just theme-from-wallpaper` / `>dynamic` в лаунчере (matugen).
