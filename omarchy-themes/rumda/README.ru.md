# Темы rumda-*

[🇬🇧 English](README.md)

Темы Omarchy по мотивам [Rumda](https://github.com/hexonide/rumda) (автор hexonide). У репозитория нет лицензии, поэтому
здесь взяты только его цвета и облик — без файлов и без его рисунков с котами. `rumda-dark` (кофейный графит с
карамельным акцентом) и `rumda-light` (песок с коричневыми чернилами) — **одноцветные**: синтаксис, 16 цветов терминала,
статусы и btop — только оттенки акцента и чернил. `rumda-dark-color` и `rumda-light-color` сохраняют разноцветный
терминал самого Rumda.

- Палитры — из его `Colors.qml` (бар, дашборд, рамки) и `kitty.conf`.
- btop — по раскладке его `rumda.theme`: коричневые рамки, графики от охры через кирпич к ржавчине.
- fastfetch — в духе его neofetch: рамка `┌──┐`, короткие ключи (os, krn, up, pkg, sh, wm) акцентом; логотип — своя
  пиксельная мордочка кота (`apps/rumda-logo.txt`).
- Обои — сплошной цвет темы со своим пиксельным силуэтом кота в углу (`1-plain`) или без него.
- Шрифт оболочки — пиксельный **Dogica Pixel** (Roberto Mocci, SIL OFL 1.1, `kamradsmeshnyavy.customizer/fonts/rumda`).

```sh
python3 build.py            # все темы
python3 build.py dark       # выбранные
```
