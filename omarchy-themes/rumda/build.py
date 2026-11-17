#!/usr/bin/env python3
"""Темы rumda-* — по мотивам Rumda (github.com/hexonide/rumda; лицензии у репозитория нет — взяты цвета, облик и его обои,
код не копируется).

Палитры — из его Colors.qml (бар, дашборд, рамки) и kitty.conf: тёмная — кофейный графит с карамельным акцентом,
светлая — песок с коричневыми чернилами. По умолчанию темы одноцветные (синтаксис, 16 цветов терминала, статусы и btop —
только оттенки акцента и чернил); варианты -color — с разноцветным терминалом самого Rumda. btop — по раскладке его
rumda.theme (коричневые рамки, графики от охры через кирпич к ржавчине). fastfetch — в духе его neofetch: рамка
«┌──┐», короткие ключи os / krn / up / pkg / sh / wm, ключи акцентом; логотип — своя пиксельная мордочка кота.
Обои — сплошной цвет темы и свой пиксельный силуэт кота в углу. Раскладку по приложениям делает генератор тем nothing.

  python3 build.py                 все темы
  python3 build.py dark light      выбранные
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
import build as nb  # noqa: E402
from palettes import contrast  # noqa: E402

# Цвета Rumda (Colors.qml: backgroundColor, dashBGColor, moduleBG, borderColor, accentColor, accent2Color, errorColor;
# kitty.conf: background, foreground, selection, color0–15)
RUMDA = {
    "dark": {
        "title": "Rumda Dark", "mode": "dark",
        "bg": "#1c1612", "panel": "#2b221a", "module": "#3d2e21", "border": "#3a2d22", "frame": "#784d37",
        "fg": "#f0c997", "accent": "#c47c4f", "accent2": "#d68e60", "error": "#9a4235", "selection": "#784d37",
        "ansi": ["#20111b", "#be100e", "#858162", "#d08b30", "#426a79", "#97522c", "#989a9c", "#968c83",
                 "#5e5252", "#be100e", "#858162", "#d08b30", "#426a79", "#97522c", "#989a9c", "#f0c997"],
    },
    "light": {
        "title": "Rumda Light", "mode": "light",
        "bg": "#f5dcc6", "panel": "#f2cdac", "module": "#f0bb90", "border": "#f2bc88", "frame": "#f2bc88",
        "fg": "#4e2e1f", "accent": "#a1694d", "accent2": "#c47c4f", "error": "#9a4235", "selection": "#dba380",
        "ansi": ["#20111b", "#be100e", "#858162", "#d08b30", "#426a79", "#97522c", "#989a9c", "#968c83",
                 "#5e5252", "#be100e", "#858162", "#d08b30", "#426a79", "#97522c", "#989a9c", "#f5dcc6"],
    },
}


def readable(c, bg, need):
    dark = sum(nb.hex2rgb(bg)) < 384
    for _ in range(40):
        if contrast(c, bg) >= need:
            break
        c = nb.mix(c, "#ffffff" if dark else "#000000", 0.06)
    return c


def palette(v, color):
    t = RUMDA[v]
    bg, fg, acc = t["bg"], t["fg"], t["accent"]
    dark = t["mode"] == "dark"
    dim = nb.mix(fg, bg, 0.35)
    p = {
        "mode": t["mode"], "title": t["title"] + (" Color" if color else ""),
        "name": f"rumda-{v}" + ("-color" if color else ""), "out": os.path.join(HERE, v + ("-color" if color else "")),
        "bg": bg, "panel": t["panel"], "raised": t["module"], "line": t["border"],
        "fg": readable(fg, bg, 7), "dim": readable(dim, bg, 4.5), "comment": readable(nb.mix(fg, bg, 0.55), bg, 3),
        "accent": acc, "on_accent": bg if dark else "#fff3e6", "selection": t["selection"],
        "error": readable(t["error"], bg, 4.5), "info": readable(t["accent2"], bg, 4.5),
        "diff_add": nb.mix(bg, acc, 0.16), "diff_del": nb.mix(bg, t["error"], 0.2), "diff_change": nb.mix(bg, t["accent2"], 0.12),
        "min_de": 0,
    }
    if color:
        a = t["ansi"]
        syn = {"keyword": a[1], "string": a[2], "number": a[3], "type": t["accent2"], "function": a[4], "property": a[6],
               "special": a[5], "constant": a[3]}
        p["ansi16"] = list(a)
    else:
        # одним цветом: акцент, его светлый (accent2) и тёмный (frame / error) тона и чернила
        strong = t["accent2"] if dark else nb.mix(acc, fg, 0.35)
        syn = {"keyword": strong, "string": nb.mix(acc, fg, 0.5), "number": acc, "type": fg,
               "function": nb.mix(fg, strong, 0.3), "property": dim, "special": t["error"], "constant": nb.mix(strong, fg, 0.4)}
        g = lambda k: nb.mix(dim, fg, k)
        p["ansi16"] = [t["panel"] if dark else fg, t["error"], nb.mix(acc, fg, 0.45), acc, g(0.3), strong, g(0.6),
                       dim if dark else t["border"],
                       p["comment"], readable(t["error"], bg, 3), nb.mix(acc, fg, 0.25), t["accent2"], g(0.5), strong, g(0.8),
                       fg if dark else "#bdb3a6"]
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(t["accent2"], bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = p["string"]
    if not dark:
        p["light_mode_file"] = True
    p["wallpapers"] = lambda pp, d, t=t: walls(t, d)
    return p


# своя пиксельная мордочка кота (14 × 12 клеток): уши, глаза, нос, усы
CAT = ["#..........#.", "##........##.", "#.#......#.#.", "#..######..#.", "#...........#",
       "#..##...##..#", "#..##...##..#", "#.....#.....#", "##...###...##", "#...........#",
       ".#.........#.", "..#########.."]
# силуэт сидящего кота для обоев (16 × 18)
SIT = ["..#.....#.......", "..##...##.......", "..#######.......", ".#########......", ".##.###.##......",
       ".#########......", "..#######.......", "...#####........", "..#######.......", ".#########......",
       "###########.....", "############....", "############.##.", "############..#.", "############..#.",
       ".##########...#.", "..##....##...##.", "..##....##......"]


# его обои (pictures/): главные — первыми (0-original), варианты — следом (0r-…)
ORIGINALS = {
    "dark": [("0-original", "pictures/dark-wallpaper.png", None),
             ("0r-katana", "pictures/dark-wallpaper-original.png", None),
             ("0r-katana-archived", "pictures/dark-wallpaper-archived.png", None),
             ("0r-katana-gruv", "pictures/dark-wallpaper-gruv.png", None),
             ("0r-katana-highcontrast", "pictures/dark-wallpaper-highcontrast.png", None),
             ("0r-katana-vesper", "pictures/dark-wallpaper_vesper.png", None)],
    "light": [("0-original", "pictures/light-wallpaper.png", None),
              ("0r-warm", "pictures/wallpaper-warm.png", None)],
}


def walls(t, out_dir):
    """Обои: первыми — его (ORIGINALS), дальше свои: сплошной цвет темы (у тёмной — фон, у светлой — песок бара) и свой
    пиксельный кот в правом нижнем углу."""
    from PIL import Image, ImageDraw
    os.makedirs(out_dir, exist_ok=True)
    sys.path.insert(0, os.path.join(HERE, ".."))
    import originals
    originals.place(out_dir, "hexonide/rumda", "main", ORIGINALS[t["mode"]])
    W, H = 2880, 1800
    base = t["bg"] if t["mode"] == "dark" else "#f0c997"
    for name, cat in (("1-plain.png", True), ("2-empty.png", False)):
        im = Image.new("RGB", (W, H), nb.hex2rgb(base))
        if cat:
            d = ImageDraw.Draw(im)
            c = 14
            ox, oy = W - 200 - len(SIT[0]) * c, H - 120 - len(SIT) * c
            ink = nb.hex2rgb(nb.mix(base, t["frame"] if t["mode"] == "dark" else t["accent"], 0.75))
            for ry, row in enumerate(SIT):
                for rx, ch in enumerate(row):
                    if ch == "#":
                        d.rectangle([ox + rx * c, oy + ry * c, ox + rx * c + c - 1, oy + ry * c + c - 1], fill=ink)
        im.save(os.path.join(out_dir, name), optimize=True)


def cat_logo(t):
    """Логотип fastfetch: мордочка кота полублоками цветом акцента, глаза и нос — светлым акцентом."""
    rgb = nb.hex2rgb
    a, b = t["accent"], t["accent2"]
    gw, gh = len(CAT[0]), len(CAT)
    on = lambda x, y: 0 <= y < gh and 0 <= x < gw and CAT[y][x] == "#"
    def px(x, y):
        if not on(x, y):
            return None
        return b if 5 <= y <= 8 and 3 <= x <= 9 else a
    rows = []
    for y in range(0, gh, 2):
        line = ""
        for x in range(gw):
            u, l = px(x, y), px(x, y + 1)
            if u is None and l is None:
                line += "\x1b[0m "
            elif l is None:
                line += "\x1b[0m\x1b[38;2;%d;%d;%dm▀" % rgb(u)
            elif u is None:
                line += "\x1b[0m\x1b[38;2;%d;%d;%dm▄" % rgb(l)
            else:
                line += "\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm▀" % (rgb(u) + rgb(l))
        rows.append(line + "\x1b[0m")
    return "\n".join(rows) + "\n"


def fastfetch_conf(v, t, color):
    import json
    e = lambda h: "38;2;%d;%d;%d" % nb.hex2rgb(h)
    esc = lambda h: "\x1b[%sm" % e(h)
    key = t["ansi"][3] if color else (t["accent2"] if t["mode"] == "dark" else t["accent"])
    line = t["frame"] if t["mode"] == "dark" else t["accent"]
    sw = "".join("\x1b[38;2;%d;%d;%dm● " % nb.hex2rgb(c) for c in
                 [t["border"], t["module"], t["frame"], t["error"], t["accent"], t["accent2"], t["fg"]])
    mod = lambda typ, k, fmt=None: dict({"type": typ, "key": k}, **({"format": fmt} if fmt else {}))
    custom = lambda s: {"type": "custom", "format": s}
    conf = {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {"type": "file-raw", "source": "~/.local/state/omarchy/current/theme/apps/rumda-logo.txt",
                 "padding": {"top": 2, "left": 2, "right": 4}},
        "display": {"separator": " ", "color": {"keys": e(key), "title": e(t["accent2"]), "output": e(t["fg"])},
                    "key": {"width": 5}},
        "modules": [
            mod("title", " ", "{user-name}@{host-name}"),
            custom(esc(line) + "┌" + "─" * 29 + "┐"),
            mod("os", "os", "{name}"), mod("kernel", "krn", "{release}"), mod("uptime", "up"),
            mod("packages", "pkg"), mod("shell", "sh", "{pretty-name}"), mod("wm", "wm", "{pretty-name}"),
            custom(esc(line) + "└" + "─" * 29 + "┘"),
            custom("  " + sw + "\x1b[0m"),
        ],
    }
    return "// Rumda: omarchy-themes/rumda/build.py по палитре темы\n" + json.dumps(conf, indent=2, ensure_ascii=False) + "\n"


def btop_theme(t):
    """btop по раскладке rumda.theme: рамки и разделители — коричневые, графики от охры через кирпич к ржавчине."""
    dark = t["mode"] == "dark"
    ink = t["fg"] if dark else "#784d37"
    box = "#a87358"
    ochre, brick, rust, sand = "#d28f51", "#9a4235", "#ad704a", "#f0c997"
    th = [("main_bg", ""), ("main_fg", ink), ("title", "#a1694d" if not dark else t["accent2"]), ("hi_fg", "#a87358" if not dark else t["accent"]),
          ("selected_bg", "#dba380" if not dark else t["selection"]), ("selected_fg", "#784d37" if not dark else t["fg"]),
          ("inactive_fg", "#a1694d" if not dark else nb.mix(t["fg"], t["bg"], 0.5)), ("graph_text", ink), ("meter_bg", t["module"]),
          ("proc_misc", t["accent"]), ("cpu_box", box), ("mem_box", box), ("net_box", box), ("proc_box", box),
          ("div_line", "#784d37"), ("temp_start", ochre), ("temp_mid", brick), ("temp_end", rust), ("cpu_start", ochre),
          ("cpu_mid", brick), ("cpu_end", rust), ("free_start", sand), ("free_mid", ochre), ("free_end", rust),
          ("cached_start", brick), ("cached_mid", rust), ("cached_end", ochre), ("available_start", sand),
          ("available_mid", ochre), ("available_end", rust), ("used_start", brick), ("used_mid", "#a1694d"),
          ("used_end", "#784d37"), ("download_start", rust), ("download_mid", ochre), ("download_end", brick),
          ("upload_start", "#dba380"), ("upload_mid", ochre), ("upload_end", rust), ("process_start", ochre),
          ("process_mid", brick), ("process_end", rust)]
    return "# Rumda: omarchy-themes/rumda/build.py (раскладка его rumda.theme)\n" + "".join(f'theme[{k}]="{v}"\n' for k, v in th)


def hypr_lua(t):
    """Рамка и тень окон как у Rumda: одна рамка для активного и неактивного окна (тёмная — коричневая #784d37,
    светлая — песочная #f2bc88); у светлой — жёсткая тень 5 × 4 коричневым, у тёмной тени нет (прозрачная).
    Включает тень стиль (Customizer → hyprGeometry.shadow), здесь — только её вид.
    Двойная рамка как у Rumda — плагин borders-plus-plus (apps/hyprland/looknfeel.lua грузит его и берёт
    `omarchy_theme_borders`): за основной рамкой полоса цвета фона (тёмная — 13 px #1c1612, светлая — 11 px
    песочным) и ещё одна песочная #f5dcc6 толщиной основной."""
    dark = t["mode"] == "dark"
    frame = t["frame"].lstrip("#")
    shadow = "0x00000000" if dark else "0xaa784d37"
    band, size = ("1c1612", 13) if dark else ("f5dcc6", 11)
    return f"""-- {t['title']}: рамка и тень окон как у Rumda (omarchy-themes/rumda/build.py).
local border = "rgb({frame})"

-- двойная рамка: читает apps/hyprland/looknfeel.lua (плагин borders-plus-plus)
omarchy_theme_borders = {{
	add_borders = 2, natural_rounding = true, border_size_1 = {size}, border_size_2 = -1,
	col = {{ border_1 = "rgb({band})", border_2 = "rgb(f5dcc6)" }},
}}

hl.config({{
	general = {{ col = {{ active_border = border, inactive_border = border }} }},
	group = {{ col = {{ border_active = border, border_inactive = border }} }},
	decoration = {{
		shadow = {{ range = 7, render_power = 4, offset = "5 4", color = "{shadow}", color_inactive = "{shadow}", scale = 1.0 }},
	}},
}})
"""


def make(v, color, out=None, name=None):
    """Собрать вариант v (ключ RUMDA) — обычный или разноцветный (color) — в out (по умолчанию — каталог в репо)."""
    key = v + ("-color" if color else "")
    p = palette(v, color)
    if out:
        p["out"], p["name"] = out, name
        p.pop("wallpapers", None)  # у dynamic-* фоны — пул обоев райса (omarchy-rice-dynamic)
    nb.PALETTES[key] = p
    nb.build(key)
    t = RUMDA[v]
    out = p["out"]
    f = os.path.join(out, "colors.toml")
    lines = open(f).read().split("\n")
    lines[0] = f"# {p['title']} — omarchy-themes/rumda (по мотивам Rumda; сборка: build.py поверх ../nothing/build.py)."
    open(f, "w").write("\n".join(lines))
    open(os.path.join(out, "apps", "rumda-logo.txt"), "w").write(cat_logo(t))
    open(os.path.join(out, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(v, t, color))
    open(os.path.join(out, "btop.theme"), "w").write(btop_theme(t))
    open(os.path.join(out, "hyprland.lua"), "w").write(hypr_lua(t))

# omarchy-rice-dynamic: вариант по умолчанию, режимы вариантов, роли цветов для переворота палитры
DYNAMIC_BASE = "dark"
FLIP_ROLES = {"bg": "surface", "panel": "surface", "module": "surface", "border": "surface", "selection": "surface",
              "frame": "auto", "fg": "text", "accent": "color", "accent2": "color", "error": "color"}


def base_modes():
    return {v: t["mode"] for v, t in RUMDA.items() if v != "dynamic"}


def dynamic(s, out, name, base=DYNAMIC_BASE, scheme="wallpaper", flip=False):
    """Тема из обоев (omarchy-rice-dynamic, движок rice) в духе Rumda: карамельные ступени фона (panel → module →
    border), рамка — акцент к фону, акцент и его светлый тон. scheme accent — вариант base как есть, с обоев только
    акцент; flip — та же палитра в противоположном режиме (16 цветов терминала — от другого варианта)."""
    import dynamic_map as dm
    if scheme == "accent":
        t = dict(RUMDA[base])
        if flip:
            other = next(x for k, x in RUMDA.items() if k != "dynamic" and x["mode"] == s["mode"])
            t = dm.flip(t, FLIP_ROLES, s["mode"], "bg")
            t["mode"], t["ansi"] = s["mode"], list(other["ansi"])
        to_dark = t["mode"] == "dark"
        acc = dm.flip_color(s["accent"], "color", to_dark, t["bg"])
        t.update(accent=acc, accent2=dm.shade(acc, 0.08 if to_dark else -0.08))
    else:
        bg, fg, acc = s["bg"], s["fg"], s["accent"]
        t = {"mode": s["mode"], "bg": bg, "panel": s["panel"], "module": s["raised"], "border": s["line"],
             "frame": nb.mix(acc, bg, 0.45), "fg": fg, "accent": acc,
             "accent2": s["accent_hi"] if s["mode"] == "dark" else s["accent_lo"], "error": s["alert"],
             "selection": nb.mix(bg, acc, 0.4),
             "ansi": list(RUMDA["dark" if s["mode"] == "dark" else "light"]["ansi"])}
    t["title"] = "Rumda Dynamic"
    RUMDA["dynamic"] = t
    make("dynamic", False, out, name)


if __name__ == "__main__":
    for v in [a for a in sys.argv[1:] if not a.startswith("--")] or list(RUMDA):
        for color in (False, True):
            make(v, color)
