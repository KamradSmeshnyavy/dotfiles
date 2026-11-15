#!/usr/bin/env python3
"""Темы bruteon-* — по мотивам Bruteon (github.com/Darkkal44/Bruteon, «Neo-Brutalism inspired rice»; в репозитории пока
только три скриншота — всё взято с них, код свой; лицензия GPL-3.0).

Необрутализм на тёплой бумаге: кремовые карточки #f5ebe6 на фоне #efe0d6, толстый тёмный контур #161110 и жёсткая тень
без размытия, пастельные акценты — персик, лосось, зелёный, розовый, лаванда, голубой. Цвета сняты с его скриншотов.
По умолчанию тема одноцветная (синтаксис, 16 цветов терминала, btop — оттенки коричневого и персика); вариант -color —
с пастельной радугой его терминала (кружки fastfetch, cava). fastfetch — как у него: пилюли «ARCH LINUX» и «HYPRLAND»,
строки «значок · ключ › значение», внизу — пастельные пилюли цветов. Окна — рамка 3 px цветом контура и жёсткая тень
6 × 6 (decoration.shadow.sharp). Обои — свои: мягкий градиент от голубого неба к персиковому закату и крему, как у него.

  python3 build.py
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
import build as nb  # noqa: E402
from palettes import contrast  # noqa: E402

T = {
    "title": "Bruteon", "mode": "light",
    "bg": "#efe0d6", "card": "#f5ebe6", "title_bar": "#e3c0a5", "ink": "#161110", "muted": "#885643", "brown": "#6b3b05",
    "peach": "#ffb77a", "salmon": "#ffb3a1", "red": "#ff8a80", "rose": "#ffb4ab", "green": "#c5e1a5", "olive": "#c3cb97",
    "pink": "#ffcbd5", "lavender": "#c2c3e9", "blue": "#90caf9", "teal": "#87aeaa", "yellow": "#f2c16a", "purple": "#b478c8",
}
PASTEL = ["peach", "green", "pink", "lavender", "blue", "salmon"]


def readable(c, bg, need):
    for _ in range(40):
        if contrast(c, bg) >= need:
            break
        c = nb.mix(c, "#000000", 0.06)
    return c


def palette(color):
    t = T
    bg, fg = t["bg"], t["ink"]
    acc = t["peach"]
    dim = t["muted"]
    p = {
        "mode": "light", "title": t["title"] + (" Color" if color else ""),
        "name": "bruteon-light" + ("-color" if color else ""), "out": os.path.join(HERE, "light" + ("-color" if color else "")),
        "bg": bg, "panel": t["card"], "raised": t["title_bar"], "line": nb.mix(bg, fg, 0.25),
        "fg": fg, "dim": readable(dim, bg, 4.5), "comment": readable(nb.mix(dim, bg, 0.3), bg, 3),
        "accent": acc, "on_accent": fg, "selection": nb.mix(bg, acc, 0.55),
        "error": readable("#c0473b", bg, 4.5), "info": readable("#3f7cb3", bg, 4.5),
        "diff_add": nb.mix(bg, t["green"], 0.5), "diff_del": nb.mix(bg, t["red"], 0.45), "diff_change": nb.mix(bg, t["blue"], 0.4),
        "min_de": 0, "light_mode_file": True,
    }
    if color:
        # его пастель, затемнённая до читаемости на кремовом
        dk = lambda k, n=4.5: readable(t[k], bg, n)
        a = [fg, dk("red"), dk("green"), dk("yellow"), dk("blue"), dk("purple"), dk("teal"), t["muted"],
             nb.mix(fg, bg, 0.4), dk("salmon"), dk("olive"), dk("peach"), dk("lavender"), dk("pink"), dk("teal", 3), nb.mix(fg, bg, 0.2)]
        syn = {"keyword": a[5], "string": a[2], "number": a[11], "type": a[3], "function": a[4], "property": a[1],
               "special": a[6], "constant": a[9]}
        p["ansi16"] = a
    else:
        br, mu = t["brown"], t["muted"]
        syn = {"keyword": br, "string": nb.mix(mu, acc, 0.35), "number": readable(acc, bg, 3.5), "type": fg,
               "function": nb.mix(fg, br, 0.5), "property": mu, "special": "#c0473b", "constant": nb.mix(br, acc, 0.4)}
        g = lambda k: nb.mix(mu, fg, k)
        p["ansi16"] = [fg, "#c0473b", nb.mix(br, mu, 0.5), readable(acc, bg, 3), br, mu, g(0.4), nb.mix(fg, bg, 0.5),
                       nb.mix(fg, bg, 0.35), "#c0473b", nb.mix(br, acc, 0.3), readable(t["salmon"], bg, 3), g(0.2), g(0.6), g(0.8), fg]
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(acc, bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = p["string"]
    p["wallpapers"] = lambda pp, d: walls(d)
    return p


def walls(out_dir):
    """Мягкий закат, как на его скриншотах: голубое небо слева сверху, персиковое пятно справа, кремовый низ; лёгкое зерно."""
    from PIL import Image, ImageChops, ImageFilter
    os.makedirs(out_dir, exist_ok=True)
    W, H = 2880, 1800
    sw, sh = 288, 180
    sky, peach, cream, rose = nb.hex2rgb("#a7b9d1"), nb.hex2rgb("#f4b896"), nb.hex2rgb("#f7e4d6"), nb.hex2rgb("#e8b9ad")
    im = Image.new("RGB", (sw, sh))
    px = im.load()
    for y in range(sh):
        for x in range(sw):
            u, v = x / sw, y / sh
            ks = max(0.0, 1 - math.hypot(u * 1.1, v * 1.6))            # небо из левого верхнего угла
            kp = max(0.0, 1 - math.hypot((u - 0.72) * 1.4, (v - 0.32) * 1.9))  # персиковое пятно
            kc = min(1.0, max(0.0, (v - 0.45) * 1.9))                 # кремовый низ
            c = [rose[i] * 0.6 + cream[i] * 0.4 for i in range(3)]
            c = [c[i] + (peach[i] - c[i]) * min(1, kp * 1.3) for i in range(3)]
            c = [c[i] + (sky[i] - c[i]) * min(1, ks * 1.5) for i in range(3)]
            c = [c[i] + (cream[i] - c[i]) * kc for i in range(3)]
            px[x, y] = tuple(int(v) for v in c)
    im = im.filter(ImageFilter.GaussianBlur(12)).resize((W, H), Image.BICUBIC)
    grain = Image.effect_noise((W, H), 10).convert("RGB")
    im = ImageChops.blend(im, ImageChops.overlay(im, grain), 0.18)
    im.save(os.path.join(out_dir, "1-sunset.jpg"), quality=90, optimize=True)
    Image.new("RGB", (W, H), nb.hex2rgb(T["bg"])).save(os.path.join(out_dir, "2-paper.jpg"), quality=90)


def fastfetch_conf(color):
    """Как его fastfetch: сверху пилюли «ARCH LINUX» и «HYPRLAND» на пастельных заливках, ниже «значок ключ › значение»
    (значки — пастелью по кругу), внизу — шесть пастельных пилюль."""
    import json
    rgb = nb.hex2rgb
    fg = lambda h: "\x1b[38;2;%d;%d;%dm" % rgb(h)
    bgc = lambda h: "\x1b[48;2;%d;%d;%dm" % rgb(h)
    ink = T["ink"]
    pill = lambda text, c: fg(c) + "" + bgc(c) + fg(ink) + "\x1b[1m " + text + " \x1b[0m" + fg(c) + "\x1b[0m"
    dots = "  ".join(fg(T[k]) + "██" for k in ["rose", "olive", "title_bar", "peach", "peach", "olive"]) + "\x1b[0m"
    icol = lambda k: "38;2;%d;%d;%d" % rgb(T[k] if color else T["muted"])
    rows = [("user", "", "rose", "title", "{user-name}@{host-name}"), ("os", "", "olive", "os", "{pretty-name}"),
            ("kernel", "", "peach", "kernel", "{sysname} {release}"), ("wm", "", "salmon", "wm", "{pretty-name}"),
            ("shell", "", "yellow", "shell", "{pretty-name} {version}"), ("pkgs", "", "pink", "packages", "{all}"),
            ("uptime", "", "green", "uptime", None), ("memory", "\U000f035b", "lavender", "memory", "{used} / {total} ({percentage})")]
    mods = [{"type": "custom", "format": pill("ARCH LINUX", T["rose"]) + "  " + pill("HYPRLAND", T["olive"])},
            {"type": "custom", "format": ""}]
    for name, ic, col, typ, fmt in rows:
        m = {"type": typ, "key": "{icon}  " + name, "keyIcon": ic, "keyColor": icol(col)}
        if fmt:
            m["format"] = fmt
        mods.append(m)
    mods += [{"type": "custom", "format": ""}, {"type": "custom", "format": dots}]
    conf = {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {"type": "none"},
        "display": {"separator": "  ›  ", "color": {"separator": "38;2;%d;%d;%d" % rgb(T["muted"]),
                    "output": "38;2;%d;%d;%d" % rgb(ink), "keys": "1;38;2;%d;%d;%d" % rgb(ink)}, "key": {"width": 12}},
        "modules": mods,
    }
    return "// Bruteon: omarchy-themes/bruteon/build.py\n" + json.dumps(conf, indent=2, ensure_ascii=False) + "\n"


def btop_theme(color):
    t = T
    lo, mid, hi = (t["green"], t["yellow"], t["red"]) if color else (t["peach"], t["muted"], t["brown"])
    th = [("main_bg", ""), ("main_fg", t["ink"]), ("title", t["ink"]), ("hi_fg", t["brown"]), ("selected_bg", t["title_bar"]),
          ("selected_fg", t["ink"]), ("inactive_fg", nb.mix(t["ink"], t["bg"], 0.5)), ("graph_text", t["muted"]),
          ("meter_bg", t["title_bar"]), ("proc_misc", t["brown"]), ("cpu_box", t["ink"]), ("mem_box", t["ink"]),
          ("net_box", t["ink"]), ("proc_box", t["ink"]), ("div_line", t["muted"])]
    for name in ("temp", "cpu", "free", "cached", "available", "used", "download", "upload", "process"):
        th += [(name + "_start", readable(lo, t["bg"], 1.6)), (name + "_mid", mid), (name + "_end", hi)]
    return "# Bruteon: omarchy-themes/bruteon/build.py\n" + "".join(f'theme[{k}]="{v}"\n' for k, v in th)


def hypr_lua():
    """Окна как у Bruteon: рамка цветом контура, жёсткая тень 6 × 6 без размытия."""
    ink = T["ink"].lstrip("#")
    return f"""-- Bruteon: рамка цветом контура и жёсткая тень без размытия (omarchy-themes/bruteon/build.py).
local border = "rgb({ink})"
hl.config({{
	general = {{ col = {{ active_border = border, inactive_border = border }} }},
	group = {{ col = {{ border_active = border, border_inactive = border }} }},
	decoration = {{ shadow = {{ range = 1, render_power = 4, sharp = true, offset = "6 6", color = "rgba({ink}ff)", color_inactive = "rgba({ink}ff)" }} }},
}})
"""


if __name__ == "__main__":
    for color in (False, True):
        key = "light" + ("-color" if color else "")
        nb.PALETTES[key] = palette(color)
        nb.build(key)
        out = os.path.join(HERE, key)
        f = os.path.join(out, "colors.toml")
        lines = open(f).read().split("\n")
        lines[0] = f"# {nb.PALETTES[key]['title']} — omarchy-themes/bruteon (по мотивам Bruteon; сборка: build.py поверх ../nothing/build.py)."
        open(f, "w").write("\n".join(lines))
        open(os.path.join(out, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(color))
        open(os.path.join(out, "btop.theme"), "w").write(btop_theme(color))
        open(os.path.join(out, "hyprland.lua"), "w").write(hypr_lua())
