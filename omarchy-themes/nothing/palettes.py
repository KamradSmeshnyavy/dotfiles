"""Палитры темы nothing: три варианта, одинаковые роли.

Роли интерфейса (bg … accent) и роли контента (синтаксис, ANSI, статусы) задаются здесь и только здесь;
build.py раскладывает их по приложениям. Проверка: python3 palettes.py.
"""

PALETTES = {
    # glyph-rice (github.com/Nebelung-cloud/glyph-rice): интерфейс — их серая шкала #000 → #F2F2F2 и красный Nothing
    # (красный — только «живое»: ключевые слова, ошибки), синтаксис — оттенки серого. Пастель — ТОЛЬКО терминалу,
    # их 16 ANSI как есть (у них в Theme.qml: «пастель только терминалу»). Цвета — данные, раскладка — build.py.
    "glyph-dark": {
        "mode": "dark",
        "title": "Glyph Dark (glyph-rice)",
        "bg": "#000000", "panel": "#0e0e0e", "raised": "#1a1a1a", "line": "#2a2a2a",
        "fg": "#f2f2f2", "dim": "#8c8c8c", "comment": "#6e6e6e",
        "accent": "#d71921", "on_accent": "#ffffff", "selection": "#2e0c0e",
        "keyword": "#f0434b", "string": "#a6a6a6", "number": "#d0d0d0", "type": "#e4e4e4",
        "function": "#f2f2f2", "property": "#bababa", "special": "#ff8a90", "constant": "#c4c4c4",
        "error": "#f0434b", "warn": "#e4e4e4", "info": "#bababa", "hint": "#a6a6a6", "ok": "#f2f2f2",
        "diff_add": "#1a1a1a", "diff_del": "#2e0c0e", "diff_change": "#141414",
        "ansi16": ["#0e0e0e", "#d71921", "#9bb59a", "#d9c38a", "#8ea3c2", "#b79bc2", "#8fb8b8", "#c9c9c9", "#4a4a4a", "#f0434b", "#b5ccb4", "#e8d6a8", "#aabbd4", "#cdb6d6", "#abcdcd", "#f2f2f2"],
        "min_de": 1,
    },
    # glyph-rice, светлая шкала #E9E9E9 → #0B0B0B; ANSI — их же, переставленные для светлой (как в их Theme.qml).
    "glyph-light": {
        "mode": "light",
        "title": "Glyph Light (glyph-rice)",
        "light_mode_file": True,
        "bg": "#e9e9e9", "panel": "#f1f1f1", "raised": "#ffffff", "line": "#d9d9d9",
        "fg": "#0b0b0b", "dim": "#4a4a4a", "comment": "#6e6e6e",
        "accent": "#d71921", "on_accent": "#ffffff", "selection": "#f3cfd1",
        "keyword": "#b3121a", "string": "#4a4a4a", "number": "#2e2e2e", "type": "#1c1c1c",
        "function": "#0b0b0b", "property": "#3a3a3a", "special": "#8a0f15", "constant": "#404040",
        "error": "#b3121a", "warn": "#1c1c1c", "info": "#3a3a3a", "hint": "#4a4a4a", "ok": "#0b0b0b",
        "diff_add": "#d9d9d9", "diff_del": "#f3cfd1", "diff_change": "#e1e1e1",
        "ansi16": ["#f2f2f2", "#d71921", "#9bb59a", "#d9c38a", "#8ea3c2", "#b79bc2", "#8fb8b8", "#4a4a4a", "#c9c9c9", "#f0434b", "#b5ccb4", "#e8d6a8", "#aabbd4", "#cdb6d6", "#abcdcd", "#0e0e0e"],
        "min_de": 1,
    },
    # Тёплый графит CMF by Nothing, сигнал — оранжевый.
    "cmf": {
        "mode": "dark",
        "title": "Nothing CMF",
        "bg": "#0d0b09",
        "panel": "#141210",
        "raised": "#221e1a",
        "line": "#332d27",
        "fg": "#ece4da",
        "dim": "#b3a99e",
        "comment": "#7a7065",
        "accent": "#ff6b1a",
        "on_accent": "#0d0b09",
        "selection": "#3d2414",
        "keyword": "#ff8a4c",
        "string": "#b5cc7a",
        "number": "#f7c35f",
        "type": "#e8a7c8",
        "ansi_yellow": "#f7c35f",   # типы здесь розовые — жёлтый ANSI берём янтарный
        "function": "#7fbfd4",
        "property": "#9fd1bd",
        "special": "#c9a2f0",
        "constant": "#ffd9a6",
        "error": "#ff5a4f",
        "warn": "#f7c35f",
        "info": "#7fbfd4",
        "hint": "#9fd1bd",
        "ok": "#b5cc7a",
        "diff_add": "#1e2614",
        "diff_del": "#3a1a14",
        "diff_change": "#162530",
    },
    # Светлая, как белый Nothing Phone: тёмные насыщенные тона на светлом.
    "glyph": {
        "mode": "light",
        "title": "Nothing Glyph White",
        "bg": "#f4f4f2",
        "panel": "#e9e9e6",
        "raised": "#ffffff",
        "line": "#d4d4d0",
        "fg": "#111111",
        "dim": "#4a4a48",
        "comment": "#7c7c78",
        "accent": "#d71921",
        "on_accent": "#ffffff",
        "selection": "#f6d4d5",
        "keyword": "#c8102e",
        "string": "#2f7a1f",
        "number": "#a65200",
        "type": "#7d6200",
        "function": "#1f5fa8",
        "property": "#0b6e78",
        "special": "#7a35a8",
        "constant": "#9e2a5e",
        "error": "#c41e24",
        "warn": "#a65200",
        "info": "#1f5fa8",
        "hint": "#0b6e78",
        "ok": "#2f7a1f",
        "diff_add": "#dcefd6",
        "diff_del": "#f6d4d5",
        "diff_change": "#d6e4f4",
    },

    # ── Тональные варианты: один-два основных цвета и их оттенки; роли различаются ещё и начертанием
    # (tonal = True: ключевые слова жирные, типы курсивом). Порог различимости ниже — min_de.
    # Red / Ash: красный Nothing и серые разной теплоты.
    "ash": {
        "mode": "dark", "tonal": True, "min_de": 8,
        "title": "Nothing Ash",
        "bg": "#000000", "panel": "#0b0b0b", "raised": "#1a1a1a", "line": "#2a2a2a",
        "fg": "#d6d3cf", "dim": "#9c9894", "comment": "#686664",
        "accent": "#d71921", "on_accent": "#ffffff", "selection": "#3a1214",
        "keyword": "#ff4d55", "type": "#ff8a8a", "number": "#ffb8b3", "constant": "#f2d6d3",
        "function": "#ffffff", "string": "#b9b0a6", "property": "#a3a8ad", "special": "#e8636b",
        "error": "#ff4d55", "warn": "#ff8a8a", "info": "#d6d3cf", "hint": "#a3a8ad", "ok": "#f2f0ed",
        "ansi_yellow": "#ffb8b3",
        "diff_add": "#1d1d1d", "diff_del": "#3a1214", "diff_change": "#26201f",
    },
    # Ember: оранжевый CMF и песочные / янтарные оттенки.
    "ember": {
        "mode": "dark", "tonal": True, "min_de": 8,
        "title": "Nothing Ember",
        "bg": "#0d0b09", "panel": "#141210", "raised": "#221e1a", "line": "#332d27",
        "fg": "#e3d9cc", "dim": "#a99d90", "comment": "#766b60",
        "accent": "#ff6b1a", "on_accent": "#0d0b09", "selection": "#3d2414",
        "keyword": "#ff7a2e", "type": "#ffab78", "number": "#ffc94f", "constant": "#ffe0b0",
        "function": "#fff4e6", "string": "#d4bb98", "property": "#b9a68e", "special": "#ff9450",
        "error": "#ff4a3d", "warn": "#ffc94f", "info": "#d4bb98", "hint": "#b9a68e", "ok": "#f0e6d8",
        "ansi_yellow": "#ffc94f",
        "diff_add": "#242018", "diff_del": "#3a1a14", "diff_change": "#2b2218",
    },
    # Signal + Steel: два цвета — красная семья (ключевые слова, типы, числа) и холодная сталь
    # (строки, функции, свойства).
    "steel": {
        "mode": "dark", "tonal": True, "min_de": 8,
        "title": "Nothing Steel",
        "bg": "#000000", "panel": "#0a0c0e", "raised": "#171b1f", "line": "#262c32",
        "fg": "#dde3e8", "dim": "#97a1aa", "comment": "#5f6a74",
        "accent": "#d71921", "on_accent": "#ffffff", "selection": "#1d2a36",
        "keyword": "#ff4d55", "type": "#ff8a8a", "number": "#ffb8b3", "constant": "#f2d6d3",
        "function": "#d2e6f6", "string": "#93b6d2", "property": "#7d9cb5", "special": "#b8cfe2",
        "error": "#ff4d55", "warn": "#ffb8b3", "info": "#93b6d2", "hint": "#7d9cb5", "ok": "#d2e6f6",
        "ansi_yellow": "#ffb8b3",
        "diff_add": "#14202b", "diff_del": "#3a1214", "diff_change": "#1a2430",
    },
    # Светлый Red / Ash: тёмно-красные и угольные тона на белом.
    "ashlight": {
        "mode": "light", "tonal": True, "min_de": 8,
        "title": "Nothing Ash Light",
        "bg": "#f4f4f2", "panel": "#e9e9e6", "raised": "#ffffff", "line": "#d4d4d0",
        "fg": "#262524", "dim": "#4f4d4b", "comment": "#86837f",
        "accent": "#d71921", "on_accent": "#ffffff", "selection": "#f6d4d5",
        "keyword": "#c8102e", "type": "#9b1c2c", "number": "#b33a4c", "constant": "#7c2a35",
        "function": "#000000", "string": "#5e574f", "property": "#44505a", "special": "#c4283f",
        "error": "#c41e24", "warn": "#b33a4c", "info": "#44505a", "hint": "#5e574f", "ok": "#1a1a1a",
        "ansi_yellow": "#b33a4c",
        "diff_add": "#e4e4e0", "diff_del": "#f6d4d5", "diff_change": "#ebe2e2",
    },
}

