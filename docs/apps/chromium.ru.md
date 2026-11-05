# Chromium / браузеры

Краткое описание: конфиги браузеров (раньше лежали в `apps/chromium`, теперь в `apps/browser`).

## Пути
- **Исходники в репозитории:** `apps/browser`
- **Линкуются отдельными файлами** (каталог `~/.config/chromium` — профиль браузера, его не трогаем):
  - `apps/browser/chromium-flags.conf` → `~/.config/chromium-flags.conf`
  - `apps/browser/configs/helium/helium-flags.conf` → `~/.config/helium-browser-flags.conf`
  - `apps/browser/configs/tridactyl` → `~/.config/tridactyl`

## Отличия от дефолтной конфигурации и добавленные фичи
- Флаги запуска Chromium/Helium, настройки расширений (Dark Reader, Stylus, Surfingkeys, Vimium C).
- Синхронизация с темой Omarchy — см. `omarchy-themes/BROWSER-THEMING.md`.
