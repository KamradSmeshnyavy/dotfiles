#!/usr/bin/env python3
"""Темы vitreus-* — палитры тем Vitreus (github.com/natepayn3/Vitreus, themes/*.toml, MIT, © natepayn3).

У Vitreus в теме одиннадцать цветов интерфейса (ink, faint, mint — акцент, mintlo / minthi, onmint, tint — фон, panel,
deep, off, alert); раскладку по приложениям делает генератор тем nothing (../nothing/build.py). Синтаксис и статусы
Vitreus не задаёт — они подобраны здесь в тон каждой теме и подогнаны по яркости до контраста 4.5 к фону (комментарии —
3), чтобы код читался. Обои — мягкие «жидкие» пятна цветов темы (у Vitreus их нет: Glass берёт цвета с обоев — это
тема dynamic, остальные рисуют фон сами).

  python3 build.py            все темы
  python3 build.py retro uwu  выбранные
  python3 build.py --color    разноцветный синтаксис и терминал (как было); по умолчанию — одноцветно

По умолчанию темы одноцветные: синтаксис, 16 цветов терминала, статусы и btop — только оттенки mint (акцента) и чернил
темы (ink, faint, off), без чужих зелёных и фиолетовых. Сам Vitreus терминал, btop и fastfetch не красит (у него свой
терминал во вкладке Desk), поэтому они сделаны здесь в его цветах; fastfetch — «VITREUS // тема», полая стеклянная V
полублоками от minthi к mintlo и полоса палитры темы.
"""
import colorsys
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
import build as nb  # noqa: E402
from palettes import contrast  # noqa: E402

# Цвета Vitreus как есть (themes/<имя>.toml, [palette]) и подобранный к ним синтаксис.
VITREUS = {
    "retro": {
        "title": "Retro (Vitreus)", "mode": "light",
        "ink": "#2b2833", "faint": "#6a665a", "mint": "#e63a3a", "mintlo": "#a8242b", "minthi": "#ff7b5c",
        "onmint": "#fff3dc", "tint": "#d6d0bd", "panel": "#bfb9a5", "deep": "#2b2833", "off": "#a39e8e", "alert": "#d81b60",
        "syntax": {"keyword": "#a8242b", "string": "#3f6e2e", "number": "#a0501a", "type": "#7a5a00",
                   "function": "#2c5a8c", "property": "#5b3f8c", "special": "#d81b60", "constant": "#2b6a6a"},
    },
    "uwu": {
        "title": "UwU (Vitreus)", "mode": "light",
        "ink": "#3a2a8c", "faint": "#7a6ad0", "mint": "#ff3d9a", "mintlo": "#d61f7c", "minthi": "#ff7cc0",
        "onmint": "#ffffff", "tint": "#e9e2ff", "panel": "#d4c8ff", "deep": "#271a5e", "off": "#cfc6f2", "alert": "#ff3d6e",
        "syntax": {"keyword": "#d61f7c", "string": "#1f7a5c", "number": "#b0560a", "type": "#8a6a00",
                   "function": "#2a56c6", "property": "#8a2fb8", "special": "#c2185b", "constant": "#1f6f8a"},
    },
    "cyber": {
        "title": "Cyber (Vitreus)", "mode": "dark",
        "ink": "#d6f7ff", "faint": "#6f93a8", "mint": "#00e5ff", "mintlo": "#00a9c4", "minthi": "#7df3ff",
        "onmint": "#001018", "tint": "#04070d", "panel": "#0a1220", "deep": "#ff2bd6", "off": "#26384a", "alert": "#ff3b5c",
        "syntax": {"keyword": "#ff2bd6", "string": "#7dffb0", "number": "#ff9f43", "type": "#ffd166",
                   "function": "#5ab0ff", "property": "#b9a3ff", "special": "#c3ff5c", "constant": "#7df3ff"},
    },
    "milk": {
        "title": "Milkbox (Vitreus)", "mode": "light",
        "ink": "#6c7390", "faint": "#9aa1b8", "mint": "#7f8cff", "mintlo": "#6672e6", "minthi": "#aab3ff",
        "onmint": "#ffffff", "tint": "#e0e5ee", "panel": "#e6eaf2", "deep": "#a3acc2", "off": "#d3d9e5", "alert": "#ee6a86",
        "syntax": {"keyword": "#5a64d6", "string": "#3f7d5e", "number": "#a0602a", "type": "#8a6a10",
                   "function": "#2f6fae", "property": "#8a4fb0", "special": "#c2405e", "constant": "#2f7a80"},
    },
    "doodle": {
        "title": "Doodle (Vitreus)", "mode": "light",
        "ink": "#22202e", "faint": "#6b6577", "mint": "#e0457b", "mintlo": "#c22f63", "minthi": "#f7a8c4",
        "onmint": "#fffdf6", "tint": "#fbf5e8", "panel": "#fffdf6", "deep": "#fcd34d", "off": "#ebe3d2", "alert": "#e5484d",
        "syntax": {"keyword": "#c22f63", "string": "#2f7a3a", "number": "#b0540a", "type": "#8a6a00",
                   "function": "#2a5bb0", "property": "#6a3fa0", "special": "#d0342c", "constant": "#1f6f7a"},
    },
    "paper": {
        "title": "Paper (Vitreus)", "mode": "light",
        "ink": "#3b3631", "faint": "#857b6c", "mint": "#6a90c9", "mintlo": "#4f76b0", "minthi": "#a9c1e6",
        "onmint": "#fffaf0", "tint": "#efe4cd", "panel": "#f6eedd", "deep": "#5a4d3d", "off": "#d9cbae", "alert": "#d9594f",
        "syntax": {"keyword": "#4f76b0", "string": "#5a7a32", "number": "#a0521e", "type": "#7a6420",
                   "function": "#1f6a70", "property": "#7a4f8a", "special": "#b8433a", "constant": "#4a5a2a"},
    },
    "proxy": {
        "title": "Proxy (Vitreus)", "mode": "dark",
        "ink": "#f2f6f8", "faint": "#93a1ac", "mint": "#ffd21f", "mintlo": "#d9a400", "minthi": "#fff07a",
        "onmint": "#0b0d10", "tint": "#10161d", "panel": "#121920", "deep": "#2a8cff", "off": "#2a323b", "alert": "#ff4d6d",
        "syntax": {"keyword": "#ffd21f", "string": "#8ee07a", "number": "#ff7a3d", "type": "#e8b04a",
                   "function": "#5aa9ff", "property": "#c3a6ff", "special": "#ff4d6d", "constant": "#7fdce0"},
    },
}


