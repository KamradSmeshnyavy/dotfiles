# Темы surface-*

[🇬🇧 English](README.md)

Темы Omarchy по мотивам [surface-dots](https://github.com/snes19xx/surface-dots) автора **snes19xx**. Файла лицензии у
репозитория нет, но в README сказано, что брать можно что угодно, если указать автора и источники фото, — поэтому цвета,
кривые и раскладка взяты оттуда, со ссылкой здесь. Его обои тоже взяты (`0-original`).

`surface-dark` (графит `#141719` с зеленью Everforest) и `surface-light` (тёплая бумага `#f0ece6` с оливковыми
чернилами) — **одноцветные**: синтаксис, 16 цветов терминала, статусы и btop — только оттенки зелени и чернил.
`surface-dark-color` и `surface-light-color` — с его собственным терминалом Everforest.

- Палитры — из его `lib/ThemeEngine.qml` (поверхности, текст, акценты) и `kitty/themes/everforest*.conf`.
- Рамки окон — 1 px зеленью с прозрачностью, у неактивного — серая, его тёплая тень и зелёный groupbar (`hyprland.lua`);
  толщину и углы задаёт стиль.
- fastfetch — как его `config.jsonc`: разделитель ` ▐ `, ключи-значки Nerd Font, строка `─` под заголовком, кружки
  цветов; логотип — свой пиксельный Сатурн полублоками (в честь его меню выключения Cassini).
- Обои — первыми его (`0-original`: `default-dark` / `default-light`; у тёмной ещё горы и Земля с его экранов блокировки —
  `0r-…`, ужаты до 3840 px), их берёт `build.py` из клона surface-dots (`SURFACE_DOTS_SRC`) или с GitHub; дальше свои: бумажное
  зерно цвета темы со сгенерированными хребтами гор зеленью (`1-ridges`) или одно зерно (`2-paper`).
- Шрифты (`kamradsmeshnyavy.customizer/fonts/surface`): **Manrope** (оболочка), **Newsreader** (меню выключения),
  **EB Garamond** (экран блокировки) — SIL OFL 1.1, Google Fonts; **CMU Typewriter Text** (терминал) — SIL OFL 1.1, из
  пакета cm-unicode. Шрифтовой профиль: `omarchy-font-profile surface`.

```sh
python3 build.py            # все темы
python3 build.py dark       # выбранные
```
