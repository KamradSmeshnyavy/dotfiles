#!/usr/bin/env python3
"""Темы yami-* — палитра yami (github.com/Trendorin/yami, MIT, © Trendorin and the yami contributors).

У yami один акцент, всё остальное выводится из него (shell/src/recolor_math.rs, derive): графит, чуть подкрашенный
оттенком акцента (bg, panel, surface), рамки и приглушённый текст — смеси панели с акцентом. Акценты — его пресеты
(px/src/theme.rs: blood, ash, sakura, amber, venom, ice, dusk). Синтаксис и статусы yami не задаёт — они подобраны
здесь приглушёнными, в тон графиту, и подогнаны по яркости до контраста 4.5 к фону. Обои — графит с точечной сеткой
и мягким светом из угла, как пиксельный фон yami. Раскладку по приложениям делает генератор тем nothing.

  python3 build.py              все темы
  python3 build.py blood ash    выбранные
"""
import colorsys
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
import build as nb  # noqa: E402

PRESETS = {
    "blood": ("Blood (yami)", "#c4161c"),
    "ash": ("Ash (yami)", "#a8a29c"),
    "sakura": ("Sakura (yami)", "#d9577c"),
    "amber": ("Amber (yami)", "#d98e1f"),
    "venom": ("Venom (yami)", "#5fae34"),
    "ice": ("Ice (yami)", "#3a9fd0"),
    "dusk": ("Dusk (yami)", "#8a5cf0"),
}
SYNTAX = {"keyword": None, "string": "#9cbf7c", "number": "#d9a05b", "type": "#d6c27a",
          "function": "#8fb3d9", "property": "#b7a2d9", "special": None, "constant": "#7fc4c4"}


def scale_v(h, k):
    r, g, b = (x / 255 for x in nb.hex2rgb(h))
    hh, s, v = colorsys.rgb_to_hsv(r, g, b)
    r, g, b = colorsys.hsv_to_rgb(hh, s, max(0, min(1, v * k)))
    return nb.rgb2hex(round(r * 255), round(g * 255), round(b * 255))


def lum(h):
    r, g, b = (x / 255 for x in nb.hex2rgb(h))
    return colorsys.rgb_to_hls(r, g, b)[1]


def readable(c, bg, need):
    """Поднять яркость до нужного контраста к тёмному фону."""
    from palettes import contrast
    for _ in range(30):
        if contrast(c, bg) >= need:
            break
        c = nb.mix(c, "#ffffff", 0.06)
    return c


def derive(accent, tint=1.0):
    """Тёмная палитра yami от акцента (recolor_math.rs, derive)."""
    bg = nb.mix("#080707", accent, 0.035 * tint)
    panel = nb.mix("#0e0c0c", accent, 0.055 * tint)
    return {
        "bg": bg, "panel": panel,
        "surface": nb.mix("#161313", accent, 0.08 * tint), "surfaceHi": nb.mix("#1f1b1b", accent, 0.12 * tint),
        "border": nb.mix(panel, accent, 0.3), "dim": nb.mix(panel, accent, 0.45),
        "accent": accent, "deep": scale_v(accent, 1 / 1.6), "glow": scale_v(accent, 1 / 1.15), "bright": scale_v(accent, 1.3),
        "selection": nb.mix(bg, accent, 0.55),
        "text": nb.mix("#ebe5e4", accent, 0.05), "textDim": nb.mix("#8c8282", accent, 0.12), "textFaint": nb.mix("#5c5252", accent, 0.1),
        "onAccent": "#0b0909" if lum(accent) > 0.6 else "#ffffff",
        "ok": "#78c878", "warn": "#ffaa28",
    }


