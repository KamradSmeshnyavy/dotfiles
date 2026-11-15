#!/usr/bin/env python3
"""Темы cozytile-* — по мотивам Cozytile (github.com/Darkkal44/Cozytile; лицензии у репозитория нет — взяты только цвета
и облик, файлы и картинки не копируются).

Пять тем, как у него: Cozy (сиреневые сумерки), Sakura (розовая), Natura (тёмная трава), Everforest (туманный лес) и
светлая Carbon (серая «электронная бумага»). Палитры — из его qtile/config.py (две заливки бара, акцент, текущий стол),
rofi/settings/launcher/*.rasi (фон, текст, выбор) и dunstrc; фон терминала — тёмная заливка бара, как на его скриншотах
(у него терминал красит pywal по обоям). По умолчанию темы одноцветные (синтаксис, 16 цветов терминала, статусы, btop — оттенки
акцента и текста); варианты -color — с разноцветным терминалом из его alacritty/colors.toml. fastfetch — в духе его pfetch:
логотип Arch штрихами, ключи os / host / kernel / uptime / pkgs / memory акцентом. Обои — первыми его (0-original, см.
ORIGINAL), дальше свои, нарисованные: сиреневое небо
с облаками и крышами, розовая ветка сакуры, травинки, туманный ельник, серая бумага. Раскладку по приложениям делает
генератор тем nothing.

  python3 build.py                 все темы
  python3 build.py cozy carbon     выбранные
"""
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
import build as nb  # noqa: E402
from palettes import contrast  # noqa: E402

# bar — тёмная заливка бара (фон терминала), panel — светлая заливка бара, fg — текст rofi, accent — текст бара,
# accent2 — текущий стол, select — выбор rofi; ansi — alacritty/colors.toml (у Carbon — затемнённые для светлого фона)
ONEDARK = ["#32363D", "#E06B74", "#98C379", "#E5C07A", "#62AEEF", "#C778DD", "#55B6C2", "#ABB2BF",
           "#50545B", "#EA757E", "#A2CD83", "#EFCA84", "#6CB8F9", "#D282E7", "#5FC0CC", "#B5BCC9"]
COZY = {
    "cozy": {"title": "Cozytile Cozy", "mode": "dark", "bg": "#282738", "panel": "#353446", "fg": "#D8DEF5",
             "accent": "#CAA9E0", "accent2": "#91B1F0", "select": "#A491AD", "deep": "#4B427E", "error": "#E06B74"},
    "sakura": {"title": "Cozytile Sakura", "mode": "dark", "bg": "#282739", "panel": "#353447", "fg": "#EFE6E4",
               "accent": "#E5B9C6", "accent2": "#CFB3E5", "select": "#E6B9C6", "deep": "#AA7490", "error": "#E06B74"},
    "natura": {"title": "Cozytile Natura", "mode": "dark", "bg": "#0F1212", "panel": "#202222", "fg": "#B2BEBC",
               "accent": "#607767", "accent2": "#B2BEBC", "select": "#788E7D", "deep": "#546E6C", "error": "#C46A6A"},
    "everforest": {"title": "Cozytile Everforest", "mode": "dark", "bg": "#232A2E", "panel": "#343F44", "fg": "#BDC2BE",
                   "accent": "#86918A", "accent2": "#D3C6AA", "select": "#7D8882", "deep": "#4F5B58", "error": "#E67E80"},
    "carbon": {"title": "Cozytile Carbon", "mode": "light", "bg": "#CCCCCC", "panel": "#C2C2C2", "fg": "#474747",
               "accent": "#555555", "accent2": "#333333", "select": "#B6B6B6", "deep": "#474747", "error": "#A33A3A"},
}


def readable(c, bg, need):
    dark = sum(nb.hex2rgb(bg)) < 384
    for _ in range(40):
        if contrast(c, bg) >= need:
            break
        c = nb.mix(c, "#ffffff" if dark else "#000000", 0.06)
    return c


