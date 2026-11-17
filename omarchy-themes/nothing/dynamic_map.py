"""Тема райса из обоев (omarchy-rice-dynamic): цвета обоев → общие смысловые слоты, из которых build.py каждого райса
собирает свою палитру (ink/mint/tint у Vitreus, bg/fg/accent у Unit-3 и т. д.), а движок colors — один colors.toml.

Цвета читает Iris (../scripts/iris_colors.py) — как Vitreus для Glass: фон и поверхность из реальных цветов картинки,
текст с контрастом, акцент — самый заметный цвет обоев, красный / зелёный / жёлтый — найденные на обоях оттенки.
Дальше — как vitreus.luau (iris_palette / build_palette): акцент подталкивается по насыщенности (Bold), mintlo / minthi —
тот же цвет темнее / светлее, deep — фон к чёрному, off — фон к тексту, текст и акцент держат контраст 4.5.

seed(image, scheme, mode) → {
  mode, bg, panel, raised, line, fg, dim, accent, accent_lo, accent_hi, on_accent, deep, alert,
  red, green, yellow, blue, magenta, cyan, orange,  # оттенки для терминала (в тоне обоев)
  syntax: {keyword, string, number, type, function, property, special, constant},  # Iris: роли синтаксиса
  mono,                                            # True — райс красит синтаксис оттенками одного цвета
}

Режимы (scheme):
  vitreus   — палитра в точности как у Vitreus (vitreus_palette: 11 цветов, всегда тёмная и на стекле), без добавок;
              exact — райс кладёт их как есть; терминал и синтаксис — одним цветом;
  wallpaper — цвета обоев по-Vitreus, плюс синтаксис и оттенки терминала, найденные Iris на обоях;
  soft      — то же, акцент и оттенки приглушены (Vitreus Subtle);
  vivid     — насыщеннее: акцент и все оттенки ярче;
  pure, pure-soft, pure-vivid — как wallpaper / soft / vivid, но все цвета терминала и кода — только оттенки, которые
              реально есть на обоях (кластеры Iris); недостающие — ступени светлоты этих же оттенков и акцента.
              Красный остаётся для ошибок, даже если его нет на картинке;
  mono      — монохром в тоне обоев: всё — один оттенок (главный цвет обоев — фон, если он не серый, иначе акцент),
              разной светлоты и насыщенности; красный остаётся для ошибок;
  grey      — серый, как Vitreus с выключенным Iris: нейтральные серые и красный для ошибок; от обоев не зависит;
  accent    — палитра варианта райса как есть, с обоев только акцент (райс берёт accent*, остальное — своё).
mode: dark / light / None (решает Iris по яркости обоев).
"""
import colorsys
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts"))
import wallpaper_colors as wc  # noqa: E402

SCHEMES = ["vitreus", "wallpaper", "soft", "vivid", "pure", "pure-soft", "pure-vivid", "mono", "grey", "accent"]
# только цвета обоев: оттенки терминала и кода — лишь те, что реально есть на картинке (без синтезированных)
PURE = {"pure": None, "pure-soft": "subtle", "pure-vivid": "lift"}
# прежние имена (схемы matugen) → новые, чтобы старый dynamic.json не ломался
ALIASES = {"tonal-spot": "wallpaper", "content": "wallpaper", "fidelity": "wallpaper", "neutral": "soft",
           "vibrant": "vivid", "expressive": "vivid", "fruit-salad": "vivid", "rainbow": "vivid",
           "monochrome": "grey", "mono-tint": "mono"}
HUES = ["red", "green", "yellow", "blue", "magenta", "cyan", "orange"]
HUE_DEG = {"red": 5, "orange": 28, "yellow": 48, "green": 138, "cyan": 185, "blue": 215, "magenta": 300}


def canon(scheme):
    return ALIASES.get(scheme, scheme)


# ── цвет: hex ↔ HSL, смешение, контраст (как в vitreus.luau) ──

def rgb(h):
    return tuple(int(h[i:i + 2], 16) / 255 for i in (1, 3, 5))


def hexc(r, g, b):
    return "#%02x%02x%02x" % tuple(round(max(0.0, min(1.0, v)) * 255) for v in (r, g, b))


def hsl(h):
    hh, l, s = colorsys.rgb_to_hls(*rgb(h))
    return hh, s, l


def from_hsl(h, s, l):
    return hexc(*colorsys.hls_to_rgb(h % 1.0, max(0.0, min(1.0, l)), max(0.0, min(1.0, s))))