def hls(h):
    r, g, b = nb.hex2rgb(h)
    return colorsys.rgb_to_hls(r / 255, g / 255, b / 255)


def from_hls(h, l, s):
    r, g, b = colorsys.hls_to_rgb(h, max(0, min(1, l)), s)
    return nb.rgb2hex(round(r * 255), round(g * 255), round(b * 255))


def readable(c, bg, need):
    """Сдвинуть яркость цвета от фона, пока контраст не станет need: тот же тон и насыщенность."""
    h, l, s = hls(c)
    dark_bg = hls(bg)[1] < 0.5
    for _ in range(100):
        if contrast(c, bg) >= need:
            return c
        l += 0.01 if dark_bg else -0.01
        c = from_hls(h, l, s)
    return c


COLOR = "--color" in sys.argv


def mono_syntax(t, bg):
    """Синтаксис оттенками акцента и чернил: ключевые слова — mintlo / minthi (что читается на фоне), строки — акцент к
    чернилам, числа — сам акцент, типы — чернила, функции — чернила к акценту, свойства — faint, особое — alert."""
    dark = t["mode"] == "dark"
    strong = t["minthi"] if dark else t["mintlo"]
    return {"keyword": strong, "string": nb.mix(t["mint"], t["ink"], 0.5), "number": t["mint"], "type": t["ink"],
            "function": nb.mix(t["ink"], strong, 0.35), "property": t["faint"], "special": t["alert"],
            "constant": nb.mix(strong, t["ink"], 0.4)}


def ansi16_mono(t, p):
    """16 цветов терминала одним цветом: красный — alert, «зелёный» — акцент к чернилам, «жёлтый» — акцент, синий и
    голубой — тона чернил, пурпурный — mintlo / minthi; 0 / 8 / 7 / 15 — фон, faint и чернила (как у тёмной или светлой)."""
    dark = t["mode"] == "dark"
    ink, faint, mint = t["ink"], t["faint"], t["mint"]
    strong = t["minthi"] if dark else t["mintlo"]
    soft = t["mintlo"] if dark else t["minthi"]
    black = t["off"] if dark else ink
    white = faint if dark else t["off"]
    base = [black, p["error"], nb.mix(mint, ink, 0.45), mint, nb.mix(faint, mint, 0.2), strong, nb.mix(faint, ink, 0.4), white]
    lift = [p["comment"], t["alert"], nb.mix(mint, ink, 0.25), soft, nb.mix(faint, ink, 0.2), soft, nb.mix(faint, ink, 0.6),
            "#ffffff" if dark else "#bdbdb8"]
    return base + lift


