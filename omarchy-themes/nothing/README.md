# nothing

Тема Omarchy в духе Nothing OS, но не монохромная: интерфейс остаётся в стиле Nothing (чёрный или белый,
точечная графика, один сигнальный цвет), а код, git и терминал получают различимые цвета.

| Вариант | Тема Omarchy | Характер |
|---|---|---|
| Signal | `nothing-signal` | OLED-чёрный, тёплый белый, сигнал — красный Nothing |
| CMF | `nothing-cmf` | Тёплый графит по мотивам CMF by Nothing, сигнал — оранжевый |
| Glyph White | `nothing-glyph` | Светлая, как белый Nothing Phone, тёмные насыщенные тона |
| Ash | `nothing-ash` | Тональная: красный Nothing и серые разной теплоты |
| Ember | `nothing-ember` | Тональная: оранжевый CMF, янтарь, персик, песок |
| Steel | `nothing-steel` | Тональная: красная семья + холодная сталь, ровно два цвета |
| Ash Light | `nothing-ashlight` | Тональная светлая: тёмно-красные и угольные тона на белом |

Тональные варианты (`tonal = True` в палитре) различают роли оттенком одного цвета и начертанием: ключевые слова
жирные, типы курсивом. «Зелёный» терминала у них — самый светлый тон, поэтому добавленное в `git diff` выделяется
яркостью, а не цветом.

## Как устроено

- `palettes.py` — три палитры с одинаковыми ролями: фон, текст, сигнал, ключевые слова, строки, числа, типы,
  функции, свойства, special, статусы, фоны диффа. `python3 palettes.py` проверяет контраст (WCAG ≥ 4.5,
  комментарии ≥ 3) и различимость синтаксических цветов (ΔE ≥ 15).
- `build.py` раскладывает роли по приложениям и пишет `signal/`, `cmf/`, `glyph/`. Шаблоны Omarchy
  (`default/themed/*.tpl`) не используются: файл в каталоге темы Omarchy не перезаписывает.
  Правка — в `palettes.py` / `build.py`, затем `python3 build.py`. Обои пересоздаются, только если их удалить.
- Свои темы: Neovim (своя colorscheme `nvim/colors/nothing-<v>.lua` + тема lualine, без aether), VS Code
  (`vscode-theme.json` — ставится как «Omarchy»), kitty, ghostty, alacritty, foot, Hyprland, btop, helix, cava,
  lazygit, gitui, atuin, television, fzf, tmux, yatline, fastfetch.
- yazi-flavor (с tmTheme для превью), nushell, lla, rmpc, glow берут раскладку из `catppuccin-mocha-efter`
  и перекрашиваются по таблице `MOCHA` → роль.
- bat и delta — `BAT_THEME=ansi`, они рисуют на подобранных вручную ANSI-цветах терминала.
- Обои — точечные фото nihil, перекрашенные в цвета варианта.
- Nihil-интерфейс (бар, панели, уведомления, lock) берёт цвета темы сам — палитра Nihil в режиме `theme`.