def blend(a, b, t):
    pa, pb = rgb(a), rgb(b)
    return hexc(*(x + (y - x) * t for x, y in zip(pa, pb)))


def lum(h):
    f = lambda v: v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = (f(v) for v in rgb(h))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def shade(c, dl):
    h, s, l = hsl(c)
    return from_hsl(h, s, max(0.03, min(0.97, l + dl)))


def ensure(c, bg, ratio, direction=None):
    """Сдвигать светлоту (тон и насыщенность те же), пока контраст к bg не станет ratio — ensure_contrast Vitreus."""
    if contrast(c, bg) >= ratio:
        return c
    h, s, l = hsl(c)
    d = direction or (1 if l >= hsl(bg)[2] else -1)
    for _ in range(40):
        l = max(0.03, min(0.97, l + d * 0.025))
        cand = from_hsl(h, s, l)
        if contrast(cand, bg) >= ratio:
            return cand
    return from_hsl(h, s, 0.97 if d > 0 else 0.03)


def push(c, how):
    """Акцент по силе (intensity_accent Vitreus): subtle — тише, bold — насыщеннее, vivid — ещё сильнее."""
    h, s, l = hsl(c)
    if how == "subtle":
        s, l = s * 0.45, l + (0.55 - l) * 0.3
    elif how == "bold":
        s, l = min(1, s * 1.5), l + (0.08 if l > 0.5 else -0.08)
    elif how == "vivid":
        s, l = min(0.9, s * 1.6 + 0.08), l + (0.05 if l > 0.5 else -0.05)
    elif how == "lift":  # оттенки терминала в vivid: заметнее, но без кислоты
        s = min(0.75, s * 1.3 + 0.04)
    return from_hsl(h, s, max(0.15, min(0.85, l)))


def like(ref, deg):
    """Оттенок deg с насыщенностью и светлотой ref: недостающие цвета терминала в тоне найденных на обоях."""
    _, s, l = hsl(ref)
    return from_hsl(deg / 360, max(s, 0.35), l)


# ── переворот палитры в противоположный режим (accent + dark у светлого варианта и наоборот) ──

def _lin(v):
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4


def _gam(v):
    v = max(0.0, min(1.0, v))
    return 12.92 * v if v <= 0.0031308 else 1.055 * v ** (1 / 2.4) - 0.055


def oklab(h):
    r, g, b = (_lin(v) for v in rgb(h))
    l_ = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m_ = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s_ = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    return (0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
            1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
            0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_)


def from_oklab(L, a, b):
    l_ = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m_ = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s_ = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    r = 4.0767416621 * l_ - 3.3077118401 * m_ + 0.2309699613 * s_
    g = -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_
    bb = -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_
    return hexc(_gam(r), _gam(g), _gam(bb))


def chroma(h):
    _, a, b = oklab(h)
    return (a * a + b * b) ** 0.5


def flip_color(c, role, to_dark, bg=None):
    """Один цвет в противоположный режим, оттенок и хрома — те же (OKLab):
    surface — фон/панель/линия: тёмная сторона L' = 0.16 + (1 − L)·0.6, светлая 0.97 − L·0.6, хрома × 0.8;
    text — чернила: тёмная сторона L' = 0.95 − L·0.45, светлая 0.05 + (1 − L)·0.45 — порядок светлоты сохраняется
           (faint тусклее ink), а сами они далеко от фона; контраст потом держат ensure / readable;
    color — акцент и прочие цвета: светлота сдвигается только до контраста 4.5 к новому фону bg."""
    L, a, b = oklab(c)
    if role == "surface":
        L2 = 0.16 + (1 - L) * 0.6 if to_dark else 0.97 - L * 0.6
        return from_oklab(L2, a * 0.8, b * 0.8)
    if role == "text":
        L2 = 0.95 - L * 0.45 if to_dark else 0.05 + (1 - L) * 0.45
        return from_oklab(L2, a, b)
    return ensure(c, bg, 4.5, 1 if to_dark else -1) if bg else c


def flip(colors, roles, to_mode, bg_key):
    """Палитра colors ({слот: hex}) в режим to_mode. roles — {слот: surface | text | color | auto}; auto — по хроме:
    почти серый (< 0.04) — text, иначе color (у Vitreus deep бывает и цветом, и тёмными чернилами).
    bg_key — слот фона: сначала переворачивается он, цвета держат контраст уже к новому фону."""
    to_dark = to_mode == "dark"
    out = dict(colors)
    out[bg_key] = flip_color(colors[bg_key], "surface", to_dark)
    for k, role in roles.items():
        if k == bg_key or k not in colors:
            continue
        if role == "auto":
            role = "text" if chroma(colors[k]) < 0.04 else "color"
        out[k] = flip_color(colors[k], role, to_dark, out[bg_key])
    return out


