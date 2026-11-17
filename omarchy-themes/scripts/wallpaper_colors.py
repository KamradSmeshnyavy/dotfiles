"""Цвета из обоев: matugen (Material You) + кадр из живых обоев. Общий код omarchy-wallpaper-theme и omarchy-rice-dynamic.

seed(image, scheme, mode) → словарь ролей Material в hex: primary, on_primary, surface, surface_container*,
outline, outline_variant, error, tertiary, … и ANSI-цвета (red, green, …, on_red_container, …), смещённые к цвету обоев.
"""
import colorsys
import json
import subprocess
import tempfile
from pathlib import Path

VIDEO = {".mp4", ".webm", ".mkv", ".mov", ".m4v", ".gif"}
IMAGE = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}

SCHEMES = ["tonal-spot", "content", "expressive", "fidelity", "fruit-salad", "monochrome",
           "neutral", "rainbow", "vibrant"]

# Цвета терминала: эталонные оттенки, matugen смещает их к цвету обоев (blend)
ANSI = {
    "red": "#e05561", "orange": "#e8875a", "yellow": "#e5c07b", "green": "#7fbf6a",
    "cyan": "#56b6c2", "blue": "#61afef", "magenta": "#c678dd", "brown": "#a9765a",
}

# Иконки Yaru по оттенку акцента (hue в градусах → вариант)
YARU = [(15, "red"), (40, "wartybrown"), (65, "yellow"), (90, "olive"), (150, "sage"),
        (190, "prussiangreen"), (250, "blue"), (290, "purple"), (335, "magenta"), (360, "red")]


class Error(Exception):
    pass


def is_media(path):
    return Path(path).suffix.lower() in VIDEO | IMAGE


def still(image, tmp):
    """Путь к картинке для matugen: сами обои или представительный кадр живых обоев (ffmpeg thumbnail)."""
    image = Path(image)
    if image.suffix.lower() not in VIDEO:
        return image
    frame = Path(tmp) / "frame.png"
    for seek in (["-ss", "2"], []):
        r = subprocess.run(["ffmpeg", "-nostdin", "-loglevel", "error", "-y", *seek, "-i", str(image),
                            "-vf", "thumbnail=60,scale=1280:-2", "-frames:v", "1", str(frame)],
                           capture_output=True, text=True)
        if r.returncode == 0 and frame.is_file():
            return frame
    raise Error(f"не удалось взять кадр из {image.name} (нужен ffmpeg)")


def matugen(image, scheme, mode, prefer="saturation", contrast=None):
    with tempfile.TemporaryDirectory() as tmp:
        conf = Path(tmp) / "matugen.toml"
        lines = ["[templates]", "", "[config.custom_colors]"]
        lines += [f'{k} = {{ color = "{v}", blend = true }}' for k, v in ANSI.items()]
        conf.write_text("\n".join(lines) + "\n")
        cmd = ["matugen", "image", str(still(image, tmp)), "-c", str(conf), "-m", mode, "-t", f"scheme-{scheme}",
               "--prefer", prefer, "--json", "hex", "--dry-run", "-q"]
        if contrast is not None:
            cmd += ["--contrast", str(contrast)]
        out = subprocess.run(cmd, capture_output=True, text=True)
    if out.returncode != 0:
        raise Error(f"matugen: {out.stderr.strip()}")
    colors = json.loads(out.stdout)["colors"]
    return {k: v[mode]["color"] for k, v in colors.items()}


def iris(image, dark=-1, glass=False, clusters=False):
    """Цвета Iris (iris_colors.generate): dark 1 / 0 / -1 (решает по обоям), glass — фон под прозрачность (как Vitreus).
    clusters — ещё и реальные цвета картинки (кластеры Iris: h в градусах, s, l, sig — заметность): (тема, кластеры)."""
    import iris_colors
    with tempfile.TemporaryDirectory() as tmp:
        src = still(image, tmp)
        img = iris_colors.load_image(str(src))
        try:
            theme = iris_colors.build_theme(img, dark, glass, False)
        except Exception as e:  # noqa: BLE001 — Iris падает на вырожденных картинках; тогда его же запасная тема
            print(f"iris: {e}", file=__import__("sys").stderr)
            theme = iris_colors.fallback(dark != 0)
        if not clusters:
            return theme
        try:
            return theme, iris_colors.sample_palette(img)
        except Exception:  # noqa: BLE001
            return theme, []


def mix(a, b, t):
    pa = [int(a[i:i + 2], 16) for i in (1, 3, 5)]
    pb = [int(b[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(x * (1 - t) + y * t):02x}" for x, y in zip(pa, pb))


def yaru(hex_color, mode):
    r, g, b = (int(hex_color[i:i + 2], 16) / 255 for i in (1, 3, 5))
    h, _, s = colorsys.rgb_to_hls(r, g, b)
    name = "Yaru" if s < 0.15 else "Yaru-" + next(v for limit, v in YARU if h * 360 < limit)
    if mode == "dark":
        name += "-dark"
    return name if (Path("/usr/share/icons") / name).is_dir() else ""


def material_palette(m, mode):
    """Палитра colors.toml Omarchy из ролей Material (движок material)."""
    dark = mode == "dark"
    extreme = "#000000" if dark else "#ffffff"
    p = {
        "accent": m["primary"],
        "cursor": m["primary"],
        "selection": m["surface_container_highest"],
        "muted": m["outline_variant"] if dark else m["outline"],
        "background": m["surface"],
        "dark_background": mix(m["surface"], m["surface_container_lowest"], 0.5),
        "darker_background": m["surface_container_lowest"],
        "lighter_background": m["surface_container_high"],
        "foreground": m["on_surface"],
        "dark_foreground": m["outline"] if dark else m["on_surface_variant"],
        "light_foreground": m["on_surface_variant"] if not dark else m["on_surface"],
        "bright_foreground": mix(m["on_surface"], "#ffffff" if dark else "#000000", 0.5),
    }
    for name in ANSI:
        p[name] = m[name]
        # яркий вариант: на тон светлее в тёмной теме, на тон темнее в светлой
        p[f"bright_{name}"] = m[f"on_{name}_container"] if dark else mix(m[name], extreme, 0.25)
    del p["bright_orange"], p["bright_brown"]
    return p


def colors_toml(p, mode, image, scheme):
    order = ["accent", "cursor", "selection", "muted", "", "background", "dark_background",
             "darker_background", "lighter_background", "", "foreground", "dark_foreground",
             "light_foreground", "bright_foreground", "", *ANSI, "",
             *(f"bright_{k}" for k in ANSI if k not in ("orange", "brown"))]
    out = [f"# Сгенерировано из обоев {Path(image).name} (matugen scheme-{scheme})",
           f'mode = "{mode}"', ""]
    out += [f'{k} = "{p[k]}"' if k else "" for k in order]
    return "\n".join(out) + "\n"
