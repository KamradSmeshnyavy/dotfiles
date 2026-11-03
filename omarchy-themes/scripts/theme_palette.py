"""
Общие роли цветов и шрифты для генераторов тем GUI-приложений (omarchy-*-theme).

Роли берутся из colors.toml темы Omarchy; если ключа нет (старые темы с color0..15), используются
запасные ключи, а если нет и их — смесь фона и текста. Шрифты — из fontconfig (sans-serif / monospace).
"""
import colorsys
import subprocess
import tomllib
from pathlib import Path

FALLBACKS = {
    "background": ["color0"],
    "foreground": ["color7"],
    "accent": ["color4", "blue"],
    "selection": ["selection_background", "color8"],
    "red": ["color1"],
    "green": ["color2"],
    "yellow": ["color3"],
    "blue": ["color4"],
    "magenta": ["color5"],
    "cyan": ["color6"],
    "orange": ["yellow", "color3"],
}


def hex_to_rgb(c):
    c = c.lstrip("#")
    return tuple(int(c[i : i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#" + "".join(f"{round(max(0, min(1, v)) * 255):02x}" for v in rgb)


def mix(a, b, t):
    """a → b на долю t (0 — a, 1 — b)."""
    ra, rb = hex_to_rgb(a), hex_to_rgb(b)
    return rgb_to_hex(tuple(x + (y - x) * t for x, y in zip(ra, rb)))


def luminance(c):
    def ch(v):
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4

    r, g, b = (ch(v) for v in hex_to_rgb(c))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def hls(c):
    return colorsys.rgb_to_hls(*hex_to_rgb(c))


class Palette:
    """Роли: bg, bg_dark, bg_darker, surface, overlay, selection, selection_fg, fg, fg_dim, fg_muted,
    fg_bright, muted, accent, on_accent, red, green, yellow, orange, blue, magenta, cyan, dark."""

    def __init__(self, theme_dir):
        with open(Path(theme_dir) / "colors.toml", "rb") as f:
            data = tomllib.load(f)
        raw = data.get("colors", data)
        self.raw = {k: v for k, v in raw.items() if isinstance(v, str) and v.startswith("#")}

        def get(key, default=None):
            for k in [key, *FALLBACKS.get(key, [])]:
                if k in self.raw:
                    return self.raw[k][:7]
            return default

        self.bg = get("background", "#1e1e2e")
        self.fg = get("foreground", "#cdd6f4")
        mode = raw.get("mode")
        self.dark = mode != "light" if mode else luminance(self.bg) < luminance(self.fg)

        self.bg_dark = get("dark_background", mix(self.bg, "#000000" if self.dark else "#ffffff", 0.25))
        self.bg_darker = get("darker_background", mix(self.bg, "#000000" if self.dark else "#ffffff", 0.45))
        self.surface = get("lighter_background", mix(self.bg, self.fg, 0.08))
        self.selection = get("selection", mix(self.bg, self.fg, 0.18))
        self.selection_fg = get("selection_foreground", self.fg)
        self.fg_bright = get("bright_foreground", self.fg)
        self.fg_dim = get("light_foreground", mix(self.fg, self.bg, 0.25))
        self.fg_muted = get("dark_foreground", mix(self.fg, self.bg, 0.45))
        self.muted = get("muted", self.fg_muted)
        # overlay — между поверхностью и выделением (рамки, разделители)
        self.overlay = mix(self.surface, self.selection, 0.5)
        if self.overlay in (self.bg, self.surface):
            self.overlay = mix(self.bg, self.fg, 0.14)

        self.accent = get("accent", "#89b4fa")
        for name in ("red", "green", "yellow", "orange", "blue", "magenta", "cyan"):
            setattr(self, name, get(name, self.accent))
        self.on_accent = self.text_on(self.accent)

    def text_on(self, c):
        """Читаемый текст поверх цвета c: тёмный фон или яркий текст темы."""
        own = [self.bg, self.fg_bright, self.fg]
        best = max(own, key=lambda x: contrast(x, c))
        if contrast(best, c) >= 4.5:
            return best
        return max(["#000000", "#ffffff"], key=lambda x: contrast(x, c))

    def tint(self, c, t=0.18):
        """Фон, подкрашенный цветом c (пузыри сообщений, подсветка)."""
        return mix(self.bg, c, t)

    def gray(self, lightness):
        """Нейтральный тон по светлоте исходной светлой темы: 1 → фон, 0 → яркий текст."""
        stops = [
            (1.00, self.bg),
            (0.95, self.surface),
            (0.88, self.overlay),
            (0.80, self.selection),
            (0.62, self.muted),
            (0.45, self.fg_muted),
            (0.30, self.fg_dim),
            (0.14, self.fg),
            (0.00, self.fg_bright),
        ]
        # для светлой темы шкала та же: фон светлый, текст тёмный
        for (l1, c1), (l2, c2) in zip(stops, stops[1:]):
            if l2 <= lightness <= l1:
                return mix(c2, c1, (lightness - l2) / (l1 - l2) if l1 != l2 else 0)
        return stops[0][1] if lightness > 1 else stops[-1][1]

    def by_hue(self, c):
        """Цвет темы, ближайший по оттенку к c (голубой акцент Telegram/Ghidra → accent)."""
        h, _, _ = hls(c)
        deg = h * 360
        if deg < 18 or deg >= 335:
            return self.red
        if deg < 45:
            return self.orange
        if deg < 70:
            return self.yellow
        if deg < 165:
            return self.green
        if deg < 190:
            return self.cyan
        if deg < 255:
            return self.accent
        return self.magenta


def _fc(name):
    try:
        out = subprocess.run(
            ["fc-match", name, "-f", "%{family}"], capture_output=True, text=True, timeout=5
        ).stdout
        return out.split(",")[0].strip() or None
    except (OSError, subprocess.SubprocessError):
        return None


def fonts():
    """{'sans': семейство, 'mono': семейство, 'size': кегль в pt} — из fontconfig: его меняют и
    omarchy font set (monospace), и omarchy-font-profile (sans-serif и monospace)."""
    return {"sans": _fc("sans-serif") or "sans-serif", "mono": _fc("monospace") or "monospace", "size": 11}
