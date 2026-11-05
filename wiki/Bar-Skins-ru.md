[English](Bar-Skins) · **Русский**

# Скины бара

Верхний бар: **24 скина**, **10 раскладок**, компактный режим и десятки стилей рабочих столов. Репозиторий:
[omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-bar-skins --enable
omarchy restart shell
```

## Выбрать скин

Customizer → **Бар** → Bar Skin. Активный скин — `~/.config/omarchy/bar-skin.json`; бар следит за файлом и меняется на
лету. Формы: `full` (сток), `floating`, `pill`, `islands`, `notch`, `underline`, `hug` (вогнутые углы), `frame` (бар и
рамка вокруг всего экрана, окна внутри). Скины: stock, floating, pill, islands, capsules, glass, hover-glass, frame,
hug, notch, underline, minimal, soft, brutal, bevel, neon, paper, dotmatrix, solid-accent, window-icons, compact-focus,
autohide и другие.

## Настроить

Bar Tweaks — 41 параметр по разделам (Форма и размер, Цвета, Модули, Эффекты, Workspaces, Compact): `h`/`l` меняют,
`x` сбрасывает, `i` — ввести значение, у каждой строки подписано значение по умолчанию. Цвет — роль темы (`accent`,
`muted`…), любой ключ `colors.toml` темы или `#hex`; роли перекрашиваются вместе с темой.

## Рабочие столы

Подписи: числа, в кружках, римские, кандзи, греческие, кириллица, Брайль, точки, LED и другие (`wsLabelStyle`); иконки
окон внутри стола (`wsWindowIcons`, стили color / mono / tinted / glyph / letter / dots / count…); плашка акцента под
активным.

## Компактный режим

Бар сжимается, когда стол занимает одно тайловое окно (или только при полноэкранном, или всегда), и разворачивается по
наведению — пресет `compact-focus`.

## Раскладки и виджеты бара

Bar Layout — положение (сверху / снизу / слева / справа) и какие виджеты в какой секции; Виджеты бара — двигать виджет
`h` / `l`, убрать `x`, вернуть из «Не на баре». Свой скин или раскладку — «💾 Сохранить…» (★ в списке).

Вернуть стоковый бар: `omarchy plugin enable omarchy.bar`. Справочник: [docs](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-bar.ru.md).
