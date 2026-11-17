# Темы rumda-*

[🇬🇧 English](README.md)

Темы Omarchy по мотивам [Rumda](https://github.com/hexonide/rumda) (автор hexonide). У репозитория нет лицензии, поэтому
здесь взяты его цвета, облик и обои — код не копируется. `rumda-dark` (кофейный графит с
карамельным акцентом) и `rumda-light` (песок с коричневыми чернилами) — **одноцветные**: синтаксис, 16 цветов терминала,
статусы и btop — только оттенки акцента и чернил. `rumda-dark-color` и `rumda-light-color` сохраняют разноцветный
терминал самого Rumda.

- Палитры — из его `Colors.qml` (бар, дашборд, рамки) и `kitty.conf`.
- btop — по раскладке его `rumda.theme`: коричневые рамки, графики от охры через кирпич к ржавчине.
- fastfetch — в духе его neofetch: рамка `┌──┐`, короткие ключи (os, krn, up, pkg, sh, wm) акцентом; логотип — своя
  пиксельная мордочка кота (`apps/rumda-logo.txt`).
- Обои — первыми его, из `pictures/` (`0-original`: тёмные с котом, светлые с кофе; дальше `0r-…`: варианты тёмных с катаной и
  сакурой, тёплые песочные у светлой), дальше свои: сплошной цвет темы с пиксельным силуэтом кота в углу (`1-plain`) или без
  него. `build.py` берёт их из клона Rumda (`RUMDA_SRC`) или с GitHub.
- Шрифт оболочки — пиксельный **Dogica Pixel** (Roberto Mocci, SIL OFL 1.1, `kamradsmeshnyavy.customizer/fonts/rumda`).
- У окон — двойная рамка Rumda: коричневая рамка 3 px, полоса цвета фона 13 px (у светлой — песочная 11 px) и внешняя
  песочная линия — через плагин borders-plus-plus (`just hypr-plugins`, см. `docs/apps/hyprland.ru.md`); без него
  рисуется только одна рамка.

```sh
python3 build.py            # все темы
python3 build.py dark       # выбранные
```

## Dynamic

`dynamic-<райс>` из обоев (`../scripts/omarchy-rice-dynamic`, движок rice, `build.py` → `dynamic()`): карамельные ступени фона, рамка — акцент к фону; при перевороте 16 цветов терминала — от второго варианта. Подробнее — `../APP-THEMING.md`, Customizer → Dynamic.