SYNTAX = ["keyword", "string", "number", "type", "function", "property", "special", "constant"]


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def luminance(h):
    def ch(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (ch(c) for c in rgb(h))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def lab(h):
    def ch(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (ch(c) for c in rgb(h))
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x), f(y), f(z)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def delta_e(a, b):
    return sum((p - q) ** 2 for p, q in zip(lab(a), lab(b))) ** 0.5


def check(name, p):
    problems = []
    for role in SYNTAX + ["fg", "error", "warn", "dim"]:
        c = contrast(p[role], p["bg"])
        if c < 4.5:
            problems.append(f"{role} contrast {c:.2f} < 4.5")
    c = contrast(p["comment"], p["bg"])
    if c < 3:
        problems.append(f"comment contrast {c:.2f} < 3")
    for i, a in enumerate(SYNTAX):
        for b in SYNTAX[i + 1:]:
            d = delta_e(p[a], p[b])
            if d < p.get("min_de", 15):
                problems.append(f"{a}/{b} ΔE {d:.1f} < {p.get('min_de', 15)}")
    return problems


if __name__ == "__main__":
    for name, p in PALETTES.items():
        probs = check(name, p)
        print(f"{name}: {'ok' if not probs else '; '.join(probs)}")
        print("   " + "  ".join(f"{r}={contrast(p[r], p['bg']):.1f}" for r in SYNTAX + ["comment"]))