# ── seed ──

def _grey(dark):
    if dark:  # iris_fx.apply_mono Vitreus
        return {"bg": "#161616", "surface": "#232323", "fg": "#ececec", "dim": "#9c9c9c", "accent": "#d6d6d6",
                "red": "#ef4444"}
    return {"bg": "#ececec", "surface": "#e0e0e0", "fg": "#161616", "dim": "#5c5c5c", "accent": "#2a2a2a",
            "red": "#c62828"}


def _lua_hex(r, g, b):
    """rgb_to_hex vitreus.luau: floor(v * 255 + 0.5), без банковского округления Python."""
    import math
    return "#%02x%02x%02x" % tuple(math.floor(max(0.0, min(1.0, v)) * 255 + 0.5) for v in (r, g, b))


def _lua_hsl_hex(h, s, l):
    return _lua_hex(*colorsys.hls_to_rgb(h % 1.0, l, s))


def _lua_blend(a, b, t):
    pa, pb = rgb(a), rgb(b)
    return _lua_hex(*(x + (y - x) * t for x, y in zip(pa, pb)))


def _lua_shade(c, dl):
    h, s, l = hsl(c)
    return _lua_hsl_hex(h, s, max(0.03, min(0.97, l + dl)))


def _lua_ensure(c, bg, ratio, d):
    """ensure_contrast vitreus.luau: шаг 0.03, до 30 шагов, границы 0.03…0.97."""
    if contrast(c, bg) >= ratio:
        return c
    h, s, l = hsl(c)
    for _ in range(30):
        l = max(0.03, min(0.97, l + d * 0.03))
        cand = _lua_hsl_hex(h, s, l)
        if contrast(cand, bg) >= ratio:
            return cand
        if l <= 0.03 or l >= 0.97:
            break
    return _lua_hsl_hex(h, s, 0.97 if d > 0 else 0.03)


def _lua_bold(c):
    """intensity_accent(…, "bold") vitreus.luau."""
    h, s, l = hsl(c)
    s = min(1, s * 1.5)
    l = l + (0.08 if l > 0.5 else -0.08)
    return _lua_hsl_hex(h, s, max(0.15, min(0.85, l)))


def vitreus_palette(image):
    """Палитра в точности как у Vitreus Glass: `iris --json-only --dark 1 --glass` → iris_palette → build_palette
    (vitreus.luau). Одиннадцать цветов: ink faint mint mintlo minthi onmint tint panel deep off alert."""
    ir = wc.iris(image, 1, True)
    surface, bg = ir["surface"], ir["bg"]
    glass = _lua_blend(surface, "#ffffff", 0.12)
    accent = _lua_ensure(_lua_bold(ir["accent"]), glass, 4.5, 1)
    fg = _lua_ensure(ir["fg"], glass, 4.5, 1)
    dim = _lua_ensure(ir["dim"], glass, 4.5, 1)
    red = _lua_ensure(ir["red"], glass, 3.0, 1)
    onmint = "#10161a" if contrast("#10161a", accent) >= contrast("#f5f7f5", accent) else "#f5f7f5"
    return {"ink": fg, "faint": dim, "mint": accent, "mintlo": _lua_shade(accent, -0.10),
            "minthi": _lua_shade(accent, 0.16), "onmint": onmint, "tint": bg, "panel": surface,
            "deep": _lua_blend(bg, "#000000", 0.45), "off": _lua_blend(bg, fg, 0.22), "alert": red}


