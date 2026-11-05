[English](Browsers) · **Русский**

# Браузеры

Firefox и Helium (на Chromium) сами следуют теме Omarchy и профилю шрифтов.

| Что | Как |
|---|---|
| **Dark Reader** | настройки пишутся из цветов темы (тёмные страницы на OLED экономят больше всего батареи) |
| **Stylus** | стили генерируются под тему, включая «DOT-MATRIX fonts»; пишутся при запуске браузера (Firefox — IndexedDB, Helium — через CDP pipe) |
| **Surfingkeys** | блок темы следует палитре и моно-шрифту |
| **Интерфейс Firefox** | сгенерированный `userChrome.css`: стоковый вид или DOT-MATRIX — в зависимости от профиля шрифтов |
| **Шрифты страниц** | из профиля шрифтов |
| **Закладки** | `just bookmarks-sync` — трёхстороннее слияние Firefox, Helium и Chromium (`-n` — только показать) |

Если браузер открыт во время смены темы, придёт уведомление «Перезапустить» — настройки пишутся, когда он закрыт.

Флаги: `apps/browser/chromium-flags.conf`, `helium-flags.conf` (overlay-скроллбары, декорации Wayland). Справочник:
[docs/apps/chromium.ru.md](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/chromium.ru.md) и
[BROWSER-THEMING](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/omarchy-themes/BROWSER-THEMING.md).
