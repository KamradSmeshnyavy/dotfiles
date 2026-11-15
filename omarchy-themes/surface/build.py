#!/usr/bin/env python3
"""Темы surface-* — по мотивам surface-dots (github.com/snes19xx/surface-dots, автор snes19xx; файла лицензии нет, но
README разрешает брать что угодно со ссылкой на автора и на источники фото — ссылка в README рядом).

Палитры — из его lib/ThemeEngine.qml (поверхности, текст, акценты) и kitty/themes/everforest*.conf (терминал): тёмная —
графит #141719 с зеленью Everforest, светлая — тёплая бумага #f0ece6 с оливковыми чернилами. По умолчанию темы
одноцветные (синтаксис, 16 цветов терминала, статусы и btop — оттенки зелени и чернил); варианты -color — с разноцветным
терминалом самого surface-dots. fastfetch — как его config.jsonc: разделитель « ▐ », значки-ключи, строка «─» под
заголовком, кружки цветов; логотип — свой Сатурн полублоками (в честь его меню выключения Cassini). Рамки окон — 1 px
зеленью с прозрачностью, тень как у него. Обои — свои: зернистая «бумага» цвета темы и слои гор зеленью (у него —
фото с Unsplash и рисунок Амано, их не копируем). Раскладку по приложениям делает генератор тем nothing.

  python3 build.py                 все темы
  python3 build.py dark light      выбранные
"""
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
import build as nb  # noqa: E402
from palettes import contrast  # noqa: E402

