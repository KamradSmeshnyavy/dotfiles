# Темы unit3-*

[🇬🇧 English](README.md)

Темы Omarchy по мотивам [Unit-3](https://github.com/samyns/Unit-3) автора samyns — райса Hyprland + Quickshell в духе
NieR:Automata (MIT). Цвета взяты из его конфигов.

- `unit3-dark` — его стол и терминал: тёмная сепия `#0b0a09`, текст `#c8b89a`, приглушённые акценты (красный `#c87060`,
  зелёный `#60a880`, синий `#6090c8`, золото `#c8a860`); 16 цветов терминала — ровно из его `kitty.conf`.
- `unit3-paper` — его меню (лаунчер, центр управления) на весь стол: бежевая бумага NieR `#d6cfb5`, чернила `#463f2e`,
  красный `#6e2a2a`.
- Окна — рамка 1 px цветом текста (неактивные — `#1a1814`), без скругления, тени и размытия, как в его `hyprland.conf`.
- Обои — первыми его (`assets/wallpapers` райса, лежат в репозитории): 2B в лесу (`0-original`), бой, логотип YoRHa и
  сцена из Hollow Knight; дальше нарисованная сетка NieR цветами темы (`1-grid`). Картинки — игровой арт их авторов, под
  MIT райса не подпадают.
- Шрифтовой профиль: `omarchy-font-profile unit3` (Share Tech Mono в оболочке, терминале и коде, OFL —
  `kamradsmeshnyavy.customizer/fonts/unit3`).

```sh
python3 build.py          # обе
python3 build.py paper    # только выбранные
```

## Dynamic

`dynamic-<райс>` из обоев (`../scripts/omarchy-rice-dynamic`, движок rice, `build.py` → `dynamic()`): приглушённые цвета (насыщенность не выше 0.4), рамка окна цветом текста; Бумагу можно сделать тёмной, тёмную — светлой. Подробнее — `../APP-THEMING.md`, Customizer → Dynamic.
