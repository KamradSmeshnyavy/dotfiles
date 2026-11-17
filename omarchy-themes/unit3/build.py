#!/usr/bin/env python3
"""Темы unit3-* — по мотивам Unit-3 (github.com/samyns/Unit-3, «Hyprland + Quickshell rice with a NieR:Automata
aesthetic», MIT; цвета и облик — из его конфигов).

unit3-dark — его стол и терминал: тёмная сепия #0b0a09, текст #c8b89a, линии того же цвета с прозрачностью, акценты
приглушённые — красный #c87060, зелёный #60a880, синий #6090c8, золото #c8a860; 16 цветов — ровно из его kitty.conf.
unit3-paper — его меню (лаунчер, центр управления): бежевая «бумага» NieR #d6cfb5, чернила #463f2e, красный #6e2a2a.
Окна — рамка 1 px цветом текста (неактивные — #1a1814), без скругления, теней и размытия, как у него.
Обои — первыми его (ORIGINALS, файлы в репозитории), дальше свои: сетка NieR на фоне темы.

  python3 build.py              обе темы
  python3 build.py paper        выбранные
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "nothing"))
sys.path.insert(0, os.path.join(HERE, ".."))
import build as nb  # noqa: E402
import originals  # noqa: E402
from palettes import contrast  # noqa: E402

DARK = {
    "title": "Unit-3", "mode": "dark",
    "bg": "#0b0a09", "panel": "#111008", "raised": "#1a1814", "fg": "#c8b89a", "dim": "#8a7f6a",
    "accent": "#c8b89a", "border_off": "#1a1814",
    "red": "#c87060", "green": "#60a880", "blue": "#6090c8", "gold": "#c8a860", "cursor": "#6e2a2a",
    # его kitty.conf, как есть
    "ansi16": ["#0b0906", "#6e2a2a", "#463f2e", "#7a6a3e", "#3a4a5a", "#5a3a4a", "#3a5a5a", "#c8b89a",
               "#2a2420", "#8a3a3a", "#6a5f4a", "#9a8a5a", "#4a6a7a", "#7a4a6a", "#4a7a7a", "#d6cfb5"],
}
PAPER = {
    "title": "Unit-3 Paper", "mode": "light",
    "bg": "#d6cfb5", "panel": "#ccc4a6", "raised": "#b8af93", "fg": "#2e2a1f", "dim": "#7a7358",
    "accent": "#6e2a2a", "border_off": "#b8af93",
    "red": "#6e2a2a", "green": "#4f5a2e", "blue": "#3a4a5a", "gold": "#7a6a3e", "cursor": "#6e2a2a",
    "ansi16": ["#2e2a1f", "#6e2a2a", "#463f2e", "#7a6a3e", "#3a4a5a", "#5a3a4a", "#3a5a5a", "#7a7358",
               "#7a7358", "#8a3a3a", "#6a5f4a", "#9a8a5a", "#4a6a7a", "#7a4a6a", "#4a7a7a", "#2e2a1f"],
}
VARIANTS = {"dark": DARK, "paper": PAPER}
T = DARK

# его обои (assets/wallpapers): 2B — главные, остальные — следом
ORIGINALS = [
    ("0-original", "assets/wallpapers/video-games-nier-automata-2b-nier-automata-wallpaper-3816fda860c05c98705c019e3812740a.jpg", None),
    ("0r-battle", "assets/wallpapers/wallpaperflare.com_wallpaper.jpg", None),
    ("0r-yorha", "assets/wallpapers/UDqXyQq.jpeg", None),
    ("0r-hollow", "assets/wallpapers/vincent-bisschop-hollow-knight-fantasy-art-video-games-wallpaper-dc425103943cadc74f86ffc53d8f7622.jpg", None),
]


def readable(c, bg, need):
    dark = sum(nb.hex2rgb(bg)) < 384
    for _ in range(40):
        if contrast(c, bg) >= need:
            break
        c = nb.mix(c, "#ffffff" if dark else "#000000", 0.06)
    return c


def palette(v):
    t = VARIANTS[v]
    dark = t["mode"] == "dark"
    bg, fg, acc = t["bg"], t["fg"], t["accent"]
    p = {
        "mode": t["mode"], "title": t["title"], "name": f"unit3-{v}", "out": os.path.join(HERE, v),
        "bg": bg, "panel": t["panel"], "raised": t["raised"], "line": nb.mix(bg, fg, 0.15 if dark else 0.25),
        "fg": fg, "dim": readable(t["dim"], bg, 4.5), "comment": readable(nb.mix(t["dim"], bg, 0.3), bg, 3),
        "accent": acc, "on_accent": bg if dark else "#d6cfb5", "selection": nb.mix(bg, fg if dark else acc, 0.3),
        "error": readable(t["red"], bg, 4.5), "info": readable(t["blue"], bg, 4.5),
        "diff_add": nb.mix(bg, t["green"], 0.35), "diff_del": nb.mix(bg, t["red"], 0.35), "diff_change": nb.mix(bg, t["blue"], 0.3),
        "min_de": 0,
        "ansi16": [readable(c, bg, 1.0) for c in t["ansi16"]] if dark else [readable(c, bg, 3.2) for c in t["ansi16"]],
    }
    if not dark:
        p["light_mode_file"] = True
    syn = {"keyword": t["red"], "string": t["green"], "number": t["gold"], "type": fg, "function": t["blue"],
           "property": t["dim"], "special": t["red"], "constant": t["gold"]}
    for role, c in syn.items():
        p[role] = readable(c, bg, 4.5)
    p["ansi_yellow"] = p["number"]
    p["warn"] = readable(t["gold"], bg, 4.5)
    p["hint"] = p["dim"]
    p["ok"] = p["string"]
    p["wallpapers"] = lambda pp, d, t=t: walls(t, d)
    return p


def walls(t, out_dir):
    """Первыми — его обои; дальше своя «сетка NieR»: фон темы, тонкая сетка 40 px и редкие засечки."""
    from PIL import Image, ImageDraw
    originals.place(out_dir, "samyns/Unit-3", "main", ORIGINALS, env="UNIT3_SRC")
    W, H = 2880, 1800
    bg, fg = nb.hex2rgb(t["bg"]), nb.hex2rgb(t["fg"])
    mix = lambda k: tuple(int(bg[i] + (fg[i] - bg[i]) * k) for i in range(3))
    im = Image.new("RGB", (W, H), bg)
    d = ImageDraw.Draw(im)
    for x in range(0, W, 40):
        d.line([(x, 0), (x, H)], fill=mix(0.05), width=2)
    for y in range(0, H, 40):
        d.line([(0, y), (W, y)], fill=mix(0.05), width=2)
    for x in range(0, W, 320):
        for y in range(0, H, 320):
            d.line([(x - 12, y), (x + 12, y)], fill=mix(0.22), width=2)
            d.line([(x, y - 12), (x, y + 12)], fill=mix(0.22), width=2)
    im.save(os.path.join(out_dir, "1-grid.png"), optimize=True)


def hypr_lua():
    """Окна как у него: рамка 1 px цветом текста (rgba …ee), неактивные — тёмные (…aa)."""
    on, off = T["fg"].lstrip("#"), T["border_off"].lstrip("#")
    return f"""-- Unit-3: рамка цветом текста, неактивные — тёмные (omarchy-themes/unit3/build.py).