# ThemeEngine.qml: bgMain, bgCard, bgItem, bgItemHover, textPrimary, textSecondary, accent / accentSlider, accentRed;
# Configuration.qml: taskbarAccent #759b61; hyprland.lua: рамка rgba(87b158aa) / rgba(595959aa);
# kitty everforest*.conf: background, foreground, selection, color0–15
SURFACE = {
    "dark": {
        "title": "Surface Dark", "mode": "dark",
        "bg": "#141719", "panel": "#1e2326", "raised": "#2d353b", "line": "#374145",
        "fg": "#e5dfc5", "dim": "#9da9a0", "accent": "#a7c080", "accent2": "#83c092", "bar": "#759b61",
        "deep": "#7aa265", "error": "#e67e80", "warm": "#f1af97", "selection": "#3a4438",
        "border": "rgba(87b158aa)", "border_off": "rgba(595959aa)",
        "ansi": ["#3c474d", "#a04f50", "#7aa265", "#d9bb80", "#83b6af", "#d39bb6", "#87c095", "#868d80",
                 "#868d80", "#a04f50", "#729e5a", "#d9bb80", "#83b6af", "#d39bb6", "#87c095", "#e5dfc5"],
    },
    "light": {
        "title": "Surface Light", "mode": "light",
        "bg": "#f0ece6", "panel": "#e3ded6", "raised": "#d8d2c8", "line": "#c9c2b6",
        "fg": "#252e33", "dim": "#546670", "accent": "#4f6b5b", "accent2": "#4a6b70", "bar": "#759b61",
        "deep": "#608552", "error": "#c74042", "warm": "#d39984", "selection": "#dfe6cf",
        "border": "rgba(608552cc)", "border_off": "rgba(a39e93aa)",
        "ansi": ["#5c6a72", "#c33b39", "#729e5a", "#dfa000", "#3a94c5", "#df69ba", "#4a6b70", "#164a2b",
                 "#829181", "#c33b39", "#729e5a", "#dfa000", "#3a94c5", "#df69ba", "#4a6b70", "#5c6a72"],
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
    t = SURFACE[v]
    bg, fg, acc = t["bg"], t["fg"], t["accent"]
    dark = t["mode"] == "dark"
    dim = t["dim"]
    p = {
        "mode": t["mode"], "title": t["title"] + (" Color" if color else ""),
        "name": f"surface-{v}" + ("-color" if color else ""), "out": os.path.join(HERE, v + ("-color" if color else "")),
        "bg": bg, "panel": t["panel"], "raised": t["raised"], "line": t["line"],
        "fg": readable(fg, bg, 7), "dim": readable(dim, bg, 4.5), "comment": readable(nb.mix(fg, bg, 0.55), bg, 3),
        "accent": acc, "on_accent": "#232a2e" if dark else "#f0ece6", "selection": t["selection"],
        "error": readable(t["error"], bg, 4.5), "info": readable(t["accent2"], bg, 4.5),
        "diff_add": nb.mix(bg, acc, 0.16), "diff_del": nb.mix(bg, t["error"], 0.2), "diff_change": nb.mix(bg, t["accent2"], 0.12),
        "min_de": 0,
    }
    if color:
        a = t["ansi"]
        syn = {"keyword": a[1], "string": a[2], "number": a[13], "type": a[3], "function": a[4], "property": a[6],
               "special": a[5], "constant": a[11]}
        p["ansi16"] = list(a)
    else:
        # одним цветом: зелень разной глубины (accent, accent2 — бирюзово-зелёный, deep — тёмная) и чернила
        syn = {"keyword": acc, "string": nb.mix(acc, fg, 0.45), "number": t["accent2"], "type": fg,
               "function": nb.mix(fg, acc, 0.3), "property": dim, "special": t["error"], "constant": nb.mix(t["accent2"], fg, 0.4)}
        g = lambda k: nb.mix(dim, fg, k)
        p["ansi16"] = [t["raised"] if dark else fg, t["error"], t["deep"], acc, g(0.3), t["accent2"], g(0.6),
                       dim if dark else t["line"],
                       p["comment"], readable(t["error"], bg, 3), nb.mix(acc, fg, 0.25), nb.mix(acc, fg, 0.15), g(0.5),
                       nb.mix(t["accent2"], fg, 0.2), g(0.8), fg if dark else "#a39e93"]
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(t["warm"], bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = p["string"]
    if not dark:
        p["light_mode_file"] = True
    p["wallpapers"] = lambda pp, d, t=t: walls(t, d)
    return p


def ridge(w, seed, base, amp, rough):
    """Профиль хребта: сумма синусов разных частот со случайными фазами (без numpy)."""
    rnd = random.Random(seed)
    waves = [(rnd.uniform(0.6, 1.4) * (2 ** i) / w * math.tau, rnd.uniform(0, math.tau), amp / (1.9 ** i)) for i in range(7)]
    out = []
    for x in range(w + 1):
        y = base
        for i, (f, ph, a) in enumerate(waves):
            y -= a * math.sin(x * f + ph) * (rough if i > 3 else 1)
        out.append(y)
    return out


def walls(t, out_dir):
    """Обои: «бумага» с зерном цвета фона и слои гор зеленью, к переднему плану — темнее (у светлой — плотнее);
    второй вариант — только зерно."""
    from PIL import Image, ImageChops, ImageDraw
    os.makedirs(out_dir, exist_ok=True)
    W, H = 2880, 1800
    dark = t["mode"] == "dark"
    base = t["bg"]
    grain = Image.effect_noise((W, H), 22).convert("RGB")
    def paper():
        im = Image.new("RGB", (W, H), nb.hex2rgb(base))
        return ImageChops.blend(im, ImageChops.overlay(im, grain), 0.35 if dark else 0.25)
    plain = paper()
    plain.save(os.path.join(out_dir, "2-paper.jpg"), quality=88, optimize=True)
    im = paper()
    d = ImageDraw.Draw(im)
    layers = [(0.50, 210, 0.9, 0.16), (0.60, 170, 1.0, 0.30), (0.71, 130, 1.1, 0.48), (0.82, 90, 1.25, 0.70)]
    for i, (yb, amp, rough, k) in enumerate(layers):
        if dark:
            # дальние хребты — в зеленоватой дымке, ближние уходят в черноту
            c = nb.mix(nb.mix(base, t["accent"], 0.26), nb.mix(base, "#050606", 0.6), i / 3)
        else:
            c = nb.mix(base, nb.mix(t["deep"], "#2b3a26", i / 5), k)
        prof = ridge(W, 11 + i * 7, H * yb, amp, rough)
        d.polygon([(0, H)] + [(x, prof[x]) for x in range(0, W + 1, 4)] + [(W, H)], fill=nb.hex2rgb(c))
    im = ImageChops.blend(im, ImageChops.overlay(im, grain), 0.3)
    im.save(os.path.join(out_dir, "1-ridges.jpg"), quality=88, optimize=True)


def saturn_px(t):
    """Свой Сатурн на сетке 26 × 16 квадратных клеток: шар акцентом с тёмными полосами, кольцо светлым с наклоном
    ~18° (за шаром — скрыто, перед ним — поверх). Возвращает (W, H, px), px(x, y) — цвет или None."""
    W, H = 26, 16
    cx, cy, R = 12.5, 7.5, 5.4
    ring = t["fg"] if t["mode"] == "dark" else t["dim"]
    band = nb.mix(t["accent"], t["bg"], 0.3)
    a = math.radians(-14)
    def px(x, y):
        dx, dy = x - cx, y - cy
        rx, ry = dx * math.cos(a) - dy * math.sin(a), dx * math.sin(a) + dy * math.cos(a)
        e = (rx / 12.6) ** 2 + (ry / 3.0) ** 2
        in_ring = 0.45 < e < 1.0
        in_ball = dx * dx + dy * dy <= R * R
        if in_ring and (ry > 0 or not in_ball):
            return ring
        if in_ball:
            return band if int(ry + 20) % 3 == 0 else t["accent"]
        return None
    return W, H, px


def saturn_logo(t):
    """Логотип fastfetch: Сатурн полублоками (две клетки сетки на символ)."""
    rgb = nb.hex2rgb
    W, H, px = saturn_px(t)
    rows = []
    for y in range(0, H, 2):
        line = ""
        for x in range(W):
            u, l = px(x, y), px(x, y + 1)
            if u is None and l is None:
                line += "\x1b[0m "
            elif l is None:
                line += "\x1b[0m\x1b[38;2;%d;%d;%dm▀" % rgb(u)
            elif u is None:
                line += "\x1b[0m\x1b[38;2;%d;%d;%dm▄" % rgb(l)
            else:
                line += "\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm▀" % (rgb(u) + rgb(l))
        rows.append(line.rstrip() + "\x1b[0m")
    while rows and not rows[-1].replace("\x1b[0m", "").strip():
        rows.pop()
    while rows and not rows[0].replace("\x1b[0m", "").strip():
        rows.pop(0)
    return "\n".join(rows) + "\n"


def fastfetch_conf(t, color, logo):
    """Как его config.jsonc: заголовок user@host, строка «─», ключи-значки цветами терминала, разделитель « ▐ »,
    кружки 16 цветов."""
    import json
    e = lambda h: "38;2;%d;%d;%d" % nb.hex2rgb(h)
    a = t["ansi"]
    if color:
        keys = [a[4], a[7], a[2], a[3], a[7], a[5], a[6]]
        line, user, host = a[1], a[4], a[6]
    else:
        keys = [t["accent"], t["dim"], t["deep"], t["accent2"], t["dim"], t["accent"], t["accent2"]]
        line, user, host = t["deep"], t["accent"], t["accent2"]
    k = iter(keys)
    mod = lambda typ, key, fmt=None, **kw: dict({"type": typ, "key": key, "keyColor": e(next(k))}, **({"format": fmt} if fmt else {}), **kw)
    conf = {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {"type": "file-raw", "source": "~/.local/state/omarchy/current/theme/apps/" + logo,
                 "padding": {"top": 2, "left": 2, "right": 3}},
        "display": {"separator": " ▐ ", "color": {"separator": e(t["line"] if t["mode"] == "dark" else t["dim"]), "output": e(t["fg"])}},
        "modules": [
            {"type": "custom", "format": ""},
            {"type": "title", "color": {"user": e(user), "at": e(host), "host": e(user)}},
            {"type": "separator", "string": "─", "outputColor": e(line)},
            mod("os", "\uf303 ", "{3}"), mod("kernel", "\ue712 ", "{2}"), mod("packages", "\uf487 "),
            mod("shell", "\ue614 ", "{1} {4}"), mod("terminal", "\uf489 "), mod("wm", "\uf2d2 "),
            mod("display", "\U000f0379 ", "{1}x{2}", compactType="original"),
            {"type": "colors", "paddingLeft": 0, "symbol": "circle", "block": {"range": [0, 15], "width": 3}},
        ],
    }
    return "// surface: omarchy-themes/surface/build.py по палитре темы\n" + json.dumps(conf, indent=2, ensure_ascii=False) + "\n"


def btop_theme(t, color):
    """btop: рамки — линии темы, заголовки зеленью; графики — от светлой зелени к глубокой (у -color — зелень → охра →
    красный, как Everforest)."""
    dark = t["mode"] == "dark"
    fg, dim, acc, deep, a2 = t["fg"], t["dim"], t["accent"], t["deep"], t["accent2"]
    lo, mid, hi = (acc, t["ansi"][3], t["error"]) if color else (nb.mix(acc, t["bg"], 0.35), acc, deep if dark else t["fg"])
    box = nb.mix(t["line"], dim, 0.3)
    th = [("main_bg", ""), ("main_fg", fg), ("title", acc), ("hi_fg", a2), ("selected_bg", t["raised"]),
          ("selected_fg", acc), ("inactive_fg", nb.mix(fg, t["bg"], 0.55)), ("graph_text", dim), ("meter_bg", t["raised"]),
          ("proc_misc", a2), ("cpu_box", box), ("mem_box", box), ("net_box", box), ("proc_box", box), ("div_line", t["line"])]
    for name in ("temp", "cpu", "free", "cached", "available", "used", "download", "upload", "process"):
        th += [(name + "_start", lo), (name + "_mid", mid), (name + "_end", hi)]
    return "# surface: omarchy-themes/surface/build.py\n" + "".join(f'theme[{k}]="{v}"\n' for k, v in th)


def hypr_lua(t):
    """Рамка, тень и groupbar окон как у surface-dots (hyprland.lua): рамка 1 px зеленью с прозрачностью, у неактивного —
    серая; тень range 3 тёплой полупрозрачной; groupbar — зелёная активная вкладка. Толщину и углы задаёт стиль."""
    groupbar_off = "rgba(2D353Bff)" if t["mode"] == "dark" else "rgba(d8d2c8ff)"
    text_off = "rgba(e5e6c5ff)" if t["mode"] == "dark" else "rgba(252e33ff)"
    return f"""-- {t['title']}: рамка, тень и groupbar окон как у surface-dots (omarchy-themes/surface/build.py).
hl.config({{
	general = {{ col = {{ active_border = "{t['border']}", inactive_border = "{t['border_off']}" }} }},
	decoration = {{ shadow = {{ range = 3, render_power = 4, color = "rgba(44220044)", color_inactive = "rgba(44220044)" }} }},
	group = {{
		col = {{ border_active = "rgba(00000000)", border_inactive = "rgba(00000000)" }},
		groupbar = {{ gradients = true, col = {{ active = "rgb({t['bar'].lstrip('#')})", inactive = "{groupbar_off}" }},
			text_color = "rgb(293136)", text_color_inactive = "{text_off}", gradient_rounding = 8, height = 16 }},
	}},
}})
"""


if __name__ == "__main__":
    for v in [a for a in sys.argv[1:] if not a.startswith("--")] or list(SURFACE):
        for color in (False, True):
            key = v + ("-color" if color else "")
            nb.PALETTES[key] = palette(v, color)
            nb.build(key)
            t = SURFACE[v]
            out = os.path.join(HERE, key)
            f = os.path.join(out, "colors.toml")
            lines = open(f).read().split("\n")
            lines[0] = f"# {nb.PALETTES[key]['title']} — omarchy-themes/surface (по мотивам surface-dots; сборка: build.py поверх ../nothing/build.py)."
            open(f, "w").write("\n".join(lines))
            open(os.path.join(out, "apps", "saturn-logo.txt"), "w").write(saturn_logo(t))
            open(os.path.join(out, "apps", "fastfetch.jsonc"), "w").write(fastfetch_conf(t, color, "saturn-logo.txt"))
            open(os.path.join(out, "btop.theme"), "w").write(btop_theme(t, color))
            open(os.path.join(out, "hyprland.lua"), "w").write(hypr_lua(t))
