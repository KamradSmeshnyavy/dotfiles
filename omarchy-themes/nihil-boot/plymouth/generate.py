#!/usr/bin/env python3
# Генератор загрузочной анимации Plymouth для темы NIHIL (Arch Linux LED-матрица).
# Адаптировано из Nihil-Shell (theme/plymouth.py и tools/snowflake.py),
# Copyright (c) 2026 Pol Iglesias, лицензия MIT.
#
# Фазы анимации:
#   intro (36 кадров) — светодиоды логотипа Arch зажигаются от центра к краям с короткой вспышкой;
#   loop  (60 кадров) — диагональная полоса света (в духе Glyph) пробегает по горящей матрице.
#
# Примеры:
#   python3 generate.py .
#   python3 generate.py /usr/share/plymouth/themes/nihil --pitch 9
#   python3 generate.py . --font /usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf --write-grid arch-29.txt

import argparse
import math
import os
import random

from PIL import Image, ImageDraw, ImageFont

ARCH_GLYPH = "\U000F08C7"  # 󰣇 (Arch Linux в Nerd Fonts)
INTRO = 36
LOOP = 60
SUB = 32


def sample_glyph_grid(font_path: str, size: int = 29, glyph: str = ARCH_GLYPH) -> list[str]:
    """Сэмплирует глиф из Nerd Font в квадратную матрицу покрытий 0..9."""
    probe = ImageFont.truetype(font_path, 1000)
    left, top, right, bottom = probe.getbbox(glyph)
    span = max(right - left, bottom - top, 1)
    font = ImageFont.truetype(font_path, round(1000 * size * SUB * 0.90 / span))
    left, top, right, bottom = font.getbbox(glyph)

    canvas = Image.new("L", (size * SUB, size * SUB), 0)
    ox = (size * SUB - (right - left)) / 2 - left
    oy = (size * SUB - (bottom - top)) / 2 - top
    ImageDraw.Draw(canvas).text((ox, oy), glyph, font=font, fill=255)
    cells = canvas.resize((size, size), Image.Resampling.BOX)
    return [
        "".join(str(min(9, round(cells.getpixel((x, y)) / 255 * 9))) for x in range(size))
        for y in range(size)
    ]


def load_grid(path: str) -> list[list[float]]:
    with open(path, encoding="utf-8") as fh:
        rows = [line.strip() for line in fh if line.strip()]
    return [[int(ch) / 9.0 for ch in row] for row in rows]


def render_frame(grid: list[list[float]], pitch: int, levels_fn, supersample: int = 4) -> Image.Image:
    n = len(grid)
    size = n * pitch
    s = supersample
    # Рендерим на чёрном фоне (#000000) в градациях серого ('L') для компактных PNG и чистого OLED-чёрного.
    img = Image.new("L", (size * s, size * s), 0)
    draw = ImageDraw.Draw(img)
    for j in range(n):
        for i in range(n):
            cx = (i + 0.5) * pitch * s
            cy = (j + 0.5) * pitch * s
            level, scale = levels_fn(i, j)
            if level <= 0:
                r = 0.14 * pitch * s
                draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=28)
                continue
            r = (0.22 + 0.20 * scale) * pitch * s
            g = max(0, min(255, round(40 + 215 * level)))
            draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=g)
    return img.resize((size, size), Image.Resampling.LANCZOS)


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    ap = argparse.ArgumentParser(description="Генератор кадров Plymouth для темы NIHIL")
    ap.add_argument("outdir", nargs="?", default=here, help="Каталог для сохранения logo.png и frame-*.png")
    ap.add_argument("--grid", default=os.path.join(here, "arch-29.txt"), help="Путь к текстовой сетке 0..9")
    ap.add_argument("--font", default="", help="Опционально: TTF Nerd Font для пересоздания сетки глифа")
    ap.add_argument("--glyph", default=ARCH_GLYPH, help="Символ для сэмплирования при --font")
    ap.add_argument("--size", type=int, default=29, help="Размер сетки при --font (по умолчанию 29)")
    ap.add_argument("--write-grid", default="", help="Сохранить сгенерированную сетку в указанный файл")
    ap.add_argument("--pitch", type=int, default=9, help="Шаг светодиодов в пикселях (по умолчанию 9)")
    args = ap.parse_args()

    if args.font:
        rows = sample_glyph_grid(args.font, args.size, args.glyph)
        target_grid = args.write_grid or args.grid
        os.makedirs(os.path.dirname(os.path.abspath(target_grid)), exist_ok=True)
        with open(target_grid, "w", encoding="utf-8") as fh:
            fh.write("\n".join(rows) + "\n")
        grid_path = target_grid
    else:
        grid_path = args.grid

    grid = load_grid(grid_path)
    n = len(grid)
    c = (n - 1) / 2.0
    rng = random.Random(1)

    lit = [[1.0 if v >= 0.45 else (0.42 if v >= 0.18 else 0.0) for v in row] for row in grid]
    arrival = [
        [min(0.95, math.hypot(i - c, j - c) / (c * 1.45) + 0.12 * rng.random()) for i in range(n)]
        for j in range(n)
    ]

    os.makedirs(args.outdir, exist_ok=True)

    for f in range(INTRO):
        t = f / (INTRO - 1)

        def intro_levels(i: int, j: int, t_now: float = t):
            if lit[j][i] == 0.0 or arrival[j][i] > t_now:
                return 0.0, 0.0
            age = (t_now - arrival[j][i]) * (INTRO - 1)
            flash = max(0.0, 1.0 - age / 4.0)
            return min(1.0, lit[j][i] * 0.86 + 0.50 * flash), 0.75 + 0.25 * flash

        render_frame(grid, args.pitch, intro_levels).save(
            os.path.join(args.outdir, f"frame-{f}.png"), optimize=True
        )

    for f in range(LOOP):
        pos = -0.35 + 1.70 * f / LOOP

        def loop_levels(i: int, j: int, p_now: float = pos):
            if lit[j][i] == 0.0:
                return 0.0, 0.0
            d = (i + j) / (2.0 * (n - 1)) - p_now
            band = math.exp(-((d / 0.09) ** 2))
            return min(1.0, lit[j][i] * 0.86 + 0.14 * band), 0.75 + 0.25 * band

        render_frame(grid, args.pitch, loop_levels).save(
            os.path.join(args.outdir, f"frame-{INTRO + f}.png"), optimize=True
        )

    render_frame(
        grid,
        args.pitch,
        lambda i, j: (lit[j][i] * 0.86, 0.75) if lit[j][i] > 0.0 else (0.0, 0.0),
    ).save(os.path.join(args.outdir, "logo.png"), optimize=True)


if __name__ == "__main__":
    main()
