# Karabiner

[🇷🇺 Русский](karabiner.ru.md)

Deep keyboard customisation for macOS (Karabiner-Elements).

## Paths

- **In the repo:** `apps/karabiner`
- **Linked to:** `~/.config/karabiner` (macOS only)

## What differs from the defaults

Complex modifications:

1. **Vim-like navigation:** `Left Ctrl + h/j/k/l` and `Right Command + h/j/k/l` → arrows.
2. **Programmer layer (AltGr):** `Right Option` turns Q, W, E, R, T, Y, U, I, O, P and others into frequently used
   programming symbols.
3. **System-wide Vim mode (11 components):**
   - visual mode: select with `h j k l e b 0 ^ $ gg G { }`, then delete / copy (`d y c x`);
   - operators: `dd`, `yy`, `cc` and their combinations with motions (`de db d0 d$ dgg` …);
   - editing: `x X p P u`, `control+r` (undo/redo);
   - navigation: `h j k l` with modifiers;
   - insert mode (turns Vim mode off): `i I a A o O`;
   - Hammerspoon integration: `s`, `m`, `spacebar` open its modal modes;
   - unused keys are disabled in command mode;
   - touching the trackpad exits the mode (finger on trackpad + any key → off).
4. **More system tweaks:**
   - **Right Command** — `Escape` on a quick tap, `Command` when held;
   - `Right Command + Backspace` → forward `Delete`;
   - **Enhanced CapsLock** (Hyper / Ctrl / Esc).
