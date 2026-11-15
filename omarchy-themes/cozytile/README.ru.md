# Темы cozytile-*

[🇬🇧 English](README.md)

Темы Omarchy по мотивам [Cozytile](https://github.com/Darkkal44/Cozytile) автора Darkkal44 (райс на Qtile). Лицензии у
репозитория нет, поэтому взяты цвета и облик, его код не копируется.

Пять тем, как у него: **cozy** (сиреневые сумерки), **sakura** (розовая), **natura** (тёмная трава), **everforest** (туманный
ельник) и светлая **carbon** (серая «электронная бумага»). По умолчанию темы **одноцветные**: синтаксис, 16 цветов терминала,
статусы и btop — только оттенки акцента и чернил. Двойники `-color` — с разноцветным терминалом из его `alacritty/colors.toml`.

- Палитры — из его `qtile/config.py` (две заливки бара, акцент, текущий стол), `rofi/settings/launcher/*.rasi` и `dunstrc`;
  фон терминала — тёмная заливка бара, как на его скриншотах (там терминал красит pywal).
- Окна — без рамки (у qtile `border_width 0`), с мягкой тенью, как у его picom.
- fastfetch — в духе его pfetch: логотип Arch штрихами, ключи os / host / kernel / uptime / pkgs / memory.
- Обои — первыми его обои для каждой темы (`0-original`, как их ставит его `autostart_once.sh`). `build.py` копирует
  их из клона Cozytile (`COZYTILE_SRC`, по умолчанию `~/src/rice-refs/Cozytile`) или скачивает с GitHub. Дальше —
  нарисованные: сиреневое небо с крышами, ветка сакуры, травинки, туманный ельник, серая бумага (`1-cozytile`) и ровная
  заливка с зерном (`2-plain`).
- Терминал Carbon — только серые, по его `Wallpaper/e-ink.json`.
- Шрифтовой профиль: `omarchy-font-profile cozytile` (JetBrains Mono Nerd Font везде, как у его бара и терминала).

```sh
python3 build.py              # все темы
python3 build.py cozy carbon  # выбранные
```