def btop_theme(t):
    """btop в цветах темы: рамки — off, графики от mintlo через mint к minthi, как у btop yami."""
    dark = t["mode"] == "dark"
    acc, lo, hi, line = t["mint"], t["mintlo"], t["minthi"], t["off"]
    deep, bright = (lo, hi) if dark else (hi, lo)
    th = [("main_bg", t["tint"]), ("main_fg", t["ink"]), ("title", t["ink"]), ("hi_fg", bright), ("selected_bg", acc),
          ("selected_fg", t["onmint"]), ("inactive_fg", t["faint"]), ("graph_text", t["faint"]), ("meter_bg", t["panel"]),
          ("proc_misc", acc), ("cpu_box", line), ("mem_box", line), ("net_box", line), ("proc_box", line), ("div_line", line),
          ("temp_start", deep), ("temp_mid", acc), ("temp_end", t["alert"]), ("cpu_start", deep), ("cpu_mid", acc),
          ("cpu_end", bright), ("free_start", line), ("free_mid", deep), ("free_end", acc), ("cached_start", line),
          ("cached_mid", nb.mix(deep, t["faint"], 0.5)), ("cached_end", t["faint"]), ("available_start", line),
          ("available_mid", deep), ("available_end", acc), ("used_start", deep), ("used_mid", acc), ("used_end", bright),
          ("download_start", line), ("download_mid", deep), ("download_end", acc), ("upload_start", line),
          ("upload_mid", nb.mix(acc, t["ink"], 0.3)), ("upload_end", t["ink"]), ("process_start", deep), ("process_mid", acc),
          ("process_end", bright)]
    return "# Vitreus: omarchy-themes/vitreus/build.py по палитре темы\n" + "".join(f'theme[{k}]="{v}"\n' for k, v in th)


# полая «стеклянная» V, как буква с баннера Vitreus (14 × 14 клеток)
VEE = ["###........###", "#.#........#.#", "#..#......#..#", "#..#......#..#", ".#..#....#..#.", ".#..#....#..#.",
       "..#..#..#..#..", "..#..#..#..#..", "...#..##..#...", "...#......#...", "....#....#....", "....#....#....",
       ".....#..#.....", "......##......"]


