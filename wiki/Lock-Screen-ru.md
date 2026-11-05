[English](Lock-Screen) · **Русский**

# Экран блокировки

**23 дизайна** и по дизайну на каждый стиль для экрана блокировки Omarchy. Репозиторий:
[omarchy-lock-designs](https://github.com/KamradSmeshnyavy/omarchy-lock-designs).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-lock-designs --enable
omarchy restart shell
```

**Аутентификация не тронута:** пароль, PAM и отпечаток — стоковый сервис `omarchy.lock`, меняется только вид. Если
дизайн не загрузился или за 0,5 с не дал поле пароля, показывается стоковый экран — сломанный дизайн не запрёт вас.

Дизайны: classic, zen, dock, island, split, sheet, card, cinema, poster, editorial, analog, flip, ring, calendar,
terminal, neon, system, music, aurora, rain, constellation, dotmatrix и дизайны стилей (flat, glass, fluent, paper,
neon, neumorph, brutal, retro).

Выбор — Customizer → **Блокировка** (превью в цветах текущей темы; `p` показывает вживую без блокировки) или вручную:
`echo '{"design": "flip"}' > ~/.config/omarchy/lock-design.json`. Превью из терминала:
`omarchy-shell lock previewDesign flip`.

Lock Tweaks: 24-часовой формат, секунды, дата, размытие и затемнение обоев, без анимаций, приветствие, аватар.

Аварийный выход, если что-то сломалось при блокировке: TTY (Ctrl+Alt+F3) → `omarchy plugin enable omarchy.lock` или
`loginctl unlock-session`. Свой дизайн: [Своё](Make-Your-Own-ru#дизайн-блокировки). Справочник:
[docs](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-lock.ru.md).