def _exact(image):
    """Режим vitreus: слоты из палитры Vitreus как есть (exact — райс не должен их подправлять); терминал и синтаксис —
    одним цветом, как одноцветный Vitreus."""
    v = vitreus_palette(image)
    s = {"mode": "dark", "bg": v["tint"], "panel": v["panel"], "raised": blend(v["panel"], v["ink"], 0.08),
         "line": v["off"], "fg": v["ink"], "dim": v["faint"], "accent": v["mint"], "accent_lo": v["mintlo"],
         "accent_hi": v["minthi"], "on_accent": v["onmint"], "deep": v["deep"], "alert": v["alert"],
         "mono": True, "exact": True, "vitreus": v, "scheme": "vitreus"}
    h, sa, la = hsl(v["mint"])
    steps = {"blue": (sa, 0.42), "magenta": (sa * 0.7, 0.53), "green": (sa, la), "cyan": (sa * 0.5, 0.66),
             "yellow": (sa * 0.8, 0.85), "orange": (sa * 0.35, 0.76)}
    for k, (ss, ll) in steps.items():
        s[k] = ensure(from_hsl(h, ss, ll), v["tint"], 3.0, 1)
    s["red"] = v["alert"]
    acc, fg = v["mint"], v["ink"]
    s["syntax"] = {k: ensure(c, v["tint"], 4.5, 1) for k, c in {
        "keyword": v["minthi"], "string": blend(acc, fg, 0.5), "number": acc, "type": fg,
        "function": blend(fg, v["minthi"], 0.35), "property": v["faint"], "special": v["alert"],
        "constant": blend(v["minthi"], fg, 0.4)}.items()}
    return s


def _hue_dist(a, b):
    d = abs(a - b) % 360
    return min(d, 360 - d)


