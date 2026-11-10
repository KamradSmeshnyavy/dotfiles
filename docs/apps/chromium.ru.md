# Chromium / браузеры

[🇬🇧 English](chromium.md)

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

## Перевод видео (Voice Over Translation)

Закадровый перевод видео в Firefox, как в Яндекс Браузере: расширение
[Voice Over Translation](https://github.com/ilyhalight/voice-over-translation), установленное с
[AMO](https://addons.mozilla.org/ru/firefox/addon/voice-over-translation/). Это официальная сборка, на неё
ссылается README репозитория. Расширение выбрано вместо userscript, потому что его проверяет и подписывает
Mozilla и оно само обновляется.
Работает через API перевода Яндекса и поддерживает YouTube, VK, Twitch, Rutube, Coursera, Udemy, X и другие сайты.

- Ставится вручную, как и остальные расширения: в репозитории ничего нет.
- В меню VOT на плеере: язык перевода — русский, громкость оригинала ~15–20 %.
- Сайтам, на которых переводишь видео, нужно разрешить автовоспроизведение аудио и видео («Настройки → Приватность и
  защита → Разрешения → Автовоспроизведение»), иначе расширение выдаёт ошибки.
- Видео длиннее 4 часов не переводятся (ограничение API). Ссылки на видео уходят в Яндекс.
