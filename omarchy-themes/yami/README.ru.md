# Темы yami-*

[🇬🇧 English](README.md)

Семь тёмных тем Omarchy по мотивам [yami](https://github.com/Trendorin/yami) (MIT, © Trendorin and the yami contributors), по
одной на каждый пресет акцента yami: `yami-blood`, `-ash`, `-sakura`, `-amber`, `-venom`, `-ice`, `-dusk`.

У yami один акцент, остальные тона выводятся из него (`shell/src/recolor_math.rs`): графит, чуть подкрашенный оттенком
акцента, — фон, панели и поверхности; рамки и приглушённый текст — смеси панели с акцентом. `build.py` повторяет этот вывод
и раскладывает результат по приложениям генератором тем `nothing` (`../nothing/build.py`). Цветов синтаксиса у yami нет —
приглушённые подобраны здесь под графит и подтянуты до контраста 4.5. Обои — графит с сеткой мелких квадратных точек и
мягким светом из угла, как пиксельный фон yami.

```sh
python3 build.py             # все темы
python3 build.py blood ash   # выбранные
```

Шрифт оболочки райса — пиксельный Tiny5 — ставит профиль шрифтов `yami` (`omarchy-font-profile yami`, шрифты в
`kamradsmeshnyavy.customizer/fonts/yami`, OFL).
