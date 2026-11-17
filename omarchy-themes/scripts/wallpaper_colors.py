"""Цвета из обоев для omarchy-rice-dynamic: Iris (iris_colors.py) по кадру обоев (у видео / GIF — представительный кадр
ffmpeg), иконки Yaru по оттенку акцента. Раскладка по слотам и режимы — ../nothing/dynamic_map.py."""
import colorsys
import subprocess
import tempfile
from pathlib import Path

VIDEO = {".mp4", ".webm", ".mkv", ".mov", ".m4v", ".gif"}
IMAGE = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}

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
