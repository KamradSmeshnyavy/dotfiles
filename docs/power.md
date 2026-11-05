# Battery and power notes

[🇷🇺 Русский](power.ru.md)

Measurements on the ThinkPad (OLED, 120 Hz panel) from a power-tuning session and a browser benchmark on 14 October.
All on battery, noise about ±0.3 W.

| What to do | Saving | Status |
|---|---|---|
| Dark pages and themes (OLED) | a white page vs a dark one: −1.8 W at 80 % brightness, −0.7 W at 20 % | ✅ Dark Reader, dark themes |
| kitty `cursor_trail 0` | −1.7…−2.0 W while the cursor moves a lot | ✅ off |
| 60 Hz instead of 120 on battery | −0.86 W idle, −0.54 W typing, −1…−2.7 W with video and browser animation | ❌ manual, not switched automatically |
| Brightness 40–50 % instead of 80 % | white content −0.8…−1.3 W, dark ~−0.2 W | ✅ 50 % now |
| No blur and transparency in Hyprland | not measured separately, estimated −0.3…−0.8 W while redrawing | ✅ blur off, transparency "soft" |
| `sudo tlp power-saver` | −0.3 W (CPU capped at 60 %, everything slower) | optional: for reading and nvim, not for builds |
| Firefox → Helium | at 120 Hz −1 W on video and animation; at 60 Hz only −0.5 W on video | not worth it with 60 Hz |
| Betterfox in `user.js` | 0 (within noise) | ✅ added for privacy, not battery |
| TLP, EPP=power, intel_lpmd, ASPM | already set | ✅ leave as is |
| Wi-Fi power save | ~0.1–0.3 W | ❌ keep off: the BE200 drops the connection |

For good efficiency:

1. Use 60 Hz on battery — the last big lever not yet on (an automatic 60/120 Hz switch on plug / unplug is possible).
2. Keep content dark. On OLED it matters more than brightness.
3. Don't enable things that animate the screen all the time: cursor trail, blur, shaders, animated skins. At 120 Hz each
   costs more.
4. Brightness 40–50 % indoors. Lower saves almost nothing on dark content.
5. `tlp power-saver` while reading or writing code, not while building.
6. Keep Firefox and tune Auto Tab Discard harder. Turn the VPN (amneziawg-go) on only when needed.

## Where things stand

| Scenario | At the start | Now, 120 Hz | With 60 Hz (estimate) |
|---|---|---|---|
| Desktop, only kitty | 6.5–7.3 W | 5.2 W | ~4.35 W (measured) |
| Firefox on a dark page + terminal | ~8–10 W (estimate) | 5.1–5.5 W | ~4.3–4.6 W |
| Firefox, opening sites | — | ~6.0 W | ~5–5.5 W |

The 5–6 W target with a browser, nvim and tmux is reached. With 60 Hz on battery it would be 4–5 W.