def palette(v):
    title, accent = PRESETS[v]
    y = derive(accent)
    bg = y["bg"]
    p = {
        "mode": "dark", "title": title,
        "name": f"yami-{v}", "out": os.path.join(HERE, v),
        "bg": bg, "panel": y["panel"], "raised": y["surface"], "line": y["border"],
        "fg": y["text"], "dim": readable(y["textDim"], bg, 4.5), "comment": readable(y["textFaint"], bg, 3),
        "accent": accent, "on_accent": y["onAccent"], "selection": y["selection"],
        "error": readable("#e5484d", bg, 4.5), "info": readable(y["bright"], bg, 4.5),
        "diff_add": nb.mix(bg, "#78c878", 0.18), "diff_del": nb.mix(bg, "#e5484d", 0.18), "diff_change": nb.mix(bg, accent, 0.14),
        "min_de": 8,
    }
    syn = dict(SYNTAX, keyword=y["bright"], special=y["glow"])
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(y["warn"], bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = readable(y["ok"], bg, 4.5)
    p["wallpapers"] = lambda pp, d, y=y: dot_walls(y, d)
    p["ansi16"] = ansi16(y)
    return p


def ansi16(y):
    """16 цветов терминала как у yami (recolor_apps.rs, ansi): цвета чуть в сторону акцента, 0 — панель, 7 / 15 — текст."""
    t = lambda c: nb.mix(c, y["accent"], 0.18)
    return [y["panel"], "#d0352d", t("#78b86a"), t("#d9a03a"), t("#5a7fa8"), t("#9a5aa0"), t("#4f9a96"), y["textDim"],
            y["textFaint"], "#ff5a4c", t("#a2d692"), t("#f0c46a"), t("#86a6c8"), t("#c486c8"), t("#7cc2bc"), y["text"]]


# 闇 — знак yami 14×16 клеток (recolor_data.rs, KANJI)
KANJI = ["######..######", "#....#..#....#", "######..######", "#....#..#....#", "######..######", "#.....#......#",
         "#..########..#", "#....#..#....#", "#.##########.#", "#............#", "#...######...#", "#...#....#...#",
         "#...######...#", "#...#....#...#", "#...######.###", ".............."]


def kanji_logo(y):
    """Логотип fastfetch: 闇 полублоками, четыре полосы от яркого к глубокому акценту и тень справа-снизу (kanji_logo)."""
    def rgb(h):
        return nb.hex2rgb(h)
    bands = [y["bright"], nb.mix(y["bright"], y["accent"], 0.5), y["accent"], nb.mix(y["accent"], y["deep"], 0.5)]
    shadow = nb.mix(y["deep"], y["bg"], 0.45)
    gw, gh = len(KANJI[0]), len(KANJI)
    on = lambda x, yy: 0 <= yy < gh and 0 <= x < gw and KANJI[yy][x] == "#"
    def px(x, yy):
        if on(x, yy):
            return bands[min(3, yy * 4 // gh)]
        return shadow if on(x - 1, yy - 1) and (x >= gw or yy >= gh - 1) else None
    rows = []
    for yy in range(0, gh + 1, 2):
        line = ""
        for x in range(gw + 1):
            a, b = px(x, yy), px(x, yy + 1)
            if a is None and b is None:
                line += "\x1b[0m "
            elif b is None:
                line += "\x1b[0m\x1b[38;2;%d;%d;%dm▀" % rgb(a)
            elif a is None:
                line += "\x1b[0m\x1b[38;2;%d;%d;%dm▄" % rgb(b)
            else:
                line += "\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm▀" % (rgb(a) + rgb(b))
        rows.append(line + "\x1b[0m")
    return "\n".join(rows) + "\n"


def fastfetch_conf(y):
    """fastfetch как у yami: «YAMI // hyprland», черта, ключи акцентом, полоса палитры (recolor_apps.rs, fastfetch)."""
    import json
    e = lambda h: "38;2;%d;%d;%d" % nb.hex2rgb(h)
    esc = lambda h: "\x1b[%sm" % e(h)
    sw = "".join("\x1b[48;2;%d;%d;%dm   " % nb.hex2rgb(c) for c in
                 [y["bg"], y["panel"], y["border"], y["deep"], y["accent"], y["bright"], y["textDim"], y["text"]])
    line = esc(y["border"]) + "─" * 30
    mod = lambda typ, key, fmt=None: dict({"type": typ, "key": key}, **({"format": fmt} if fmt else {}))
    custom = lambda v: {"type": "custom", "format": v}
    conf = {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {"type": "file-raw", "source": "~/.local/state/omarchy/current/theme/apps/yami-logo.txt",
                 "padding": {"top": 1, "left": 2, "right": 4}},
        "display": {
            "separator": "  ",
            "color": {"keys": e(y["accent"]), "title": e(y["bright"]), "output": e(y["text"]), "separator": e(y["border"])},
            "key": {"width": 8},
            "bar": {"char": {"elapsed": "■", "total": "·"}, "width": 12, "border": {"left": "", "right": ""}},
            "percent": {"type": 3, "color": {"green": e(y["ok"]), "yellow": e(y["warn"]), "red": e(y["bright"])}},
        },
        "modules": [
            custom(esc(y["accent"]) + "YAMI " + esc(y["textFaint"]) + "// " + esc(y["textDim"]) + "hyprland"), custom(line),
            mod("title", "host", "{user-name}@{host-name}"), mod("os", "os", "{pretty-name}"),
            mod("wm", "wm", "{pretty-name}"), mod("shell", "shell", "{pretty-name}"),
            mod("terminal", "term", "{pretty-name}"), mod("uptime", "uptime"),
            "break", custom(sw + "\x1b[0m"),
        ],
    }
    return "// YAMI: omarchy-themes/yami/build.py по палитре темы\n" + json.dumps(conf, indent=2, ensure_ascii=False) + "\n"


def dot_walls(y, out_dir):
    """Графит с точечной сеткой (шаг 48 px, точка 3 px), свечение акцента из правого нижнего угла и водяной знак 闇
    там же — фон yami. 1-grid — со свечением, 2-dark — только сетка и знак. Перерисовываются при каждой сборке."""
    from PIL import Image, ImageDraw, ImageFilter
    os.makedirs(out_dir, exist_ok=True)
    W, H = 2880, 1800
    for name, glow in (("1-grid.png", 0.32), ("2-dark.png", 0.0)):
        im = Image.new("RGB", (W, H), nb.hex2rgb(y["bg"]))
        if glow:
            g = Image.new("L", (W // 8, H // 8), 0)
            ImageDraw.Draw(g).ellipse([W // 8 * 0.6, H // 8 * 0.5, W // 8 * 1.45, H // 8 * 1.45], fill=255)
            g = g.filter(ImageFilter.GaussianBlur(42)).resize((W, H), Image.BILINEAR)
            lit = Image.new("RGB", (W, H), nb.hex2rgb(nb.mix(y["bg"], y["deep"], glow)))
            im = Image.composite(lit, im, g)
        d = ImageDraw.Draw(im)
        dot = nb.hex2rgb(nb.mix(y["bg"], y["textFaint"], 0.55))
        for yy in range(24, H, 48):
            for xx in range(24, W, 48):
                d.rectangle([xx, yy, xx + 2, yy + 2], fill=dot)
        # водяной знак: 闇 клетками 8 px у правого нижнего угла
        c, mark = 8, nb.hex2rgb(nb.mix(y["bg"], y["deep"], 0.55))
        ox, oy = W - 120 - len(KANJI[0]) * c, H - 96 - len(KANJI) * c
        for ry, row in enumerate(KANJI):
            for rx, ch in enumerate(row):
                if ch == "#":
                    d.rectangle([ox + rx * c, oy + ry * c, ox + rx * c + c - 1, oy + ry * c + c - 1], fill=mark)
        im.save(os.path.join(out_dir, name), optimize=True)


if __name__ == "__main__":
    for v in sys.argv[1:] or list(PRESETS):
        nb.PALETTES[v] = palette(v)
        # у генератора nothing есть свой вариант ash со своими обоями — на время сборки он не мешает
        saved = nb.WALLPAPERS.pop(v, None)
        nb.build(v)
        if saved is not None:
            nb.WALLPAPERS[v] = saved
        f = os.path.join(HERE, v, "colors.toml")
        lines = open(f).read().split("\n")
        lines[0] = f"# {PRESETS[v][0]} — omarchy-themes/yami (палитра yami, MIT; сборка: build.py поверх ../nothing/build.py)."
        open(f, "w").write("\n".join(lines))
        # fastfetch и его логотип — свои, как у yami (вместо точечного «ex nihilo» генератора nothing)
        y = derive(PRESETS[v][1])
        open(os.path.join(HERE, v, "apps", "yami-logo.txt"), "w").write(kanji_logo(y))
        open(os.path.join(HERE, v, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(y))
