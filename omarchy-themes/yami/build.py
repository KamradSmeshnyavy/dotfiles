#!/usr/bin/env python3
"""Темы yami-* — палитра yami (github.com/Trendorin/yami, MIT, © Trendorin and the yami contributors).

У yami один акцент, всё остальное выводится из него (shell/src/recolor_math.rs, derive): графит, чуть подкрашенный
оттенком акцента (bg, panel, surface), рамки и приглушённый текст — смеси панели с акцентом. Акценты — его пресеты
(px/src/theme.rs: blood, ash, sakura, amber, venom, ice, dusk). Синтаксис и статусы yami не задаёт — они подобраны
здесь приглушёнными, в тон графиту, и подогнаны по яркости до контраста 4.5 к фону. Обои — графит с точечной сеткой
и мягким светом из угла, как пиксельный фон yami. Раскладку по приложениям делает генератор тем nothing.

  python3 build.py              все темы
  python3 build.py blood ash    выбранные
  python3 build.py --color      разноцветный синтаксис и терминал (как ansi у yami); по умолчанию — одноцветно

По умолчанию темы одноцветные, как сам yami на снимках (btop, fastfetch): синтаксис, 16 цветов терминала и статусы —
только оттенки акцента и серого графита; btop — ровно как пишет yami (recolor_apps.rs, btop).
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
    """Поднять яркость до нужного контраста к тёмному фону (к светлому — затемнить: dynamic, перевёрнутая yami)."""
    from palettes import contrast
    toward = "#000000" if lum(bg) > 0.5 else "#ffffff"
    for _ in range(30):
        if contrast(c, bg) >= need:
            break
        c = nb.mix(c, toward, 0.06)
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


COLOR = "--color" in sys.argv


def mono_syntax(y):
    """Синтаксис в оттенках акцента и графита: ключевые слова и константы — яркий акцент, строки — акцент к тексту,
    числа — glow, типы и функции — текст, свойства — приглушённый текст, особое — сам акцент."""
    return {"keyword": y["bright"], "string": nb.mix(y["accent"], y["text"], 0.62), "number": y["glow"],
            "type": y["text"], "function": nb.mix(y["text"], y["bright"], 0.25), "property": y["textDim"],
            "special": y["accent"], "constant": nb.mix(y["bright"], y["text"], 0.45)}


# готовые палитры yami (dynamic: от акцента обоев, возможно перевёрнутые в светлую) — вместо derive(PRESETS[v][1])
DERIVED = {}


def yami_of(v):
    return DERIVED.get(v) or derive(PRESETS[v][1])


def palette(v):
    title, accent = PRESETS[v]
    y = yami_of(v)
    accent = y["accent"]
    bg = y["bg"]
    p = {
        "mode": y.get("mode", "dark"), "title": title,
        "name": f"yami-{v}", "out": os.path.join(HERE, v),
        "bg": bg, "panel": y["panel"], "raised": y["surface"], "line": y["border"],
        "fg": y["text"], "dim": readable(y["textDim"], bg, 4.5), "comment": readable(y["textFaint"], bg, 3),
        "accent": accent, "on_accent": y["onAccent"], "selection": y["selection"],
        "error": readable("#e5484d", bg, 4.5), "info": readable(y["bright"], bg, 4.5),
        "diff_add": nb.mix(bg, "#78c878", 0.18), "diff_del": nb.mix(bg, "#e5484d", 0.18), "diff_change": nb.mix(bg, accent, 0.14),
        "min_de": 8,
    }
    syn = dict(SYNTAX, keyword=y["bright"], special=y["glow"]) if COLOR else mono_syntax(y)
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(y["warn"] if COLOR else y["glow"], bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = readable(y["ok"] if COLOR else nb.mix(y["accent"], y["text"], 0.45), bg, 4.5)
    if not COLOR:
        # одним цветом роли ближе друг к другу, чем требует генератор для разноцветных тем
        p["min_de"] = 0
        p["error"] = readable(y["bright"], bg, 4.5)
        p["info"] = readable(y["textDim"], bg, 4.5)
        p["diff_add"] = nb.mix(bg, y["text"], 0.12)
        p["diff_del"] = nb.mix(bg, y["accent"], 0.22)
    if p["mode"] == "light":
        p["light_mode_file"] = True
    p["wallpapers"] = lambda pp, d, y=y: dot_walls(y, d)
    p["ansi16"] = ansi16(y) if COLOR else ansi16_mono(y)
    return p


def ansi16(y):
    """16 цветов терминала как у yami (recolor_apps.rs, ansi): цвета чуть в сторону акцента, 0 — панель, 7 / 15 — текст."""
    t = lambda c: nb.mix(c, y["accent"], 0.18)
    return [y["panel"], "#d0352d", t("#78b86a"), t("#d9a03a"), t("#5a7fa8"), t("#9a5aa0"), t("#4f9a96"), y["textDim"],
            y["textFaint"], "#ff5a4c", t("#a2d692"), t("#f0c46a"), t("#86a6c8"), t("#c486c8"), t("#7cc2bc"), y["text"]]


def ansi16_mono(y):
    """16 цветов терминала одним цветом: красный — акцент, «зелёный» — акцент к тексту, «жёлтый» — glow, синий и голубой —
    серые тона, пурпурный — deep к яркому; яркие варианты светлее. Так ls, git, btop и подсветка не дают фиолетового и
    зелёного, а остаются в палитре fastfetch."""
    a, t, d, f = y["accent"], y["text"], y["textDim"], y["textFaint"]
    base = [y["panel"], a, nb.mix(a, t, 0.45), y["glow"], nb.mix(d, a, 0.15), nb.mix(y["deep"], y["bright"], 0.5), nb.mix(d, t, 0.35), d]
    lift = [f, y["bright"], nb.mix(a, t, 0.65), nb.mix(y["glow"], t, 0.35), nb.mix(d, t, 0.45), y["bright"], nb.mix(d, t, 0.6), t]
    return base + lift


def btop_theme(y):
    """btop как у yami (recolor_apps.rs, btop): рамки — border, графики от deep через акцент к яркому."""
    acc, deep, bright, border = y["accent"], y["deep"], y["bright"], y["border"]
    m1, m2, m3 = nb.mix(y["textFaint"], acc, 0.5), nb.mix(deep, y["textDim"], 0.5), nb.mix(acc, y["text"], 0.3)
    th = [("main_bg", y["bg"]), ("main_fg", y["text"]), ("title", y["text"]), ("hi_fg", bright), ("selected_bg", deep),
          ("selected_fg", "#ffffff"), ("inactive_fg", y["textFaint"]), ("graph_text", y["textDim"]), ("meter_bg", y["surfaceHi"]),
          ("proc_misc", acc), ("cpu_box", border), ("mem_box", border), ("net_box", border), ("proc_box", border),
          ("div_line", border), ("temp_start", m1), ("temp_mid", acc), ("temp_end", bright), ("cpu_start", deep),
          ("cpu_mid", acc), ("cpu_end", bright), ("free_start", border), ("free_mid", deep), ("free_end", acc),
          ("cached_start", border), ("cached_mid", m2), ("cached_end", y["textDim"]), ("available_start", border),
          ("available_mid", deep), ("available_end", acc), ("used_start", deep), ("used_mid", acc), ("used_end", bright),
          ("download_start", border), ("download_mid", deep), ("download_end", acc), ("upload_start", border),
          ("upload_mid", m3), ("upload_end", y["text"]), ("process_start", deep), ("process_mid", acc), ("process_end", bright)]
    return "# YAMI: omarchy-themes/yami/build.py по палитре темы (как recolor_apps.rs, btop)\n" + "".join(f'theme[{k}]="{v}"\n' for k, v in th)


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


def make(v, out=None, name=None):
    """Собрать пресет v (ключ PRESETS) в out (по умолчанию — каталог в репо)."""
    p = palette(v)
    if out:
        p["out"], p["name"] = out, name
        p.pop("wallpapers", None)  # у dynamic-* фоны — пул обоев райса (omarchy-rice-dynamic)
    nb.PALETTES[v] = p
    # у генератора nothing есть свой вариант ash со своими обоями — на время сборки он не мешает
    saved = nb.WALLPAPERS.pop(v, None)
    nb.build(v)
    if saved is not None:
        nb.WALLPAPERS[v] = saved
    out = p["out"]
    f = os.path.join(out, "colors.toml")
    lines = open(f).read().split("\n")
    lines[0] = f"# {PRESETS[v][0]} — omarchy-themes/yami (палитра yami, MIT; сборка: build.py поверх ../nothing/build.py)."
    open(f, "w").write("\n".join(lines))
    # fastfetch и его логотип — свои, как у yami (вместо точечного «ex nihilo» генератора nothing)
    y = yami_of(v)
    open(os.path.join(out, "apps", "yami-logo.txt"), "w").write(kanji_logo(y))
    open(os.path.join(out, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(y))
    open(os.path.join(out, "btop.theme"), "w").write(btop_theme(y))


# omarchy-rice-dynamic: yami весь строится от одного акцента (derive) и всегда тёмный; светлая — переворот палитры
DYNAMIC_BASE = "blood"
DYNAMIC_MODE = "dark"
FLIP_ROLES = {"bg": "surface", "panel": "surface", "surface": "surface", "surfaceHi": "surface", "border": "surface",
              "dim": "surface", "selection": "surface", "text": "text", "textDim": "text", "textFaint": "text",
              "deep": "color", "glow": "color", "bright": "color", "ok": "color", "warn": "color"}


def base_modes():
    return {v: "dark" for v in PRESETS if v != "dynamic"}


def dynamic(s, out, name, base=DYNAMIC_BASE, scheme="wallpaper", flip=False):
    """Тема из обоев (omarchy-rice-dynamic, движок rice) по-yami: вся палитра — derive от акцента обоев (родной
    алгоритм yami, recolor_math.rs); режимы задают сам акцент (тише, ярче, моно, серый). Светлая (dark / light явно или
    flip в режиме accent) — та же палитра, перевёрнутая: фоны светлые, текст тёмный, акцент — до контраста."""
    import dynamic_map as dm
    y = derive(s["accent"])
    if s["mode"] == "light":
        y = dm.flip(y, FLIP_ROLES, "light", "bg")
        y["accent"] = dm.flip_color(y["accent"], "color", False, y["bg"])
        y["onAccent"] = "#0b0909" if lum(y["accent"]) > 0.6 else "#ffffff"
        y["mode"] = "light"
    PRESETS["dynamic"] = ("Dynamic (yami)", y["accent"])
    DERIVED["dynamic"] = y
    make("dynamic", out, name)


if __name__ == "__main__":
    for v in [a for a in sys.argv[1:] if not a.startswith("--")] or list(PRESETS):
        make(v)
