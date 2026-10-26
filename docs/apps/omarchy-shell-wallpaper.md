# Обои и theme switcher: переходы, стили пикера, кэш миниатюр

Два клона первой стороны, оба настраиваются в Customizer (Super+Shift+T):

| Плагин | Клон | Настройки | Категория |
|---|---|---|---|
| `kamradsmeshnyavy.background` | `omarchy.background` | `~/.config/omarchy/wallpaper-transition.json` | Wallpaper FX |
| `kamradsmeshnyavy.image-picker` | `omarchy.image-picker` | `~/.config/omarchy/image-picker.json` | Theme Switcher |

Оба файла читаются на лету. Правки клонов помечены `// fx:` и `// picker:`.

## Переходы обоев

Переход рисует свой шейдер `shaders/transition.frag` (один на все эффекты, номер — `mode`) через
`TransitionEffect.qml`. После правки шейдера: `just shaders-wallpaper` (qsb → `transition.frag.qsb`,
оба файла в репо).

Эффекты (свои реализации по идеям swww и gl-transitions): `slant` (как в стоке), `fade`, `wipe`,
`wave`, `grow`, `outer`, `diamond`, `clock`, `blinds`, `doors`, `mosaic`, `dissolve`, `pixelize`,
`ripple`, `swirl`, `crosszoom`, `slide`, `zoom`, `glitch`, `burn`, `waterdrop`, `hexagon`, `random`,
`none`.

| Ключ | Умолч. | |
|---|---|---|
| `type` | `slant` | эффект |
| `duration` | `420` | мс |
| `easing` | `InOutCubic` | кривая Qt: InOutQuad, OutExpo, OutBack, OutBounce, Linear, … |
| `angle` | `0` | градусы для wipe / wave / slide |
| `origin` | `center` | откуда круг и капля: center / cursor / random |
| `softness` | `0.02` | ширина мягкого края |

`omarchy-shell background replay` — проиграть текущий эффект (соседние обои темы → текущие). В
Customizer это `p`.

## Theme switcher

Один overlay для выбора темы и обоев. Стили: `slices` (сток), `cards`, `coverflow`, `strip`, `wide`,
`polaroid`. Поверх стиля — `expandedWidth/Height`, `sliceWidth/Height`, `spacing`, `skew`,
`cardRadius`, `dim`, `selectedBorder`, `animMs`, `scrimAlpha`, `labels`; 0 / -1 — значение стиля
или темы (ключ не хранится). `autoCache` — кэшировать миниатюры после смены темы
(`omarchy-themes/hooks/theme-set`).

## Кэш миниатюр — почему пикеры тормозили

`omarchy-menu-images` хранит миниатюры в `~/.cache/omarchy/image-selector/` и индекс
`index.tsv` (путь, размер:mtime, хэш). Обои текущей темы лежат по одному и тому же пути
`~/.local/state/omarchy/current/theme/backgrounds`, но при каждой смене темы копируются заново с новым
mtime — индекс растёт без конца (было 56 тыс. строк, 9 ГБ миниатюр). После смены темы кэш строк
промахивается, и для каждой картинки индекс прогоняется `awk`'ом: ~55 мс × 439 обоев ≈ 24 с.

В Customizer → Theme Switcher:
- **⚡ Закэшировать миниатюры** — `omarchy-theme-switcher --preload` и
  `omarchy-menu-images --cache-only` для превью тем и для обоев текущей темы (те же каталоги, что у
  `omarchy-theme-bg-switcher`: ключ кэша строк — md5 списка каталогов);
- **🧹 Очистить неиспользуемые** — оставляет миниатюры картинок, которые существуют с той же
  подписью, и всё, на что ссылаются `*.rows`; остальное удаляет и переписывает индекс без дублей.
  Перед удалением — подтверждение с размером;
- **autoCache** — то же кэширование в фоне после каждой смены темы.