def pure_hues(clusters, accent, dark):
    """Цвета терминала (кроме красного) только из оттенков обоев. clusters — кластеры Iris (h в градусах, s, l, sig).
    1) Слоту (зелёный, жёлтый, …) достаётся настоящий оттенок картинки в пределах 30° от его цвета, если такой есть.
    2) Остальные слоты — ступени светлоты и насыщенности уже найденных оттенков обоев и акцента, по кругу: цвета разные
       по светлоте, но ни одного чужого оттенка."""
    lo, hi = (0.48, 0.82) if dark else (0.22, 0.48)
    sat_floor = 0.35 if dark else 0.5
    real = []
    # настоящий цвет — заметная хрома (Lab c ≥ 15) не в почти чёрном (l ≥ 0.10): в тенях оттенок — шум
    for e in sorted((e for e in clusters if e["s"] >= 0.18 and e.get("c", 99) >= 15 and e["l"] >= 0.10),
                    key=lambda e: -e["sig"]):
        if all(_hue_dist(e["h"], r["h"]) >= 20 for r in real):
            real.append(e)
    out, used = {}, set()
    slots = ["green", "yellow", "blue", "magenta", "cyan", "orange"]
    for k in slots:
        cand = [(r, _hue_dist(r["h"], HUE_DEG[k])) for i, r in enumerate(real) if i not in used]
        cand = [(r, d) for r, d in cand if d <= 30]
        if cand:
            r, _ = min(cand, key=lambda x: x[1])
            used.add(real.index(r))
            out[k] = from_hsl(r["h"] / 360, min(0.85, max(r["s"], sat_floor)), (lo + hi) / 2)
    # ступени: оттенки обоев по заметности, затем акцент; светлота — по лесенке, чтобы соседние слоты различались
    hues = [(r["h"] / 360, min(0.85, max(r["s"], sat_floor))) for r in real]
    ah, asat, _ = hsl(accent)
    hues.append((ah, max(asat, sat_floor)))
    # красный — для ошибок: пока на обоях есть не-красные оттенки, лесенка ходит только по ним (иначе «добавлено» в
    # git diff и ошибки — одного цвета); красные — только если других нет
    not_red = [x for x in hues if _hue_dist(x[0] * 360, HUE_DEG["red"]) > 25]
    hues = not_red or hues
    ladder = [lo, hi, (lo + hi) / 2 + 0.08, lo + 0.06, hi - 0.06, (lo + hi) / 2 - 0.06]
    i = 0
    for k in slots:
        if k in out:
            continue
        h, sat = hues[i % len(hues)]
        out[k] = from_hsl(h, sat * (0.7 if (i // len(hues)) % 2 else 1.0), ladder[i % len(ladder)])
        i += 1
    return out


def seed(image, scheme="wallpaper", mode=None, glass=False):
    scheme = canon(scheme)
    if scheme not in SCHEMES:
        raise wc.Error(f"нет режима {scheme} (есть: {', '.join(SCHEMES)})")
    if scheme == "vitreus":
        return _exact(image)  # всегда тёмный и на стекле, как Vitreus: настройка светлая / тёмная не действует
    dark_arg = {"dark": 1, "light": 0}.get(mode, -1)
    if scheme in PURE:
        ir, clusters = wc.iris(image, dark_arg, glass, clusters=True)
    else:
        ir, clusters = wc.iris(image, dark_arg, glass), []
    dark = bool(ir["dark"]) if mode is None else mode == "dark"
    src = _grey(dark) if scheme == "grey" else ir
    bg, surface = src["bg"], src["surface"]
    # текст на стекле Vitreus — на фоне чуть светлее поверхности (худший случай для светлого текста); иначе — на фоне
    ref = blend(surface, "#ffffff", 0.12) if glass and dark else bg
    way = 1 if dark else -1
    how = {"wallpaper": "bold", "accent": "bold", "soft": "subtle", "vivid": "vivid", "pure": "bold",
           "pure-soft": "subtle", "pure-vivid": "vivid"}.get(scheme)
    accent = push(src["accent"], how) if how else src["accent"]
    fg = ensure(src["fg"], ref, 4.5, way)
    dim = ensure(src["dim"], ref, 4.5, way)
    accent = ensure(accent, ref, 4.5, way)
    red = ensure(src["red"], ref, 3.0, way)

    if scheme == "mono":
        # один оттенок — главный цвет обоев: фон, если в нём есть цвет, иначе акцент. Фон и поверхность еле окрашены,
        # текст — почти нейтральный, акцент — тот же тон насыщеннее
        bh, bs, _ = hsl(bg)
        h = bh if bs >= 0.12 else hsl(accent)[0]
        tone = lambda c, sat: from_hsl(h, sat, hsl(c)[2])
        bg, surface = tone(bg, min(0.25, max(bs, 0.12))), tone(surface, min(0.25, max(bs, 0.12)))
        fg, dim = tone(fg, 0.10), tone(dim, 0.16)
        accent = ensure(from_hsl(h, 0.55, hsl(accent)[2]), ref, 4.5, way)
    on_accent = "#10161a" if contrast("#10161a", accent) >= contrast("#f5f7f5", accent) else "#f5f7f5"
    s = {
        "mode": "dark" if dark else "light",
        "bg": bg, "panel": surface, "raised": blend(surface, fg, 0.08), "line": blend(bg, fg, 0.22),
        "fg": fg, "dim": dim, "accent": accent,
        "accent_lo": shade(accent, -0.10), "accent_hi": shade(accent, 0.16), "on_accent": on_accent,
        "deep": blend(bg, "#000000", 0.45), "alert": red,
        "mono": scheme in ("mono", "grey"),
        "scheme": scheme,
    }
    if scheme in ("mono", "grey"):
        # терминал одним тоном: «цвета» — ступени светлоты и насыщенности акцента, от тёмной к светлой, чтобы различались;
        # красный — настоящий (ошибки)
        h, sa, la = hsl(accent)
        lo, hi = (0.42, 0.85) if dark else (0.22, 0.55)
        steps = {"blue": (sa, lo), "magenta": (sa * 0.7, lo + (hi - lo) * 0.25), "green": (sa, la),
                 "cyan": (sa * 0.5, lo + (hi - lo) * 0.55), "yellow": (sa * 0.8, hi), "orange": (sa * 0.35, lo + (hi - lo) * 0.8)}
        for k, (ss, ll) in steps.items():
            s[k] = from_hsl(h, ss, ll)
        s["red"] = red
        syn = {"keyword": accent, "string": blend(accent, fg, 0.5), "number": s["accent_hi"] if dark else s["accent_lo"],
               "type": fg, "function": blend(fg, accent, 0.35), "property": dim, "special": red,
               "constant": blend(accent, fg, 0.3)}
    elif scheme in PURE:
        boost = PURE[scheme]
        f = (lambda c: push(c, boost)) if boost else (lambda c: c)
        for k, v in pure_hues(clusters, accent, dark).items():
            s[k] = f(v)
        s["red"] = red
        syn = {"keyword": accent, "string": s["green"], "number": s["orange"], "type": fg, "function": s["blue"],
               "property": dim, "special": red, "constant": s["cyan"]}
    else:
        boost = "lift" if scheme == "vivid" else ("subtle" if scheme == "soft" else None)
        f = (lambda c: push(c, boost)) if boost else (lambda c: c)
        s["red"], s["green"], s["yellow"] = f(ir["red"]), f(ir["green"]), f(ir["yellow"])
        for k in ("blue", "magenta", "cyan", "orange"):
            s[k] = f(like(ir["green"], HUE_DEG[k]))
        syn = {"keyword": ir["syntax_keyword"], "string": ir["syntax_string"], "number": ir["syntax_const"],
               "type": ir["syntax_type"], "function": ir["syntax_func"], "property": ir["syntax_param"],
               "special": ir["red"], "constant": ir["syntax_operator"]}
        syn = {k: f(v) for k, v in syn.items()}
    for k in HUES:
        s[k] = ensure(s[k], bg, 3.0, way)
    s["syntax"] = {k: ensure(v, bg, 4.5, way) for k, v in syn.items()}
    return s


# роли ключей colors.toml Omarchy для переворота (движок colors, режим accent): фоны — surface, текст — text, остальное — цвета
COLORS_ROLES_SURFACE = ("background", "dark_background", "darker_background", "lighter_background", "selection")
COLORS_ROLES_TEXT = ("foreground", "dark_foreground", "light_foreground", "bright_foreground", "muted")


def parse_colors_toml(text):
    """colors.toml → (режим или None, {ключ: hex})."""
    mode, cols = None, {}
    for line in text.splitlines():
        k, _, v = line.partition("=")
        k, v = k.strip(), v.strip().strip('"')
        if k == "mode":
            mode = v
        elif v.startswith("#") and len(v) == 7:
            cols[k] = v.lower()
    return mode, cols


def colors_from_variant(text, variant_mode, s, image, to_mode=None):
    """Движок colors, режим accent: colors.toml варианта облика как есть, акцент (accent, cursor, selection) — с обоев;
    to_mode другого знака — та же палитра, перевёрнутая (как flip у build.py). Порядок строк и комментарии — варианта."""
    _, cols = parse_colors_toml(text)
    to_mode = to_mode or variant_mode
    to_dark = to_mode == "dark"
    if to_mode != variant_mode and "background" in cols:
        roles = {k: ("surface" if k in COLORS_ROLES_SURFACE else "text" if k in COLORS_ROLES_TEXT else "color")
                 for k in cols}
        cols = flip(cols, roles, to_mode, "background")
    bg = cols.get("background", s["bg"])
    acc = flip_color(s["accent"], "color", to_dark, bg) if to_mode != variant_mode else ensure(s["accent"], bg, 3.0,
                                                                                               1 if to_dark else -1)
    cols.update(accent=acc, cursor=acc, selection=blend(bg, acc, 0.3))
    out, seen = [f"# Сгенерировано из обоев {os.path.basename(str(image))}: палитра варианта, акцент с обоев"
                 + (f", переведено в {to_mode}" if to_mode != variant_mode else "")], set()
    for line in text.splitlines():
        k = line.partition("=")[0].strip()
        if k == "mode":
            out.append(f'mode = "{to_mode}"'); seen.add(k)
        elif k in cols and "=" in line:
            out.append(f'{k} = "{cols[k]}"'); seen.add(k)
        elif not line.startswith("# Сгенерировано") and not (line.startswith("#") and len(out) == 1):
            out.append(line)
    if "mode" not in seen:
        out.insert(1, f'mode = "{to_mode}"')
    return "\n".join(out).rstrip("\n") + "\n", acc


def colors_toml(s, image, scheme):
    """Движок colors: один colors.toml Omarchy из слотов (остальное — шаблоны Omarchy)."""
    dark = s["mode"] == "dark"
    ext = "#ffffff" if dark else "#000000"
    p = {
        "accent": s["accent"], "cursor": s["accent"], "selection": blend(s["bg"], s["accent"], 0.3), "muted": s["dim"],
        "background": s["bg"], "dark_background": blend(s["bg"], s["deep"], 0.5), "darker_background": s["deep"],
        "lighter_background": s["panel"],
        "foreground": s["fg"], "dark_foreground": s["dim"], "light_foreground": blend(s["fg"], s["dim"], 0.3),
        "bright_foreground": blend(s["fg"], ext, 0.5),
    }
    order = ["red", "orange", "yellow", "green", "cyan", "blue", "magenta"]
    for k in order:
        p[k] = s[k]
        p[f"bright_{k}"] = blend(s[k], ext, 0.25)
    p["brown"] = blend(s["orange"], s["bg"], 0.35)
    keys = ["accent", "cursor", "selection", "muted", "", "background", "dark_background", "darker_background",
            "lighter_background", "", "foreground", "dark_foreground", "light_foreground", "bright_foreground", "",
            *order, "brown", "", *(f"bright_{k}" for k in order if k != "orange")]
    out = [f"# Сгенерировано из обоев {os.path.basename(str(image))} (Iris, режим {scheme})", f'mode = "{s["mode"]}"', ""]
    out += [f'{k} = "{p[k]}"' if k else "" for k in keys]
    return "\n".join(out) + "\n"
