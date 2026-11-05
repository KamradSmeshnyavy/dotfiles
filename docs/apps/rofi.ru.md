# Rofi

[🇬🇧 English](rofi.md)

Быстрый скриптуемый лаунчер окон и приложений. **Больше не висит на Super+Space** — лаунчер теперь плагин оболочки
`kamradsmeshnyavy.menu`, а Super+Shift+T — Customizer. Rofi остался для скриптов.

## Пути

- **В репозитории:** `apps/rofi`
- **Линкуется в:** `~/.config/rofi`

## Что осталось

- Макеты в `apps/rofi/themes/` (`Layout-*.rasi`), которые импортируют цвета, сгенерированные из темы Omarchy
  (`~/.config/rofi/wallust/colors-rofi.rasi`).
- Меню для скриптов из `apps/hyprland/UserScripts/` (RofiBeats — онлайн-радио, RofiCalc — калькулятор).
- Старое комби-меню (приложения, файлы, окна, история cliphist, веб-поиск) работает через `rofi -show combi`.
