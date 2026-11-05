# Ghidra

[🇬🇧 English](ghidra.md)

Тема для фреймворка реверс-инжиниринга Ghidra, которая следует теме Omarchy.

## Пути

- **В репозитории:** `apps/ghidra`
- **Генерируется:** `omarchy-themes/scripts/omarchy-ghidra-theme <каталог темы> <выходной .theme>` собирает `.theme` из
  `colors.toml` темы и текущих шрифтов (`fonts.json` / fontconfig); `omarchy-app-themes` запускает его при каждой смене
  темы или шрифтов. В Ghidra тему один раз импортировать в настройках тем.

## Что задаёт

- Системные цвета FlatLaf на тёмной основе (`Flat Dark`, `useDarkDefaults = true`).
- Цвета листинга, декомпилятора (выделение переменных, поиск, пути, узлы source/sink), закладок, обзора, ByteViewer и
  Code Compare, текущей строки, графов P-кода.
- `font.standard` / `font.monospaced` — из профиля шрифтов.