hl.config({{
	general = {{ col = {{ active_border = "rgba({on}ee)", inactive_border = "rgba({off}aa)" }} }},
	group = {{ col = {{ border_active = "rgba({on}ee)", border_inactive = "rgba({off}aa)" }} }},
}})
"""


def make(v, out=None, name=None):
    """Собрать тему варианта v (ключ VARIANTS) в out (по умолчанию — каталог варианта в репо)."""
    global T
    T = VARIANTS[v]
    p = palette(v)
    if out:
        p["out"], p["name"] = out, name
        p.pop("wallpapers", None)  # у dynamic-* фоны — пул обоев райса (omarchy-rice-dynamic)
    nb.PALETTES[v] = p
    nb.build(v)
    out = p["out"]
    f = os.path.join(out, "colors.toml")
    lines = open(f).read().split("\n")
    lines[0] = f"# {T['title']} — omarchy-themes/unit3 (по мотивам Unit-3, samyns, MIT; сборка: build.py поверх ../nothing/build.py)."
    open(f, "w").write("\n".join(lines))
    open(os.path.join(out, "hyprland.lua"), "w").write(hypr_lua())


# omarchy-rice-dynamic: вариант, на который опирается dynamic, и режимы вариантов
DYNAMIC_BASE = "dark"


def base_modes():
    return {v: t["mode"] for v, t in VARIANTS.items() if v != "dynamic"}


def _muted(c, cap=0.4):
    import colorsys
    r, g, b = (x / 255 for x in nb.hex2rgb(c))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    r, g, b = colorsys.hls_to_rgb(h, l, min(s, cap))
    return nb.rgb2hex(round(r * 255), round(g * 255), round(b * 255))


# роли цветов для переворота палитры варианта (dynamic_map.flip); 16 цветов терминала при перевороте — от другого варианта
FLIP_ROLES = {"bg": "surface", "panel": "surface", "raised": "surface", "border_off": "surface", "fg": "text",
              "dim": "text", "red": "color", "green": "color", "blue": "color", "gold": "color"}


def dynamic(s, out, name, base=DYNAMIC_BASE, scheme="tonal-spot", flip=False):
    """Тема из обоев (omarchy-rice-dynamic, движок rice). Характер Unit-3 сохраняется: приглушённые цвета (насыщенность
    не выше 0.4), рамка окна цветом текста, 16 цветов терминала тёмными тонами. scheme accent — вариант base как есть,
    с обоев только акцент и курсор; flip — та же палитра в противоположном режиме (Бумага тёмная)."""
    if scheme == "accent":
        t = dict(VARIANTS[base])
        if flip:
            import dynamic_map as dm
            other = next(v for k, v in VARIANTS.items() if k != "dynamic" and v["mode"] == s["mode"])
            t = dm.flip(t, FLIP_ROLES, s["mode"], "bg")
            t["mode"], t["ansi16"] = s["mode"], list(other["ansi16"])
            to_dark = s["mode"] == "dark"
            s = dict(s, accent=dm.flip_color(s["accent"], "color", to_dark, t["bg"]),
                     accent_lo=dm.flip_color(s["accent_lo"], "color", to_dark, t["bg"]))
        t.update(accent=_muted(s["accent"], 0.5), cursor=_muted(s["accent_lo"], 0.5))
    else:
        bg, fg = s["bg"], s["fg"]
        if s["mono"]:
            red, green, blue, gold = s["accent"], nb.mix(fg, s["dim"], 0.5), s["dim"], nb.mix(s["accent"], fg, 0.5)
            mag, cyan = nb.mix(s["accent"], s["dim"], 0.5), nb.mix(fg, s["dim"], 0.3)
        else:
            red, green, blue, gold, mag, cyan = (nb.mix(_muted(s[k]), fg, 0.15)
                                                 for k in ("red", "green", "blue", "yellow", "magenta", "cyan"))
        hues = [red, green, gold, blue, mag, cyan]
        dark = s["mode"] == "dark"
        low = [nb.mix(c, bg, 0.45 if dark else 0.0) for c in hues]
        t = {"mode": s["mode"], "bg": bg, "panel": s["panel"], "raised": s["raised"], "fg": fg, "dim": s["dim"],
             "accent": _muted(s["accent"], 0.5), "border_off": s["raised"], "red": red, "green": green, "blue": blue,
             "gold": gold, "cursor": _muted(s["accent_lo"], 0.5),
             "ansi16": [nb.mix(bg, fg, 0.04)] + low + [fg if dark else s["dim"],
                        nb.mix(bg, fg, 0.15)] + hues + [nb.mix(fg, "#ffffff", 0.3) if dark else fg]}
    t["title"] = "Unit-3 Dynamic"
    VARIANTS["dynamic"] = t
    make("dynamic", out, name)


if __name__ == "__main__":
    for v in [a for a in sys.argv[1:] if not a.startswith("--")] or list(VARIANTS):
        make(v)