def vee_logo(t):
    """Логотип fastfetch: V полублоками, четыре полосы от minthi через mint к mintlo, тень цвета off справа-снизу."""
    rgb = nb.hex2rgb
    bands = [t["minthi"], nb.mix(t["minthi"], t["mint"], 0.5), t["mint"], t["mintlo"]]
    shadow = t["off"]
    gw, gh = len(VEE[0]), len(VEE)
    on = lambda x, y: 0 <= y < gh and 0 <= x < gw and VEE[y][x] == "#"
    def px(x, y):
        if on(x, y):
            return bands[min(3, y * 4 // gh)]
        return shadow if on(x - 1, y - 1) else None
    rows = []
    for y in range(0, gh + 1, 2):
        line = ""
        for x in range(gw + 1):
            a, b = px(x, y), px(x, y + 1)
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


def fastfetch_conf(v, t):
    """fastfetch Vitreus: «VITREUS // тема», черта цвета off, ключи акцентом, полоса из одиннадцати цветов темы."""
    import json
    e = lambda h: "38;2;%d;%d;%d" % nb.hex2rgb(h)
    esc = lambda h: "\x1b[%sm" % e(h)
    order = ["tint", "panel", "off", "deep", "mintlo", "mint", "minthi", "alert", "faint", "ink"]
    sw = "".join("\x1b[48;2;%d;%d;%dm   " % nb.hex2rgb(t[k]) for k in order)
    key = t["minthi"] if t["mode"] == "dark" else t["mintlo"]
    mod = lambda typ, k, fmt=None: dict({"type": typ, "key": k}, **({"format": fmt} if fmt else {}))
    custom = lambda s: {"type": "custom", "format": s}
    conf = {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {"type": "file-raw", "source": "~/.local/state/omarchy/current/theme/apps/vitreus-logo.txt",
                 "padding": {"top": 1, "left": 2, "right": 4}},
        "display": {
            "separator": "  ",
            "color": {"keys": e(key), "title": e(t["mint"]), "output": e(t["ink"]), "separator": e(t["off"])},
            "key": {"width": 8},
            "bar": {"char": {"elapsed": "■", "total": "·"}, "width": 12, "border": {"left": "", "right": ""}},
            "percent": {"type": 3, "color": {"green": e(t["mint"]), "yellow": e(key), "red": e(t["alert"])}},
        },
        "modules": [
            custom(esc(t["mint"]) + "VITREUS " + esc(t["faint"]) + "// " + esc(t["ink"]) + t["title"].split(" (")[0].lower()),
            custom(esc(t["off"]) + "─" * 30),
            mod("title", "host", "{user-name}@{host-name}"), mod("os", "os", "{pretty-name}"),
            mod("wm", "wm", "{pretty-name}"), mod("shell", "shell", "{pretty-name}"),
            mod("terminal", "term", "{pretty-name}"), mod("uptime", "uptime"),
            "break", custom(sw + "\x1b[0m"),
        ],
    }
    return "// Vitreus: omarchy-themes/vitreus/build.py по палитре темы\n" + json.dumps(conf, indent=2, ensure_ascii=False) + "\n"


def palette(v):
    t = VITREUS[v]
    bg, fg = t["tint"], t["ink"]
    dark = t["mode"] == "dark"
    p = {
        "mode": t["mode"], "title": t["title"],
        "name": f"vitreus-{v}", "out": os.path.join(HERE, v),
        "bg": bg, "panel": t["panel"], "raised": nb.mix(t["panel"], fg, 0.08), "line": t["off"],
        "fg": readable(fg, bg, 7), "dim": readable(t["faint"], bg, 4.5), "comment": readable(t["faint"], bg, 3),
        "accent": t["mint"], "on_accent": t["onmint"], "selection": nb.mix(bg, t["mint"], 0.28),
        "error": readable(t["alert"], bg, 4.5), "info": readable(t["mintlo"] if not dark else t["minthi"], bg, 4.5),
        "diff_add": nb.mix(bg, "#3fae5a", 0.18), "diff_del": nb.mix(bg, t["alert"], 0.18), "diff_change": nb.mix(bg, t["mint"], 0.14),
        "min_de": 8,
    }
    syn = t["syntax"] if COLOR else mono_syntax(t, bg)
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    if not COLOR:
        p["min_de"] = 0
        p["diff_add"] = nb.mix(bg, t["mint"], 0.18)
    # слоты ANSI = роли (yellow — типы): жёлтым терминалу даём числа, они тёплые у всех тем
    p["ansi_yellow"] = p["number"]
    p["warn"] = p["number"]
    p["hint"] = p["dim"]
    p["ok"] = p["string"]
    if not dark:
        p["light_mode_file"] = True
    p["wallpapers"] = lambda pp, d, t=t: liquid_walls(t, d)
    if not COLOR:
        p["ansi16"] = ansi16_mono(t, p)
    return p


def liquid_walls(t, out_dir):
    """Два фона «жидкого стекла»: мягкие пятна акцента и deep на фоне темы — стеклу есть что размывать."""
    from PIL import Image, ImageDraw, ImageFilter
    os.makedirs(out_dir, exist_ok=True)
    layouts = {
        "1-liquid.png": [("mint", 0.22, 0.30, 0.34), ("deep", 0.78, 0.70, 0.30), ("minthi", 0.62, 0.18, 0.20), ("panel", 0.30, 0.82, 0.28)],
        "2-drift.png": [("deep", 0.18, 0.75, 0.36), ("mint", 0.70, 0.35, 0.30), ("alert", 0.92, 0.88, 0.16), ("mintlo", 0.40, 0.10, 0.18)],
    }
    w, h = 320, 200
    for name, blobs in layouts.items():
        dst = os.path.join(out_dir, name)
        if os.path.exists(dst):
            continue
        im = Image.new("RGB", (w, h), nb.hex2rgb(t["tint"]))
        d = ImageDraw.Draw(im)
        for role, cx, cy, r in blobs:
            col = nb.mix(t["tint"], t[role], 0.75)
            R = r * w
            d.ellipse([cx * w - R, cy * h - R, cx * w + R, cy * h + R], fill=nb.hex2rgb(col))
        im = im.filter(ImageFilter.GaussianBlur(28)).resize((2880, 1800), Image.LANCZOS)
        im.save(dst, optimize=True)


if __name__ == "__main__":
    for v in [a for a in sys.argv[1:] if not a.startswith("--")] or list(VITREUS):
        nb.PALETTES[v] = palette(v)
        nb.build(v)
        # шапка colors.toml генератора называет nothing — здесь своя
        f = os.path.join(HERE, v, "colors.toml")
        lines = open(f).read().split("\n")
        lines[0] = f"# {VITREUS[v]['title']} — omarchy-themes/vitreus (палитра Vitreus, MIT; сборка: build.py поверх ../nothing/build.py)."
        open(f, "w").write("\n".join(lines))
        # fastfetch, его логотип и btop — свои, в цветах темы (вместо точечного «ex nihilo» генератора nothing)
        t = VITREUS[v]
        open(os.path.join(HERE, v, "apps", "vitreus-logo.txt"), "w").write(vee_logo(t))
        open(os.path.join(HERE, v, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(v, t))
        if not COLOR:
            open(os.path.join(HERE, v, "btop.theme"), "w").write(btop_theme(t))
