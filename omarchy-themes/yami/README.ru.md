# Темы yami-*

[🇬🇧 English](README.md)

Семь тёмных тем Omarchy по мотивам [yami](https://github.com/Trendorin/yami) (MIT, © Trendorin and the yami contributors), по
одной на каждый пресет акцента yami: `yami-blood`, `-ash`, `-sakura`, `-amber`, `-venom`, `-ice`, `-dusk`.

У yami один акцент, остальные тона выводятся из него (`shell/src/recolor_math.rs`): графит, чуть подкрашенный оттенком
акцента, — фон, панели и поверхности; рамки и приглушённый текст — смеси панели с акцентом. `build.py` повторяет этот вывод
и раскладывает результат по приложениям генератором тем `nothing` (`../nothing/build.py`). Цветов синтаксиса у yami нет —
приглушённые подобраны здесь под графит и подтянуты до контраста 4.5. Обои — графит с сеткой мелких квадратных точек и
мягким светом из угла, как пиксельный фон yami.

16 цветов терминала — как у yami (`recolor_apps.rs`, `ansi`): привычные оттенки, сдвинутые на 18 % к акценту, цвет 0 — панель, 7 / 15 — текст. fastfetch тоже свой, как у yami: знак 闇 полублоками в четыре полосы от яркого к глубокому акценту с тенью, «YAMI // hyprland», ключи акцентом и полоса палитры (`apps/fastfetch.jsonc`, `apps/yami-logo.txt`).

По умолчанию темы **одноцветные**, как сам yami на снимках: синтаксис, 16 цветов терминала и статусы — только оттенки акцента и серого графита, btop — ровно как у yami (`btop.theme`, по `recolor_apps.rs`, `btop`). `python3 build.py --color` собирает вместо этого разноцветный вариант (`ansi` yami и приглушённый синтаксис).

```sh
python3 build.py             # все темы
python3 build.py blood ash   # выбранные
```

Шрифт оболочки райса — пиксельный Tiny5 — ставит профиль шрифтов `yami` (`omarchy-font-profile yami`, шрифты в
`kamradsmeshnyavy.customizer/fonts/yami`, OFL).

## Dynamic

`dynamic-<райс>` из обоев (`../scripts/omarchy-rice-dynamic`, движок rice, `build.py` → `dynamic()`): вся палитра yami — `derive` от акцента обоев (родной алгоритм yami); светлая — та же палитра, перевёрнутая. Подробнее — `../APP-THEMING.md`, Customizer → Dynamic.
