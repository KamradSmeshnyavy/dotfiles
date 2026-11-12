"""
Стиль Customizer для генераторов тем приложений: ~/.config/omarchy/style.json (пишет Customizer →
Пресеты → Стиль) и форма каждого стиля. Общий для omarchy-style-form и omarchy-kbptr-theme.

OMARCHY_STYLE_JSON перекрывает путь к style.json (для проверки без правки настоящего файла).
"""
import json
import os
from pathlib import Path

HOME = Path.home()
STYLE_JSON = Path(os.environ.get("OMARCHY_STYLE_JSON") or HOME / ".config/omarchy/style.json")
FONTS_JSON = HOME / ".config/omarchy/fonts.json"

# Форма стилей: радиус, рамка, тени. bevel — 3D-кант (светлый сверху-слева, тёмный снизу-справа).
FORMS = {
    "dotmatrix":    {"r": 0,  "border": 1, "shadow": "none",  "pad": 10, "cursor": "block"},
    "flat":     {"r": 0,  "border": 1, "shadow": "none",  "pad": 8,  "cursor": "block"},
    "glass":    {"r": 12, "border": 1, "shadow": "soft",  "pad": 14, "cursor": "beam", "glass": True},
    "liquid":   {"r": 18, "border": 1, "shadow": "soft",  "pad": 14, "cursor": "beam", "glass": True},
    "fluent":   {"r": 8,  "border": 1, "shadow": "soft",  "pad": 12, "cursor": "beam"},
    "paper":    {"r": 4,  "border": 1, "shadow": "paper", "pad": 16, "cursor": "underline", "texture": True},
    "neumorph": {"r": 14, "border": 0, "shadow": "neu",   "pad": 16, "cursor": "beam"},
    "brutal":   {"r": 0,  "border": 2, "shadow": "hard",  "pad": 10, "cursor": "block"},
    "retro":    {"r": 0,  "border": 2, "shadow": "bevel", "pad": 6,  "cursor": "block"},
    "neon":     {"r": 6,  "border": 1, "shadow": "glow",  "pad": 12, "cursor": "beam"},
}


def _read(path):
    try:
        data = json.loads(Path(path).read_text())
        return data if isinstance(data, dict) else {}
    except (OSError, ValueError):
        return {}


def tokens():
    """Весь style.json (id, material, typeface, …); нет файла — пустой словарь."""
    return _read(STYLE_JSON)


def style():
    """(id стиля, форма из FORMS или None)."""
    sid = str(tokens().get("id") or "")
    return sid, FORMS.get(sid)


def font_profile():
    """~/.config/omarchy/fonts.json (omarchy-font-profile): profile, sans, mono, title."""
    return _read(FONTS_JSON)
