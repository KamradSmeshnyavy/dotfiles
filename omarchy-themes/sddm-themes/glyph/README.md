# glyph — тема входа SDDM из glyph-rice

Перенесена без изменений из [glyph-rice](https://github.com/Nebelung-cloud/glyph-rice) (`config/sddm/glyph`,
© Nebelung-cloud): выбор сеанса «диском камеры», тахометр, заполняющийся при вводе пароля, поэтапное включение.
**Лицензия этого каталога — GPL-3.0** (`LICENSE`), шрифты Doto / Space Grotesk / Space Mono — SIL OFL 1.1
(`fonts/OFL.txt`); остальные dotfiles — MIT.

Поставить (sudo, копия в `/usr/share/sddm/themes/glyph`): `omarchy-lock-themes sddm glyph`.
Посмотреть без выхода из сеанса: `omarchy-lock-themes sddm-test glyph`. Вернуть вход Omarchy: `omarchy-lock-themes sddm reset`.
