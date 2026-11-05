# Kanata

[🇷🇺 Русский](kanata.ru.md)

A cross-platform software keyboard remapper (like KMonad / Karabiner).

## Paths

- **In the repo:** `apps/kanata`
- **Linked to:** set up per OS (systemd / launchd).

## What differs from the defaults

Three layers:

1. **base**
   - **Tab (tab-mod):** tap — `Tab`, hold — the arrow layer.
   - **Right Alt / AltGr (alt-symbols):** tap — `Esc`, hold — the programmer symbols layer.
   - `Caps Lock` → `Left Ctrl`.

2. **arrow-layer** (hold `Tab`)
   - Vim navigation: `h j k l` → `Left Down Up Right`.
   - `u` → Backspace, `i` → Delete, `m` → Enter; right Alt → Delete.

3. **symbols-layer** (hold right `Alt`) — symbols without leaving the home row:
   - top row (QWERTY): `@ ( ) [ ] { } < > = | ~`
   - home row (ASDFGH): `# $ % ^ & * - _ + : "`
   - bottom row (ZXCVBN): `/ \ ? ! |`, plus `Enter`, `Backspace`
   - macros: `,` → `->`, `.` → `0x`, `/` → `!=`

Between kanata and Hyprland sits mouseless, so Hyprland binds use the `all` keyboard (see the `F19` layout switch in
`apps/hyprland/bindings.lua`).