def palette(v, color):
    t = COZY[v]
    bg, fg, acc = t["bg"], t["fg"], t["accent"]
    dark = t["mode"] == "dark"
    dim = nb.mix(fg, bg, 0.35)
    p = {
        "mode": t["mode"], "title": t["title"] + (" Color" if color else ""),
        "name": f"cozytile-{v}" + ("-color" if color else ""), "out": os.path.join(HERE, v + ("-color" if color else "")),
        "bg": bg, "panel": t["panel"], "raised": nb.mix(t["panel"], fg, 0.08), "line": nb.mix(t["panel"], fg, 0.12),
        "fg": readable(fg, bg, 7), "dim": readable(dim, bg, 4.5), "comment": readable(nb.mix(fg, bg, 0.55), bg, 3),
        "accent": acc, "on_accent": bg, "selection": nb.mix(bg, t["select"], 0.35),
        "error": readable(t["error"], bg, 4.5), "info": readable(t["accent2"], bg, 4.5),
        "diff_add": nb.mix(bg, acc, 0.16), "diff_del": nb.mix(bg, t["error"], 0.2), "diff_change": nb.mix(bg, t["accent2"], 0.12),
        "min_de": 0,
    }
    if v == "carbon":
        # его Carbon красит терминал схемой Wallpaper/e-ink.json — только серые
        a = ["#333333", "#474747", "#666666", "#999999", "#333333", "#808080", "#AAAAAA", "#555555",
             "#222222", "#4D4D4D", "#3D3D3D", "#5C5C5C", "#1A1A1A", "#6E6E6E", "#666666", "#333333"]
        syn = {"keyword": a[4], "string": a[2], "number": a[7], "type": a[1], "function": a[12], "property": a[5],
               "special": a[9], "constant": a[10]}
        p["ansi16"] = a
    elif color:
        a = list(ONEDARK)
        syn = {"keyword": a[5], "string": a[2], "number": a[3], "type": a[3], "function": a[4], "property": a[1],
               "special": a[6], "constant": a[11]}
        p["ansi16"] = a
    else:
        a2 = t["accent2"]
        syn = {"keyword": acc, "string": nb.mix(acc, fg, 0.45), "number": a2, "type": fg,
               "function": nb.mix(fg, a2, 0.35), "property": dim, "special": t["error"], "constant": nb.mix(a2, fg, 0.4)}
        g = lambda k: nb.mix(dim, fg, k)
        p["ansi16"] = [t["panel"] if dark else fg, t["error"], nb.mix(acc, fg, 0.3), acc, a2, t["select"], g(0.6),
                       dim if dark else t["panel"],
                       p["comment"], readable(t["error"], bg, 3), nb.mix(acc, fg, 0.15), nb.mix(acc, fg, 0.5),
                       nb.mix(a2, fg, 0.3), nb.mix(t["select"], fg, 0.3), g(0.8), fg if dark else "#8A8A8A"]
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(t["accent2"], bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = p["string"]
    if not dark:
        p["light_mode_file"] = True
    p["wallpapers"] = lambda pp, d, v=v, t=t: walls(v, t, d)
    return p


# ── обои: свои рисунки ──────────────────────────────────────────────────────────────────────────────────────────────
W, H = 2880, 1800


def rgb(h):
    return nb.hex2rgb(h)


def vgrad(top, bottom, w=W, h=H):
    from PIL import Image
    im = Image.new("RGB", (1, h))
    for y in range(h):
        im.putpixel((0, y), rgb(nb.mix(top, bottom, y / (h - 1))))
    return im.resize((w, h))


def cozy_sky():
    """Сиреневые сумерки: небо от голубого к лиловому, мягкие облака, силуэты крыш и антенна."""
    from PIL import Image, ImageDraw, ImageFilter
    im = vgrad("#7f9be6", "#c9a3d9")
    rnd = random.Random(7)
    # каждый тон — свой слой, залитый этим же цветом с нулевой альфой: размытие не даёт тёмной каймы
    tones = [(172, 150, 214, 120), (216, 190, 236, 130), (244, 236, 250, 150)]
    layers = [Image.new("RGBA", (W, H), t[:3] + (0,)) for t in tones]
    draws = [ImageDraw.Draw(l) for l in layers]
    for _ in range(46):
        cx, cy = rnd.randint(-200, W + 200), rnd.randint(80, int(H * 0.62))
        for _k in range(rnd.randint(4, 9)):
            rx, ry = rnd.randint(90, 260), rnd.randint(40, 110)
            ox, oy = rnd.randint(-260, 260), rnd.randint(-50, 50)
            i = rnd.randrange(3)
            draws[i].ellipse([cx + ox - rx, cy + oy - ry, cx + ox + rx, cy + oy + ry], fill=tones[i])
    im = im.convert("RGBA")
    for l in layers:
        im = Image.alpha_composite(im, l.filter(ImageFilter.GaussianBlur(26)))
    d = ImageDraw.Draw(im)
    roof = (92, 76, 140, 255)
    x = 0
    while x < W:
        w = rnd.randint(140, 420)
        h = rnd.randint(170, 520) if not (900 < x < 1900) else rnd.randint(90, 220)
        d.rectangle([x, H - h, x + w, H], fill=roof)
        for wy in range(H - h + 30, H - 20, 46):
            for wx in range(x + 22, x + w - 30, 52):
                if rnd.random() < 0.55:
                    d.rectangle([wx, wy, wx + 22, wy + 16], fill=(120, 102, 172, 255))
        x += w + rnd.randint(0, 30)
    ax = int(W * 0.31)
    d.line([ax, H - 160, ax, int(H * 0.36)], fill=roof, width=9)
    for i, yy in enumerate(range(int(H * 0.38), int(H * 0.5), 34)):
        half = 150 - i * 22
        d.line([ax - half, yy, ax + half, yy], fill=roof, width=6)
    return im.convert("RGB")


def sakura():
    """Розовая: светлый розовый фон и своя ветка сакуры по диагонали с цветками из пяти лепестков."""
    from PIL import Image, ImageDraw, ImageFilter
    im = Image.new("RGB", (W, H), rgb("#f4c6c4"))
    d = ImageDraw.Draw(im)
    rnd = random.Random(3)
    pts = [(int(W * 0.12 + i * W * 0.0085), int(H * 0.08 + i * H * 0.0075 + 40 * math.sin(i / 9))) for i in range(100)]
    d.line(pts, fill=rgb("#3e2c3a"), width=46, joint="curve")
    d.line(pts, fill=rgb("#6b4d60"), width=14, joint="curve")
    for k in range(5):
        i0 = 15 + k * 17
        x0, y0 = pts[i0]
        side = 1 if k % 2 else -1
        b = [(x0 + j * 16, y0 + side * j * 11 - j * 4) for j in range(22)]
        d.line(b, fill=rgb("#3e2c3a"), width=18, joint="curve")
    flowers = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    f = ImageDraw.Draw(flowers)
    for _ in range(150):
        i = rnd.randint(5, 98)
        x, y = pts[i]
        x += rnd.randint(-260, 260)
        y += rnd.randint(-220, 220)
        r = rnd.randint(18, 40)
        tone = rnd.choice(["#fbe4ea", "#f7cfd9", "#f2b6c6", "#fff2f4"])
        for a in range(5):
            ang = a * 2 * math.pi / 5 + rnd.random()
            px, py = x + math.cos(ang) * r * 0.75, y + math.sin(ang) * r * 0.75
            f.ellipse([px - r * 0.62, py - r * 0.62, px + r * 0.62, py + r * 0.62], fill=rgb(tone) + (240,))
        f.ellipse([x - r * 0.28, y - r * 0.28, x + r * 0.28, y + r * 0.28], fill=rgb("#e6a03c") + (255,))
    shadow = flowers.filter(ImageFilter.GaussianBlur(6))
    im = im.convert("RGBA")
    im.alpha_composite(Image.new("RGBA", (W, H), (0, 0, 0, 0)))
    im = Image.alpha_composite(im, Image.eval(shadow, lambda c: c // 5))
    im = Image.alpha_composite(im, flowers)
    for _ in range(40):
        x, y, r = rnd.randint(0, W), rnd.randint(0, H), rnd.randint(8, 16)
        ImageDraw.Draw(im).ellipse([x - r, y - r * 0.6, x + r, y + r * 0.6], fill=rgb("#f9d9e0") + (200,))
    return im.convert("RGB")


def natura():
    """Тёмная трава: длинные изогнутые травинки разных зелёных на почти чёрном, ближние — светлее и резче."""
    from PIL import Image, ImageDraw, ImageFilter
    im = vgrad("#0c1110", "#151c1a").convert("RGBA")
    rnd = random.Random(11)
    for layer, (blur, tone, n) in enumerate([(14, "#1f2b26", 40), (6, "#34473d", 34), (0, "#607767", 22)]):
        lay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        d = ImageDraw.Draw(lay)
        for _ in range(n):
            x0 = rnd.randint(-200, W + 200)
            lean = rnd.uniform(-0.9, 0.9)
            top = rnd.randint(-300, int(H * 0.5))
            w0 = rnd.randint(40, 110) if layer == 2 else rnd.randint(30, 80)
            pts_l, pts_r = [], []
            steps = 40
            for s in range(steps + 1):
                k = s / steps
                y = H + 50 - k * (H + 50 - top)
                x = x0 + lean * (k ** 2) * 900
                wd = w0 * (1 - k) + 2
                pts_l.append((x - wd / 2, y))
                pts_r.append((x + wd / 2, y))
            c = rgb(nb.mix(tone, "#b2bebc", rnd.uniform(0, 0.25)))
            d.polygon(pts_l + pts_r[::-1], fill=c + (255,))
            d.line([(a[0] + (b[0] - a[0]) * 0.35, a[1]) for a, b in zip(pts_l, pts_r)], fill=rgb(nb.mix(tone, "#dfe6e3", 0.3)) + (120,), width=3)
        if blur:
            lay = lay.filter(ImageFilter.GaussianBlur(blur))
        im = Image.alpha_composite(im, lay)
    return im.convert("RGB")


def everforest():
    """Туманный ельник: слои ёлок на склонах, к переднему плану темнее, между слоями — полосы тумана."""
    from PIL import Image, ImageDraw, ImageFilter
    im = vgrad("#9aa4a1", "#5f6b67").convert("RGBA")
    rnd = random.Random(5)
    for i in range(5):
        lay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        d = ImageDraw.Draw(lay)
        k = i / 4
        tone = rgb(nb.mix("#7b8784", "#1c2422", k))
        base = int(H * (0.38 + 0.13 * i))
        slope = lambda x: base + 160 * math.sin(x / W * math.pi * (1.3 + i * 0.4) + i) - (300 - i * 60) * (x / W)
        x = -60
        while x < W + 60:
            h = rnd.randint(int(120 + 70 * i), int(220 + 110 * i))
            w = h * rnd.uniform(0.32, 0.42)
            y = slope(x)
            d.polygon([(x, y - h), (x - w / 2, y + 10), (x + w / 2, y + 10)], fill=tone + (255,))
            x += w * rnd.uniform(0.35, 0.6)
        d.polygon([(0, H)] + [(x, slope(x)) for x in range(0, W + 1, 20)] + [(W, H)], fill=tone + (255,))
        im = Image.alpha_composite(im, lay.filter(ImageFilter.GaussianBlur(max(0, 4 - i))))
        fog = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(fog).rectangle([0, base - 260, W, base + 120], fill=(200, 208, 205, 70))
        im = Image.alpha_composite(im, fog.filter(ImageFilter.GaussianBlur(120)))
    return im.convert("RGB")


def carbon():
    """Серая «электронная бумага»: светло-серый фон с мелким зерном и едва заметной сеткой строк."""
    from PIL import Image, ImageChops, ImageDraw
    im = Image.new("RGB", (W, H), rgb("#c9c9c9"))
    d = ImageDraw.Draw(im)
    for y in range(0, H, 48):
        d.line([0, y, W, y], fill=rgb("#c3c3c3"), width=1)
    grain = Image.effect_noise((W, H), 18).convert("RGB")
    return ImageChops.blend(im, ImageChops.overlay(im, grain), 0.35)


# его обои по темам (qtile/autostart_once.sh, `wal -i ~/Wallpaper/…`): build.py берёт их из клона Cozytile
# (COZYTILE_SRC, по умолчанию ~/src/rice-refs/Cozytile) или скачивает с GitHub и кладёт файлом 0-original.* первым в
# backgrounds/ — тема по умолчанию встаёт на его обои.
ORIGINAL = {"cozy": "Aesthetic2.png", "sakura": "120_-_KnFPX73.jpg", "natura": "claudio-testa-FrlCwXwbwkk-unsplash.jpg",
            "everforest": "fog_forest_2.png", "carbon": "a_road_going_through_a_desert.jpeg"}


def original(v):
    """Его обои для темы v: путь к файлу в клоне Cozytile или скачанному во временную папку; None — если взять неоткуда."""
    import tempfile
    import urllib.parse
    import urllib.request
    name = ORIGINAL[v]
    src = os.path.join(os.environ.get("COZYTILE_SRC", os.path.expanduser("~/src/rice-refs/Cozytile")), "Wallpaper", name)
    if os.path.isfile(src):
        return src
    dst = os.path.join(tempfile.mkdtemp(prefix="cozytile-"), name)
    try:
        url = "https://raw.githubusercontent.com/Darkkal44/Cozytile/main/Wallpaper/" + urllib.parse.quote(name)
        with urllib.request.urlopen(url, timeout=60) as r, open(dst, "wb") as f:
            f.write(r.read())
        return dst
    except Exception as e:  # noqa: BLE001
        print(f"  {v}: оригинальные обои не получены ({e}) — только свои", file=sys.stderr)
        return None


PAINT = {"cozy": cozy_sky, "sakura": sakura, "natura": natura, "everforest": everforest, "carbon": carbon}


def walls(v, t, out_dir):
    from PIL import Image, ImageChops
    os.makedirs(out_dir, exist_ok=True)
    import shutil
    target = None
    for ext in (".png", ".jpg", ".jpeg"):
        if os.path.isfile(os.path.join(out_dir, "0-original" + ext)):
            target = os.path.join(out_dir, "0-original" + ext)
    if target is None or os.path.islink(target):
        orig = original(v)
        if orig:
            dst = os.path.join(out_dir, "0-original" + os.path.splitext(orig)[1])
            if os.path.lexists(dst):
                os.unlink(dst)
            shutil.copyfile(orig, dst)
    PAINT[v]().save(os.path.join(out_dir, "1-cozytile.jpg"), quality=88, optimize=True)
    plain = Image.new("RGB", (W, H), rgb(t["panel"] if t["mode"] == "dark" else t["bg"]))
    grain = Image.effect_noise((W, H), 16).convert("RGB")
    ImageChops.blend(plain, ImageChops.overlay(plain, grain), 0.25).save(os.path.join(out_dir, "2-plain.jpg"), quality=88, optimize=True)


# ── fastfetch в духе его pfetch ───────────────────────────────────────────────────────────────────────────────────────
LOGO = [
    "        /\\",
    "       /  \\",
    "      / /\\ \\",
    "     / /  \\ \\",
    "    / /    \\ \\",
    "   / / ____ \\ \\",
    "  /_/ `----.\\_\\",
]


def logo(t):
    c = "\x1b[38;2;%d;%d;%dm" % rgb(t["accent"])
    return "\n".join(c + l + "\x1b[0m" for l in LOGO) + "\n"


def fastfetch_conf(t, color):
    import json
    e = lambda h: "38;2;%d;%d;%d" % rgb(h)
    key = t["accent2"] if not color else ONEDARK[4]
    mod = lambda typ, k, fmt=None: dict({"type": typ, "key": k}, **({"format": fmt} if fmt else {}))
    conf = {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {"type": "file-raw", "source": "~/.local/state/omarchy/current/theme/apps/cozytile-logo.txt",
                 "padding": {"top": 0, "left": 2, "right": 6}},
        "display": {"separator": " ", "color": {"keys": e(key), "title": e(t["accent"]), "output": e(t["fg"])},
                    "key": {"width": 8}},
        "modules": [
            mod("title", " ", "{user-name}@{host-name}"),
            mod("os", "os", "{name}"), mod("host", "host", "{name}"), mod("kernel", "kernel", "{release}"),
            mod("uptime", "uptime"), mod("packages", "pkgs", "{all}"), mod("memory", "memory", "{used} / {total}"),
        ],
    }
    return "// Cozytile: omarchy-themes/cozytile/build.py по палитре темы\n" + json.dumps(conf, indent=2, ensure_ascii=False) + "\n"


def btop_theme(t, color):
    """btop: рамки — светлая заливка бара, графики — от тёмного акцента через акцент к свету (у -color — радуга OneDark)."""
    fg, acc, a2 = t["fg"], t["accent"], t["accent2"]
    box = nb.mix(t["panel"], fg, 0.25)
    lo, mid, hi = (ONEDARK[2], ONEDARK[3], ONEDARK[1]) if color else (t["deep"], acc, a2)
    th = [("main_bg", ""), ("main_fg", fg), ("title", acc), ("hi_fg", a2), ("selected_bg", t["panel"]),
          ("selected_fg", acc), ("inactive_fg", nb.mix(fg, t["bg"], 0.55)), ("graph_text", nb.mix(fg, t["bg"], 0.3)),
          ("meter_bg", t["panel"]), ("proc_misc", a2), ("cpu_box", box), ("mem_box", box), ("net_box", box),
          ("proc_box", box), ("div_line", box)]
    for name in ("temp", "cpu", "free", "cached", "available", "used", "download", "upload", "process"):
        th += [(name + "_start", lo), (name + "_mid", mid), (name + "_end", hi)]
    return "# Cozytile: omarchy-themes/cozytile/build.py\n" + "".join(f'theme[{k}]="{v}"\n' for k, v in th)


def hypr_lua(t):
    """Окна как у Cozytile (qtile border_width 0, picom): без рамки — рамка цветом фона, мягкая тень 15 со сдвигом."""
    return f"""-- {t['title']}: окна без рамки и с мягкой тенью, как у Cozytile (omarchy-themes/cozytile/build.py).
local border = "rgb({t['bg'].lstrip('#')})"
hl.config({{
	general = {{ col = {{ active_border = border, inactive_border = border }} }},
	group = {{ col = {{ border_active = border, border_inactive = border }} }},
	decoration = {{ shadow = {{ range = 15, render_power = 3, offset = "-4 6", color = "rgba(00000080)", color_inactive = "rgba(00000060)" }} }},
}})
"""


if __name__ == "__main__":
    for v in [a for a in sys.argv[1:] if not a.startswith("--")] or list(COZY):
        for color in (False, True):
            key = v + ("-color" if color else "")
            nb.PALETTES[key] = palette(v, color)
            nb.build(key)
            t = COZY[v]
            out = os.path.join(HERE, key)
            f = os.path.join(out, "colors.toml")
            lines = open(f).read().split("\n")
            lines[0] = f"# {nb.PALETTES[key]['title']} — omarchy-themes/cozytile (по мотивам Cozytile; сборка: build.py поверх ../nothing/build.py)."
            open(f, "w").write("\n".join(lines))
            open(os.path.join(out, "apps", "cozytile-logo.txt"), "w").write(logo(t))
            open(os.path.join(out, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(t, color))
            open(os.path.join(out, "btop.theme"), "w").write(btop_theme(t, color))
            open(os.path.join(out, "hyprland.lua"), "w").write(hypr_lua(t))
