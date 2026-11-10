"""
Общая перекраска палитры Telegram (Desktop и Android) в цвета темы Omarchy.

Исходные значения — светлая тема Telegram по умолчанию: серые идут на шкалу фон…текст темы
(Palette.gray), цветные — на ближайший по оттенку цвет темы, ключи исходящих сообщений — на акцент.
"""
from theme_palette import hls


def split_alpha(v):
    """'#rrggbbaa' → ('#rrggbb', 'aa'); без альфы — ('#rrggbb', '')."""
    v = v.lstrip("#")
    return "#" + v[:6], (v[6:8] if len(v) == 8 else "")


def remap(p, value, outgoing=False):
    """Значение светлой темы '#rrggbb[aa]' → цвет темы p в том же формате."""
    base, alpha = split_alpha(value)
    if alpha:
        # полупрозрачные: тени и затемнения (чёрный/белый) оставить, цветные — перекрасить
        h, l, s = hls(base)
        if s < 0.15:
            return value
        return p.by_hue(base) + alpha
    h, l, s = hls(base)
    if s < 0.15 or (l > 0.95 and s < 0.5):
        return p.gray(l)
    target = p.accent if outgoing else p.by_hue(base)
    if l > 0.88:  # бледная подложка (наведение, выделение)
        return p.tint(target, 0.14)
    if l > 0.75:
        return p.tint(target, 0.32)
    return target
