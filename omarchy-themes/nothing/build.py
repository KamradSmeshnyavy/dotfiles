#!/usr/bin/env python3
"""Собирает три варианта темы nothing (signal, cmf, glyph) из palettes.py.

Каждое приложение получает свою тему по ролям палитры — шаблоны Omarchy (default/themed/*.tpl) не
используются: файл, лежащий в каталоге темы, Omarchy не перезаписывает.

Крупные структурированные темы (yazi-flavor с tmTheme, nushell, lla, rmpc, glow) берут раскладку из
catppuccin-mocha-efter и перекрашиваются по таблице MOCHA → роль.

    python3 build.py            # все варианты
    python3 build.py signal     # один
"""
import json
import os
import re
import sys

from palettes import PALETTES, check

HERE = os.path.dirname(os.path.abspath(__file__))
EFTER = os.path.join(HERE, "..", "catppuccin-mocha-efter")
DOTMATRIX = os.path.join(HERE, "..", "dot-matrix")


# ── Цветовые утилиты ──────────────────────────────────────────────────────

def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb2hex(r, g, b):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(v))) for v in (r, g, b))


def mix(a, b, t):
    """t = доля b."""
    ra, rb = hex2rgb(a), hex2rgb(b)
    return rgb2hex(*(x + (y - x) * t for x, y in zip(ra, rb)))


def bare(h):
    return h.lstrip("#")


def ansi(p):
    """16 цветов терминала. Тёмные: color0 чуть светлее фона, 7/15 — светлые; светлая — наоборот."""
    if p.get("ansi16"):
        # Свои 16 цветов терминала как есть (glyph-rice: пастель только терминалу, интерфейс — серый и красный).
        return list(p["ansi16"])
    dark = p["mode"] == "dark"
    yellow = p.get("ansi_yellow", p["type"])
    base = {
        "black": p["line"] if dark else "#3a3a38",
        "red": p["error"],
        # Тональные: «зелёный» (добавленное в git, ok) — самый светлый тон, выделяется яркостью.
        "green": p["ok"] if p.get("tonal") else p["string"],
        "yellow": yellow,
        "blue": p["function"],
        "magenta": p["special"],
        "cyan": p["property"],
        "white": p["dim"] if dark else p["line"],
    }
    lift = (lambda c: mix(c, "#ffffff", 0.22)) if dark else (lambda c: mix(c, "#000000", 0.18))
    bright = {k: lift(v) for k, v in base.items()}
    bright["black"] = p["comment"]
    bright["white"] = "#ffffff" if dark else "#bdbdb8"
    order = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
    return [base[k] for k in order] + [bright[k] for k in order]


# ── colors.toml ───────────────────────────────────────────────────────────

def colors_toml(p):
    a = ansi(p)
    dark = p["mode"] == "dark"
    rows = [
        f'# {p["title"]} — omarchy-themes/nothing (палитра: palettes.py, сборка: build.py).',
        "# Слоты совпадают с ролями: green = строки, blue = функции, red = ошибки и т.д.",
        f'mode = "{p["mode"]}"',
        "",
        f'accent = "{p["accent"]}"',
        f'cursor = "{p["accent"]}"',
        f'selection = "{p["selection"]}"',
        f'selection_foreground = "{p["fg"]}"',
        f'selection_background = "{p["selection"]}"',
        f'muted = "{p["comment"]}"',
        "",
        f'background = "{p["bg"]}"',
        f'dark_background = "{p["panel"]}"',
        f'darker_background = "{p["bg"] if dark else p["panel"]}"',
        f'lighter_background = "{p["raised"]}"',
        "",
        f'foreground = "{p["fg"]}"',
        f'dark_foreground = "{p["comment"]}"',
        f'light_foreground = "{p["dim"]}"',
        f'bright_foreground = "{"#ffffff" if dark else "#000000"}"',
        "",
        f'hyprland_active_border = "{p["accent"]}"',
        f'hyprland_inactive_border = "{p["line"]}"',
        "",
        f'red = "{a[1]}"',
        f'yellow = "{a[3]}"',
        f'orange = "{p["number"]}"',
        f'green = "{a[2]}"',
        f'cyan = "{a[6]}"',
        f'blue = "{a[4]}"',
        f'magenta = "{a[5]}"',
        f'brown = "{mix(p["number"], p["bg"], 0.45)}"',
        "",
        f'bright_red = "{a[9]}"',
        f'bright_yellow = "{a[11]}"',
        f'bright_green = "{a[10]}"',
        f'bright_cyan = "{a[14]}"',
        f'bright_blue = "{a[12]}"',
        f'bright_magenta = "{a[13]}"',
    ]
    return "\n".join(rows) + "\n"


# ── Терминалы ─────────────────────────────────────────────────────────────

def kitty(p):
    a = ansi(p)
    out = [
        f"# {p['title']} — kitty",
        f"foreground {p['fg']}",
        f"background {p['bg']}",
        f"selection_foreground {p['fg']}",
        f"selection_background {p['selection']}",
        f"cursor {p['accent']}",
        f"cursor_text_color {p['on_accent']}",
        f"url_color {p['function']}",
        f"active_border_color {p['accent']}",
        f"inactive_border_color {p['line']}",
        f"bell_border_color {p['warn']}",
        "wayland_titlebar_color system",
        f"active_tab_foreground {p['fg']}",
        f"active_tab_background {p['raised']}",
        f"inactive_tab_foreground {p['comment']}",
        f"inactive_tab_background {p['bg']}",
        f"tab_bar_background {p['bg']}",
        f"mark1_foreground {p['on_accent']}",
        f"mark1_background {p['accent']}",
        f"mark2_foreground {p['bg']}",
        f"mark2_background {p['type']}",
        f"mark3_foreground {p['bg']}",
        f"mark3_background {p['function']}",
    ]
    out += [f"color{i} {c}" for i, c in enumerate(a)]
    return "\n".join(out) + "\n"


def ghostty(p):
    a = ansi(p)
    out = [
        f"# {p['title']} — ghostty",
        f"background = {p['bg']}",
        f"foreground = {p['fg']}",
        f"cursor-color = {p['accent']}",
        f"cursor-text = {p['on_accent']}",
        f"selection-background = {p['selection']}",
        f"selection-foreground = {p['fg']}",
    ]
    out += [f"palette = {i}={c}" for i, c in enumerate(a)]
    return "\n".join(out) + "\n"


def alacritty(p):
    a = ansi(p)
    names = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
    out = [
        f"# {p['title']} — alacritty",
        "[colors.primary]", f'background = "{p["bg"]}"', f'foreground = "{p["fg"]}"', "",
        "[colors.cursor]", f'text = "{p["on_accent"]}"', f'cursor = "{p["accent"]}"', "",
        "[colors.vi_mode_cursor]", f'text = "{p["bg"]}"', f'cursor = "{p["function"]}"', "",
        "[colors.search.matches]", f'foreground = "{p["bg"]}"', f'background = "{p["type"]}"', "",
        "[colors.search.focused_match]", f'foreground = "{p["on_accent"]}"', f'background = "{p["accent"]}"', "",
        "[colors.selection]", f'text = "{p["fg"]}"', f'background = "{p["selection"]}"', "",
        "[colors.normal]",
    ]
    out += [f'{n} = "{a[i]}"' for i, n in enumerate(names)]
    out += ["", "[colors.bright]"]
    out += [f'{n} = "{a[i + 8]}"' for i, n in enumerate(names)]
    return "\n".join(out) + "\n"


def foot(p):
    a = ansi(p)
    section = "colors-dark" if p["mode"] == "dark" else "colors-light"
    out = [
        f"[{section}]",
        f"foreground={bare(p['fg'])}", f"background={bare(p['bg'])}",
        f"selection-foreground={bare(p['fg'])}", f"selection-background={bare(p['selection'])}",
        f"cursor={bare(p['on_accent'])} {bare(p['accent'])}",
    ]
    out += [f"regular{i}={bare(c)}" for i, c in enumerate(a[:8])]
    out += [f"bright{i}={bare(c)}" for i, c in enumerate(a[8:])]
    return "\n".join(out) + "\n"


# ── Hyprland, btop, cava, helix ──────────────────────────────────────────

def hyprland(p):
    return f"""-- {p['title']}: тонкая рамка — активная в сигнальном цвете, неактивная — линия.
local active_border_color = "rgb({bare(p['accent'])})"
local inactive_border_color = "rgb({bare(p['line'])})"

hl.config({{
	general = {{
		col = {{
			active_border = active_border_color,
			inactive_border = inactive_border_color,
		}},
	}},

	group = {{
		col = {{
			border_active = active_border_color,
			border_inactive = inactive_border_color,
		}},
	}},
}})
"""


def btop(p):
    kv = {
        "main_bg": p["bg"], "main_fg": p["fg"], "title": p["fg"], "hi_fg": p["accent"],
        "selected_bg": p["raised"], "selected_fg": p["fg"], "inactive_fg": p["comment"],
        "graph_text": p["dim"], "meter_bg": p["line"], "proc_misc": p["dim"],
        "cpu_box": p["line"], "mem_box": p["line"], "net_box": p["line"], "proc_box": p["line"],
        "div_line": p["line"],
        "temp_start": p["string"], "temp_mid": p["warn"], "temp_end": p["error"],
        "cpu_start": p["dim"], "cpu_mid": p["fg"], "cpu_end": p["accent"],
        "free_start": p["property"], "free_mid": p["property"], "free_end": p["function"],
        "cached_start": p["function"], "cached_mid": p["function"], "cached_end": p["special"],
        "available_start": p["type"], "available_mid": p["number"], "available_end": p["number"],
        "used_start": p["dim"], "used_mid": p["fg"], "used_end": p["accent"],
        "download_start": p["property"], "download_mid": p["function"], "download_end": p["special"],
        "upload_start": p["type"], "upload_mid": p["number"], "upload_end": p["accent"],
        "process_start": p["dim"], "process_mid": p["fg"], "process_end": p["accent"],
    }
    lines = [f"# {p['title']} — btop: графики от текста к сигнальному цвету, температура — зелёный → янтарь → красный"]
    lines += [f'theme[{k}]="{v}"' for k, v in kv.items()]
    return "\n".join(lines) + "\n"


def cava(p):
    stops = [p["dim"], p["fg"], p["property"], p["function"], p["special"], p["keyword"], p["number"], p["accent"]]
    out = ["[color]", f"background = '{p['bg']}'", f"foreground = '{p['fg']}'", "gradient = 1",
           f"gradient_count = {len(stops)}"]
    out += [f"gradient_color_{i + 1} = '{c}'" for i, c in enumerate(stops)]
    return "\n".join(out) + "\n"


def helix(p):
    pal = {k: p[k] for k in ["bg", "panel", "raised", "line", "fg", "dim", "comment", "accent", "selection",
                             "keyword", "string", "number", "type", "function", "property", "special",
                             "constant", "error", "warn", "info", "hint", "ok", "on_accent"]}
    rows = {
        "ui.background": {"bg": "bg"}, "ui.text": "fg", "ui.text.focus": {"fg": "fg", "bg": "raised"},
        "ui.cursor": {"fg": "on_accent", "bg": "dim"}, "ui.cursor.primary": {"fg": "on_accent", "bg": "accent"},
        "ui.cursor.match": {"bg": "line", "modifiers": ["bold"]},
        "ui.selection": {"bg": "raised"}, "ui.selection.primary": {"bg": "selection"},
        "ui.linenr": "comment", "ui.linenr.selected": "fg", "ui.cursorline.primary": {"bg": "panel"},
        "ui.statusline": {"fg": "dim", "bg": "panel"}, "ui.statusline.inactive": {"fg": "comment", "bg": "panel"},
        "ui.statusline.normal": {"fg": "on_accent", "bg": "accent", "modifiers": ["bold"]},
        "ui.statusline.insert": {"fg": "bg", "bg": "string", "modifiers": ["bold"]},
        "ui.statusline.select": {"fg": "bg", "bg": "special", "modifiers": ["bold"]},
        "ui.popup": {"bg": "panel"}, "ui.window": "line", "ui.help": {"fg": "fg", "bg": "panel"},
        "ui.menu": {"fg": "fg", "bg": "panel"}, "ui.menu.selected": {"bg": "raised"},
        "ui.virtual.whitespace": "line", "ui.virtual.ruler": {"bg": "panel"}, "ui.virtual.inlay-hint": "comment",
        "comment": {"fg": "comment", "modifiers": ["italic"]}, "keyword": "keyword", "keyword.function": "keyword",
        "string": "string", "string.regexp": "special", "constant": "constant", "constant.numeric": "number",
        "constant.builtin.boolean": "number", "constant.character.escape": "special",
        "type": "type", "type.builtin": "type", "function": "function", "function.macro": "special",
        "variable": "fg", "variable.parameter": "fg", "variable.other.member": "property",
        "variable.builtin": "keyword", "attribute": "special", "namespace": "type", "tag": "keyword",
        "label": "special", "operator": "dim", "punctuation": "dim", "constructor": "type",
        "markup.heading": {"fg": "accent", "modifiers": ["bold"]}, "markup.bold": {"modifiers": ["bold"]},
        "markup.italic": {"modifiers": ["italic"]}, "markup.link.url": {"fg": "function", "modifiers": ["underlined"]},
        "markup.raw": "string", "markup.list": "keyword", "markup.quote": "dim",
        "diff.plus": "ok", "diff.minus": "error", "diff.delta": "info",
        "error": "error", "warning": "warn", "info": "info", "hint": "hint",
        "diagnostic.error": {"underline": {"style": "curl", "color": "error"}},
        "diagnostic.warning": {"underline": {"style": "curl", "color": "warn"}},
    }
    out = [f"# {p['title']} — helix"]
    for k, v in rows.items():
        if isinstance(v, str):
            out.append(f'"{k}" = "{v}"')
        else:
            parts = []
            for kk, vv in v.items():
                if isinstance(vv, list):
                    parts.append(f'{kk} = [{", ".join(json.dumps(x) for x in vv)}]')
                elif isinstance(vv, dict):
                    parts.append(f'{kk} = {{ ' + ", ".join(f'{a} = "{b}"' for a, b in vv.items()) + " }")
                else:
                    parts.append(f'{kk} = "{vv}"')
            out.append(f'"{k}" = {{ ' + ", ".join(parts) + " }")
    out.append("")
    out.append("[palette]")
    out += [f'{k} = "{v}"' for k, v in pal.items()]
    return "\n".join(out) + "\n"


# ── TUI-слоты (apps/) ─────────────────────────────────────────────────────

def lazygit(p):
    return f"""# {p['title']} — lazygit
gui:
  theme:
    activeBorderColor: ["{p['accent']}", bold]
    inactiveBorderColor: ["{p['line']}"]
    searchingActiveBorderColor: ["{p['type']}", bold]
    optionsTextColor: ["{p['function']}"]
    selectedLineBgColor: ["{p['raised']}"]
    inactiveViewSelectedLineBgColor: ["{p['panel']}"]
    cherryPickedCommitFgColor: ["{p['special']}"]
    cherryPickedCommitBgColor: ["{p['raised']}"]
    markedBaseCommitFgColor: ["{p['function']}"]
    markedBaseCommitBgColor: ["{p['raised']}"]
    unstagedChangesColor: ["{p['error']}"]
    defaultFgColor: ["{p['fg']}"]
  authorColors:
    "*": "{p['property']}"
"""


def gitui(p):
    kv = {
        "selected_tab": p["accent"], "command_fg": p["fg"], "selection_bg": p["raised"],
        "selection_fg": p["fg"], "cmdbar_bg": p["panel"], "cmdbar_extra_lines_bg": p["panel"],
        "disabled_fg": p["comment"], "diff_line_add": p["ok"], "diff_line_delete": p["error"],
        "diff_file_added": p["ok"], "diff_file_removed": p["error"], "diff_file_moved": p["special"],
        "diff_file_modified": p["number"], "commit_hash": p["special"], "commit_time": p["function"],
        "commit_author": p["property"], "danger_fg": p["error"], "push_gauge_bg": p["accent"],
        "push_gauge_fg": p["on_accent"], "tag_fg": p["type"], "branch_fg": p["string"],
    }
    return "(\n" + ",\n".join(f'    {k}: Some("{v}")' for k, v in kv.items()) + "\n)\n"


def atuin(p):
    return f"""[theme]
name = "omarchy"

[colors]
AlertInfo = "{p['ok']}"
AlertWarn = "{p['warn']}"
AlertError = "{p['error']}"
Annotation = "{p['function']}"
Base = "{p['fg']}"
Guidance = "{p['comment']}"
Important = "{p['accent']}"
Title = "{p['fg']}"
"""


def television(p):
    return f"""# {p['title']} — television
background = '{p['bg']}'
border_fg = '{p['line']}'
text_fg = '{p['fg']}'
dimmed_text_fg = '{p['comment']}'
input_text_fg = '{p['fg']}'
result_count_fg = '{p['accent']}'
result_name_fg = '{p['function']}'
result_line_number_fg = '{p['number']}'
result_value_fg = '{p['dim']}'
selection_fg = '{p['fg']}'
selection_bg = '{p['raised']}'
match_fg = '{p['accent']}'
preview_title_fg = '{p['type']}'
channel_mode_fg = '{p['on_accent']}'
channel_mode_bg = '{p['accent']}'
remote_control_mode_fg = '{p['bg']}'
remote_control_mode_bg = '{p['string']}'
action_picker_mode_fg = '{p['bg']}'
action_picker_mode_bg = '{p['function']}'
"""


def fzf(p):
    return (f"# {p['title']} — fzf: совпадения в сигнальном цвете, выбранная строка — приподнятый фон\n"
            f"--color=bg:{p['bg']},bg+:{p['raised']},fg:{p['dim']},fg+:{p['fg']}\n"
            f"--color=hl:{p['accent']},hl+:{p['accent']},info:{p['comment']},prompt:{p['accent']}\n"
            f"--color=pointer:{p['accent']},marker:{p['string']},spinner:{p['function']},header:{p['type']}\n"
            f"--color=border:{p['line']},label:{p['fg']},query:{p['fg']},selected-bg:{p['selection']}\n")


def tmux(p):
    om = {
        "bg": p["bg"], "fg": p["fg"], "black": p["line"], "white": p["dim"], "red": p["error"],
        "green": p["string"], "yellow": p["type"], "blue": p["function"], "magenta": p["special"],
        "cyan": p["property"], "overlay0": p["comment"], "overlay1": p["dim"], "rosewater": p["constant"],
        "lavender": p["accent"], "maroon": p["keyword"],
    }
    thm = {
        "bg": p["bg"], "fg": p["fg"], "rosewater": p["constant"], "flamingo": p["constant"],
        "pink": p["special"], "mauve": p["special"], "red": p["error"], "maroon": p["keyword"],
        "peach": p["number"], "yellow": p["type"], "green": p["string"], "teal": p["property"],
        "sky": p["property"], "sapphire": p["function"], "blue": p["function"], "lavender": p["accent"],
        "subtext_1": p["dim"], "subtext_0": p["dim"], "overlay_2": p["comment"], "overlay_1": p["comment"],
        "overlay_0": p["comment"], "surface_2": p["line"], "surface_1": p["line"], "surface_0": p["raised"],
        "mantle": p["panel"], "crust": p["bg"],
    }
    out = [f"# {p['title']} — tmux: перекрывает @om_* из om-theme.conf и @thm_* (catppuccin-раскладка)."]
    out += [f'set -g @om_{k} "{v}"' for k, v in om.items()]
    out += [""] + [f'set -ogq @thm_{k} "{v}"' for k, v in thm.items()]
    return "\n".join(out) + "\n"


def yatline_palette(p):
    return f"""# {p['title']} — палитра yatline (scripts/omarchy-yatline-theme)
accent = "{p['accent']}"
magenta = "{p['special']}"
red = "{p['error']}"
yellow = "{p['type']}"
green = "{p['string']}"
cyan = "{p['property']}"
blue = "{p['function']}"
foreground = "{p['fg']}"
background = "{p['bg']}"
dark_background = "{p['panel']}"
lighter_background = "{p['raised']}"
"""


def env(p):
    return ("# Переменные окружения темы (KEY=VALUE, {theme} — путь к текущей теме)\n"
            "# bat и delta рисуют на ANSI-цветах терминала — они подобраны вручную в kitty/ghostty.\n"
            "BAT_THEME=ansi\n"
            "GLAMOUR_STYLE={theme}/apps/glow.json\n")


def fastfetch(p):
    text = open(os.path.join(DOTMATRIX, "apps", "fastfetch.jsonc")).read()
    # Точечный Arch-логотип dotmatrix; горящие точки — красным ANSI (у варианта он близок к сигналу), ключи — серые.
    text = text.replace('"1": "white"', '"1": "red"', 1)
    return re.sub(r"#d71921", p["accent"], text, flags=re.I)


# ── Перекраска структурированных тем catppuccin-mocha-efter ───────────────

MOCHA = {
    "f5e0dc": "constant", "f2cdcd": "constant", "f5c2e7": "special", "cba6f7": "keyword",
    "f38ba8": "error", "eba0ac": "keyword", "fab387": "number", "f9e2af": "type", "a6e3a1": "string",
    "94e2d5": "property", "89dceb": "property", "74c7ec": "function", "89b4fa": "function",
    "b4befe": "accent", "cdd6f4": "fg", "bac2de": "dim", "a6adc8": "dim", "9399b2": "comment",
    "7f849c": "comment", "6c7086": "comment", "585b70": "line", "45475a": "line", "313244": "raised",
    "1e1e2e": "bg", "181825": "panel", "11111b": "bg",
    # единичные не-mocha цвета в rmpc / glow / yazi-flavor
    "3b4252": "raised", "4c566a": "line", "f38bb8": "error", "ffffff": "fg", "3e5767": "selection",
}


def recolor(text, p):
    def sub(m):
        role = MOCHA.get(m.group(1).lower())
        return p[role] if role else m.group(0)
    return re.sub(r"#([0-9a-fA-F]{6})", sub, text)


def from_efter(rel, p):
    return recolor(open(os.path.join(EFTER, rel)).read(), p)


# ── Neovim: своя colorscheme ─────────────────────────────────────────────

def nvim_colors(name, p):
    dark = p["mode"] == "dark"
    c = dict(p)
    c["none"] = "NONE"
    c["cursorline"] = p["panel"]
    c["float"] = p["panel"]
    c["visual"] = p["selection"]
    c["search"] = mix(p["type"], p["bg"], 0.65)
    c["inc"] = p["accent"]
    c["err_bg"] = mix(p["error"], p["bg"], 0.85)
    c["warn_bg"] = mix(p["warn"], p["bg"], 0.85)
    c["info_bg"] = mix(p["info"], p["bg"], 0.85)
    c["hint_bg"] = mix(p["hint"], p["bg"], 0.85)
    hl = {
        # редактор
        "Normal": {"fg": "fg", "bg": "bg"}, "NormalNC": {"fg": "fg", "bg": "bg"},
        "NormalFloat": {"fg": "fg", "bg": "float"}, "FloatBorder": {"fg": "line", "bg": "float"},
        "FloatTitle": {"fg": "fg", "bg": "float", "bold": True},
        "Cursor": {"fg": "on_accent", "bg": "accent"}, "lCursor": {"fg": "on_accent", "bg": "accent"},
        "CursorLine": {"bg": "cursorline"}, "CursorColumn": {"bg": "cursorline"},
        "ColorColumn": {"bg": "panel"}, "LineNr": {"fg": "line" if dark else "comment"},
        "CursorLineNr": {"fg": "accent", "bold": True}, "SignColumn": {"bg": "bg"},
        "FoldColumn": {"fg": "comment", "bg": "bg"}, "Folded": {"fg": "dim", "bg": "panel"},
        "VertSplit": {"fg": "line"}, "WinSeparator": {"fg": "line"},
        "Visual": {"bg": "visual"}, "VisualNOS": {"bg": "visual"},
        "Search": {"fg": "fg", "bg": "search"}, "IncSearch": {"fg": "on_accent", "bg": "inc"},
        "CurSearch": {"fg": "on_accent", "bg": "inc"}, "Substitute": {"fg": "on_accent", "bg": "error"},
        "MatchParen": {"fg": "accent", "bold": True, "underline": True},
        "Pmenu": {"fg": "fg", "bg": "float"}, "PmenuSel": {"fg": "fg", "bg": "raised", "bold": True},
        "PmenuSbar": {"bg": "panel"}, "PmenuThumb": {"bg": "line"}, "PmenuKind": {"fg": "special", "bg": "float"},
        "PmenuExtra": {"fg": "comment", "bg": "float"},
        "StatusLine": {"fg": "dim", "bg": "panel"}, "StatusLineNC": {"fg": "comment", "bg": "panel"},
        "TabLine": {"fg": "comment", "bg": "panel"}, "TabLineFill": {"bg": "bg"}, "TabLineSel": {"fg": "fg", "bg": "raised"},
        "WinBar": {"fg": "dim", "bg": "bg"}, "WinBarNC": {"fg": "comment", "bg": "bg"},
        "NonText": {"fg": "line"}, "Whitespace": {"fg": "line"}, "SpecialKey": {"fg": "line"},
        "EndOfBuffer": {"fg": "bg"}, "Conceal": {"fg": "comment"}, "Directory": {"fg": "function"},
        "Title": {"fg": "accent", "bold": True}, "Question": {"fg": "function"}, "MoreMsg": {"fg": "string"},
        "ModeMsg": {"fg": "dim", "bold": True}, "ErrorMsg": {"fg": "error"}, "WarningMsg": {"fg": "warn"},
        "QuickFixLine": {"bg": "raised", "bold": True}, "WildMenu": {"fg": "on_accent", "bg": "accent"},
        "SpellBad": {"sp": "error", "undercurl": True}, "SpellCap": {"sp": "warn", "undercurl": True},
        "SpellRare": {"sp": "special", "undercurl": True}, "SpellLocal": {"sp": "info", "undercurl": True},
        "DiffAdd": {"bg": "diff_add"}, "DiffDelete": {"fg": "error", "bg": "diff_del"},
        "DiffChange": {"bg": "diff_change"}, "DiffText": {"bg": mix(p["diff_change"], p["function"], 0.25)},
        "Added": {"fg": "ok"}, "Removed": {"fg": "error"}, "Changed": {"fg": "info"},
        # синтаксис
        "Comment": {"fg": "comment", "italic": True}, "Constant": {"fg": "constant"},
        "String": {"fg": "string"}, "Character": {"fg": "string"}, "Number": {"fg": "number"},
        "Boolean": {"fg": "number"}, "Float": {"fg": "number"}, "Identifier": {"fg": "fg"},
        "Function": {"fg": "function"}, "Statement": {"fg": "keyword"}, "Conditional": {"fg": "keyword"},
        "Repeat": {"fg": "keyword"}, "Label": {"fg": "special"}, "Operator": {"fg": "dim"},
        "Keyword": {"fg": "keyword"}, "Exception": {"fg": "keyword"}, "PreProc": {"fg": "special"},
        "Include": {"fg": "keyword"}, "Define": {"fg": "special"}, "Macro": {"fg": "special"},
        "PreCondit": {"fg": "special"}, "Type": {"fg": "type"}, "StorageClass": {"fg": "keyword"},
        "Structure": {"fg": "type"}, "Typedef": {"fg": "type"}, "Special": {"fg": "special"},
        "SpecialChar": {"fg": "special"}, "Tag": {"fg": "keyword"}, "Delimiter": {"fg": "dim"},
        "SpecialComment": {"fg": "comment", "italic": True}, "Debug": {"fg": "warn"},
        "Underlined": {"underline": True}, "Error": {"fg": "error"}, "Todo": {"fg": "on_accent", "bg": "accent", "bold": True},
        # treesitter
        "@variable": {"fg": "fg"}, "@variable.builtin": {"fg": "keyword", "italic": True},
        "@variable.parameter": {"fg": "fg", "italic": True}, "@variable.member": {"fg": "property"},
        "@property": {"fg": "property"}, "@field": {"fg": "property"},
        "@constant": {"fg": "constant"}, "@constant.builtin": {"fg": "number"}, "@constant.macro": {"fg": "special"},
        "@module": {"fg": "type"}, "@namespace": {"fg": "type"}, "@label": {"fg": "special"},
        "@string": {"fg": "string"}, "@string.escape": {"fg": "special"}, "@string.regexp": {"fg": "special"},
        "@string.special": {"fg": "special"}, "@string.special.url": {"fg": "function", "underline": True},
        "@character": {"fg": "string"}, "@number": {"fg": "number"}, "@boolean": {"fg": "number"},
        "@type": {"fg": "type"}, "@type.builtin": {"fg": "type", "italic": True}, "@type.definition": {"fg": "type"},
        "@attribute": {"fg": "special"}, "@function": {"fg": "function"}, "@function.builtin": {"fg": "function", "italic": True},
        "@function.call": {"fg": "function"}, "@function.macro": {"fg": "special"}, "@function.method": {"fg": "function"},
        "@function.method.call": {"fg": "function"}, "@constructor": {"fg": "type"},
        "@operator": {"fg": "dim"}, "@keyword": {"fg": "keyword"}, "@keyword.function": {"fg": "keyword"},
        "@keyword.return": {"fg": "keyword", "italic": True}, "@keyword.import": {"fg": "keyword"},
        "@keyword.operator": {"fg": "keyword"}, "@keyword.exception": {"fg": "keyword"},
        "@punctuation": {"fg": "dim"}, "@punctuation.delimiter": {"fg": "dim"}, "@punctuation.bracket": {"fg": "dim"},
        "@punctuation.special": {"fg": "special"}, "@comment": {"fg": "comment", "italic": True},
        "@comment.todo": {"fg": "on_accent", "bg": "accent", "bold": True}, "@comment.error": {"fg": "error", "bold": True},
        "@comment.warning": {"fg": "warn", "bold": True}, "@comment.note": {"fg": "info", "bold": True},
        "@tag": {"fg": "keyword"}, "@tag.attribute": {"fg": "property"}, "@tag.delimiter": {"fg": "dim"},
        "@markup.heading": {"fg": "accent", "bold": True}, "@markup.heading.1": {"fg": "accent", "bold": True},
        "@markup.heading.2": {"fg": "number", "bold": True}, "@markup.heading.3": {"fg": "type", "bold": True},
        "@markup.heading.4": {"fg": "string", "bold": True}, "@markup.heading.5": {"fg": "function", "bold": True},
        "@markup.heading.6": {"fg": "special", "bold": True},
        "@markup.strong": {"bold": True}, "@markup.italic": {"italic": True}, "@markup.strikethrough": {"strikethrough": True},
        "@markup.link": {"fg": "function"}, "@markup.link.url": {"fg": "function", "underline": True},
        "@markup.raw": {"fg": "string"}, "@markup.list": {"fg": "accent"}, "@markup.quote": {"fg": "dim", "italic": True},
        "@diff.plus": {"fg": "ok"}, "@diff.minus": {"fg": "error"}, "@diff.delta": {"fg": "info"},
        # LSP semantic
        "@lsp.type.class": {"fg": "type"}, "@lsp.type.enum": {"fg": "type"}, "@lsp.type.interface": {"fg": "type", "italic": True},
        "@lsp.type.struct": {"fg": "type"}, "@lsp.type.typeParameter": {"fg": "type", "italic": True},
        "@lsp.type.namespace": {"fg": "type"}, "@lsp.type.parameter": {"fg": "fg", "italic": True},
        "@lsp.type.property": {"fg": "property"}, "@lsp.type.enumMember": {"fg": "constant"},
        "@lsp.type.function": {"fg": "function"}, "@lsp.type.method": {"fg": "function"},
        "@lsp.type.macro": {"fg": "special"}, "@lsp.type.decorator": {"fg": "special"},
        "@lsp.typemod.variable.readonly": {"fg": "constant"}, "@lsp.mod.deprecated": {"strikethrough": True},
        "LspReferenceText": {"bg": "raised"}, "LspReferenceRead": {"bg": "raised"}, "LspReferenceWrite": {"bg": "raised", "underline": True},
        "LspInlayHint": {"fg": "comment", "italic": True}, "LspSignatureActiveParameter": {"fg": "accent", "bold": True},
        "LspCodeLens": {"fg": "comment"}, "LspInfoBorder": {"fg": "line", "bg": "float"},
        # диагностика
        "DiagnosticError": {"fg": "error"}, "DiagnosticWarn": {"fg": "warn"}, "DiagnosticInfo": {"fg": "info"},
        "DiagnosticHint": {"fg": "hint"}, "DiagnosticOk": {"fg": "ok"},
        "DiagnosticVirtualTextError": {"fg": "error", "bg": "err_bg"}, "DiagnosticVirtualTextWarn": {"fg": "warn", "bg": "warn_bg"},
        "DiagnosticVirtualTextInfo": {"fg": "info", "bg": "info_bg"}, "DiagnosticVirtualTextHint": {"fg": "hint", "bg": "hint_bg"},
        "DiagnosticUnderlineError": {"sp": "error", "undercurl": True}, "DiagnosticUnderlineWarn": {"sp": "warn", "undercurl": True},
        "DiagnosticUnderlineInfo": {"sp": "info", "undercurl": True}, "DiagnosticUnderlineHint": {"sp": "hint", "undercurl": True},
        "DiagnosticUnnecessary": {"fg": "comment"},
        # gitsigns
        "GitSignsAdd": {"fg": "ok"}, "GitSignsChange": {"fg": "info"}, "GitSignsDelete": {"fg": "error"},
        "GitSignsAddInline": {"bg": "diff_add"}, "GitSignsDeleteInline": {"bg": "diff_del"}, "GitSignsChangeInline": {"bg": "diff_change"},
        "GitSignsCurrentLineBlame": {"fg": "comment", "italic": True},
        # snacks
        "SnacksPicker": {"fg": "fg", "bg": "float"}, "SnacksPickerBorder": {"fg": "line", "bg": "float"},
        "SnacksPickerTitle": {"fg": "on_accent", "bg": "accent", "bold": True}, "SnacksPickerMatch": {"fg": "accent", "bold": True},
        "SnacksPickerListCursorLine": {"bg": "raised"}, "SnacksPickerPrompt": {"fg": "accent"},
        "SnacksPickerDir": {"fg": "comment"}, "SnacksPickerFile": {"fg": "fg"}, "SnacksPickerSelected": {"fg": "string"},
        "SnacksDashboardHeader": {"fg": "accent"}, "SnacksDashboardKey": {"fg": "accent"},
        "SnacksDashboardIcon": {"fg": "dim"}, "SnacksDashboardDesc": {"fg": "fg"}, "SnacksDashboardFooter": {"fg": "comment"},
        "SnacksDashboardSpecial": {"fg": "special"}, "SnacksIndent": {"fg": "line" if dark else "panel"},
        "SnacksIndentScope": {"fg": "comment"}, "SnacksNotifierBorderInfo": {"fg": "info"},
        "SnacksNotifierBorderWarn": {"fg": "warn"}, "SnacksNotifierBorderError": {"fg": "error"},
        "SnacksNotifierTitleInfo": {"fg": "info"}, "SnacksNotifierTitleWarn": {"fg": "warn"}, "SnacksNotifierTitleError": {"fg": "error"},
        "SnacksNotifierIconInfo": {"fg": "info"}, "SnacksNotifierIconWarn": {"fg": "warn"}, "SnacksNotifierIconError": {"fg": "error"},
        # blink.cmp
        "BlinkCmpMenu": {"fg": "fg", "bg": "float"}, "BlinkCmpMenuBorder": {"fg": "line", "bg": "float"},
        "BlinkCmpMenuSelection": {"bg": "raised", "bold": True}, "BlinkCmpLabelMatch": {"fg": "accent", "bold": True},
        "BlinkCmpLabelDeprecated": {"fg": "comment", "strikethrough": True}, "BlinkCmpLabelDetail": {"fg": "comment"},
        "BlinkCmpDoc": {"fg": "fg", "bg": "float"}, "BlinkCmpDocBorder": {"fg": "line", "bg": "float"},
        "BlinkCmpGhostText": {"fg": "comment", "italic": True}, "BlinkCmpKind": {"fg": "special"},
        "BlinkCmpKindFunction": {"fg": "function"}, "BlinkCmpKindMethod": {"fg": "function"},
        "BlinkCmpKindVariable": {"fg": "fg"}, "BlinkCmpKindField": {"fg": "property"}, "BlinkCmpKindProperty": {"fg": "property"},
        "BlinkCmpKindClass": {"fg": "type"}, "BlinkCmpKindStruct": {"fg": "type"}, "BlinkCmpKindInterface": {"fg": "type"},
        "BlinkCmpKindKeyword": {"fg": "keyword"}, "BlinkCmpKindConstant": {"fg": "constant"}, "BlinkCmpKindSnippet": {"fg": "string"},
        "BlinkCmpKindModule": {"fg": "type"}, "BlinkCmpKindText": {"fg": "dim"},
        # bufferline
        "BufferLineFill": {"bg": "bg"}, "BufferLineBackground": {"fg": "comment", "bg": "bg"},
        "BufferLineBufferSelected": {"fg": "fg", "bg": "bg", "bold": True, "italic": False},
        "BufferLineBufferVisible": {"fg": "dim", "bg": "bg"}, "BufferLineIndicatorSelected": {"fg": "accent", "bg": "bg"},
        "BufferLineSeparator": {"fg": "bg", "bg": "bg"}, "BufferLineModifiedSelected": {"fg": "accent", "bg": "bg"},
        "BufferLineCloseButtonSelected": {"fg": "error", "bg": "bg"}, "BufferLineTab": {"fg": "comment", "bg": "bg"},
        "BufferLineTabSelected": {"fg": "accent", "bg": "bg"},
        # noice, which-key, flash, mini, render-markdown, dap, trouble
        "NoiceCmdlinePopupBorder": {"fg": "accent"}, "NoiceCmdlineIcon": {"fg": "accent"},
        "NoiceCmdlinePopupTitle": {"fg": "accent"}, "NoiceConfirmBorder": {"fg": "accent"},
        "WhichKey": {"fg": "accent"}, "WhichKeyGroup": {"fg": "function"}, "WhichKeyDesc": {"fg": "fg"},
        "WhichKeySeparator": {"fg": "comment"}, "WhichKeyNormal": {"bg": "float"}, "WhichKeyBorder": {"fg": "line", "bg": "float"},
        "FlashLabel": {"fg": "on_accent", "bg": "accent", "bold": True}, "FlashMatch": {"fg": "type"},
        "FlashCurrent": {"fg": "string", "bold": True}, "FlashBackdrop": {"fg": "comment"},
        "MiniIconsAzure": {"fg": "function"}, "MiniIconsBlue": {"fg": "function"}, "MiniIconsCyan": {"fg": "property"},
        "MiniIconsGreen": {"fg": "string"}, "MiniIconsGrey": {"fg": "dim"}, "MiniIconsOrange": {"fg": "number"},
        "MiniIconsPurple": {"fg": "special"}, "MiniIconsRed": {"fg": "error"}, "MiniIconsYellow": {"fg": "type"},
        "RenderMarkdownH1Bg": {"bg": mix(p["accent"], p["bg"], 0.85)}, "RenderMarkdownH2Bg": {"bg": mix(p["number"], p["bg"], 0.88)},
        "RenderMarkdownH3Bg": {"bg": mix(p["type"], p["bg"], 0.88)}, "RenderMarkdownH4Bg": {"bg": mix(p["string"], p["bg"], 0.88)},
        "RenderMarkdownCode": {"bg": "panel"}, "RenderMarkdownBullet": {"fg": "accent"},
        "DapBreakpoint": {"fg": "accent"}, "DapStopped": {"fg": "string"}, "DapStoppedLine": {"bg": "diff_add"},
        "TroubleNormal": {"fg": "fg", "bg": "panel"}, "TroubleNormalNC": {"fg": "fg", "bg": "panel"},
        "TodoBgTODO": {"fg": "on_accent", "bg": "accent", "bold": True}, "TodoFgTODO": {"fg": "accent"},
        "TodoBgFIX": {"fg": "on_accent", "bg": "error", "bold": True}, "TodoFgFIX": {"fg": "error"},
        "TodoBgNOTE": {"fg": "bg", "bg": "info", "bold": True}, "TodoFgNOTE": {"fg": "info"},
        "TodoBgWARN": {"fg": "bg", "bg": "warn", "bold": True}, "TodoFgWARN": {"fg": "warn"},
    }

    if p.get("tonal"):
        # Тональная палитра: роли одного цвета дополнительно различаются начертанием.
        for g in ["Keyword", "Statement", "Conditional", "Repeat", "Include", "Exception", "StorageClass",
                  "@keyword", "@keyword.function", "@keyword.import", "@keyword.operator", "@keyword.exception",
                  "@keyword.return", "@tag"]:
            hl[g] = dict(hl[g], bold=True)
        for g in ["Type", "Structure", "Typedef", "@type", "@type.definition", "@constructor",
                  "@lsp.type.class", "@lsp.type.enum", "@lsp.type.struct", "@module", "@namespace"]:
            hl[g] = dict(hl[g], italic=True)

    def val(v):
        return c.get(v, v) if isinstance(v, str) else v

    lines = [
        f"-- {p['title']} — своя colorscheme (omarchy-themes/nothing/build.py, роли — palettes.py).",
        'vim.cmd("highlight clear")',
        'if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end',
        f'vim.o.background = "{p["mode"]}"',
        f'vim.g.colors_name = "{name}"',
        "local set = vim.api.nvim_set_hl",
    ]
    for group, spec in hl.items():
        parts = []
        for k, v in spec.items():
            if isinstance(v, bool):
                parts.append(f"{k} = {'true' if v else 'false'}")
            else:
                parts.append(f'{k} = "{val(v)}"')
        lines.append(f'set(0, "{group}", {{ {", ".join(parts)} }})')
    a = ansi(p)
    lines += [f'vim.g.terminal_color_{i} = "{col}"' for i, col in enumerate(a)]
    return "\n".join(lines) + "\n"


def lualine_theme(p):
    def mode(color):
        return (f'{{ a = {{ fg = "{p["on_accent"] if color == p["accent"] else p["bg"]}", bg = "{color}", gui = "bold" }}, '
                f'b = {{ fg = "{p["fg"]}", bg = "{p["raised"]}" }}, c = {{ fg = "{p["dim"]}", bg = "{p["panel"]}" }} }}')
    return f"""-- {p['title']} — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {{
  normal = {mode(p['accent'])},
  insert = {mode(p['string'])},
  visual = {mode(p['special'])},
  replace = {mode(p['error'])},
  command = {mode(p['type'])},
  terminal = {mode(p['function'])},
  inactive = {{ a = {{ fg = "{p['comment']}", bg = "{p['panel']}" }}, b = {{ fg = "{p['comment']}", bg = "{p['panel']}" }}, c = {{ fg = "{p['comment']}", bg = "{p['panel']}" }} }},
}}
"""


def neovim_spec(name):
    return f"""-- Своя colorscheme {name}: лежит в каталоге темы (nvim/colors, nvim/lua/lualine/themes),
-- omarchy копирует тему в ~/.local/state/omarchy/current/theme — оттуда её и грузим.
return {{
	{{
		dir = vim.fn.expand("~/.local/state/omarchy/current/theme/nvim"),
		name = "{name}",
		lazy = false,
		priority = 1000,
	}},
	{{
		"LazyVim/LazyVim",
		opts = {{
			colorscheme = "{name}",
		}},
	}},
}}
"""


# ── VS Code ───────────────────────────────────────────────────────────────

def vscode(p):
    dark = p["mode"] == "dark"
    a = ansi(p)
    t = lambda c, alpha: c + alpha
    colors = {
        "focusBorder": t(p["accent"], "99"), "foreground": p["fg"], "descriptionForeground": p["dim"],
        "errorForeground": p["error"], "icon.foreground": p["dim"], "selection.background": p["selection"],
        "widget.shadow": "#00000066" if dark else "#0000001f", "sash.hoverBorder": p["accent"],
        "editor.background": p["bg"], "editor.foreground": p["fg"],
        "editorLineNumber.foreground": p["line"] if dark else p["comment"],
        "editorLineNumber.activeForeground": p["accent"], "editorCursor.foreground": p["accent"],
        "editor.selectionBackground": p["selection"], "editor.inactiveSelectionBackground": t(p["selection"], "99"),
        "editor.selectionHighlightBackground": t(p["raised"], "cc"), "editor.wordHighlightBackground": t(p["raised"], "cc"),
        "editor.findMatchBackground": t(p["accent"], "66"), "editor.findMatchHighlightBackground": t(p["type"], "33"),
        "editor.lineHighlightBackground": p["panel"], "editor.lineHighlightBorder": "#00000000",
        "editorIndentGuide.background1": p["raised"] if dark else p["line"], "editorIndentGuide.activeBackground1": p["comment"],
        "editorWhitespace.foreground": p["line"], "editorBracketMatch.background": t(p["accent"], "33"),
        "editorBracketMatch.border": t(p["accent"], "99"),
        "editorBracketHighlight.foreground1": p["dim"], "editorBracketHighlight.foreground2": p["special"],
        "editorBracketHighlight.foreground3": p["function"], "editorBracketHighlight.foreground4": p["string"],
        "editorBracketHighlight.foreground5": p["type"], "editorBracketHighlight.foreground6": p["number"],
        "editorError.foreground": p["error"], "editorWarning.foreground": p["warn"], "editorInfo.foreground": p["info"],
        "editorHint.foreground": p["hint"], "editorInlayHint.foreground": p["comment"], "editorInlayHint.background": "#00000000",
        "editorGutter.addedBackground": p["ok"], "editorGutter.modifiedBackground": p["info"], "editorGutter.deletedBackground": p["error"],
        "diffEditor.insertedTextBackground": t(p["ok"], "26"), "diffEditor.removedTextBackground": t(p["error"], "26"),
        "diffEditor.insertedLineBackground": p["diff_add"], "diffEditor.removedLineBackground": p["diff_del"],
        "editorWidget.background": p["panel"], "editorWidget.border": p["line"], "editorHoverWidget.background": p["panel"],
        "editorHoverWidget.border": p["line"], "editorSuggestWidget.background": p["panel"], "editorSuggestWidget.border": p["line"],
        "editorSuggestWidget.selectedBackground": p["raised"], "editorSuggestWidget.highlightForeground": p["accent"],
        "editorGroupHeader.tabsBackground": p["bg"], "editorGroup.border": p["line"],
        "tab.activeBackground": p["bg"], "tab.inactiveBackground": p["bg"], "tab.activeForeground": p["fg"],
        "tab.inactiveForeground": p["comment"], "tab.activeBorderTop": p["accent"], "tab.border": p["bg"],
        "tab.unfocusedActiveBorderTop": p["line"],
        "activityBar.background": p["bg"], "activityBar.foreground": p["fg"], "activityBar.inactiveForeground": p["comment"],
        "activityBar.activeBorder": p["accent"], "activityBarBadge.background": p["accent"], "activityBarBadge.foreground": p["on_accent"],
        "activityBar.border": p["line"],
        "sideBar.background": p["bg"], "sideBar.foreground": p["dim"], "sideBar.border": p["line"],
        "sideBarTitle.foreground": p["fg"], "sideBarSectionHeader.background": p["bg"], "sideBarSectionHeader.foreground": p["fg"],
        "sideBarSectionHeader.border": p["line"],
        "list.activeSelectionBackground": p["raised"], "list.activeSelectionForeground": p["fg"],
        "list.inactiveSelectionBackground": p["panel"], "list.hoverBackground": p["panel"],
        "list.highlightForeground": p["accent"], "list.focusOutline": t(p["accent"], "66"),
        "list.errorForeground": p["error"], "list.warningForeground": p["warn"],
        "gitDecoration.addedResourceForeground": p["ok"], "gitDecoration.modifiedResourceForeground": p["info"],
        "gitDecoration.deletedResourceForeground": p["error"], "gitDecoration.untrackedResourceForeground": p["string"],
        "gitDecoration.ignoredResourceForeground": p["comment"], "gitDecoration.conflictingResourceForeground": p["warn"],
        "statusBar.background": p["bg"], "statusBar.foreground": p["dim"], "statusBar.border": p["line"],
        "statusBar.noFolderBackground": p["bg"], "statusBar.debuggingBackground": p["accent"],
        "statusBar.debuggingForeground": p["on_accent"], "statusBarItem.remoteBackground": p["accent"],
        "statusBarItem.remoteForeground": p["on_accent"], "statusBarItem.hoverBackground": p["raised"],
        "titleBar.activeBackground": p["bg"], "titleBar.activeForeground": p["fg"], "titleBar.inactiveBackground": p["bg"],
        "titleBar.inactiveForeground": p["comment"], "titleBar.border": p["line"],
        "panel.background": p["bg"], "panel.border": p["line"], "panelTitle.activeBorder": p["accent"],
        "panelTitle.activeForeground": p["fg"], "panelTitle.inactiveForeground": p["comment"],
        "terminal.background": p["bg"], "terminal.foreground": p["fg"], "terminalCursor.foreground": p["accent"],
        "terminal.selectionBackground": p["selection"],
        "input.background": p["panel"], "input.border": p["line"], "input.foreground": p["fg"],
        "input.placeholderForeground": p["comment"], "inputOption.activeBorder": p["accent"],
        "dropdown.background": p["panel"], "dropdown.border": p["line"],
        "button.background": p["accent"], "button.foreground": p["on_accent"], "button.hoverBackground": mix(p["accent"], p["fg"], 0.15),
        "button.secondaryBackground": p["raised"], "button.secondaryForeground": p["fg"],
        "badge.background": p["accent"], "badge.foreground": p["on_accent"],
        "progressBar.background": p["accent"], "scrollbarSlider.background": t(p["line"], "80"),
        "scrollbarSlider.hoverBackground": t(p["comment"], "80"), "scrollbarSlider.activeBackground": t(p["accent"], "80"),
        "minimap.background": p["bg"], "breadcrumb.foreground": p["comment"], "breadcrumb.focusForeground": p["fg"],
        "notifications.background": p["panel"], "notifications.border": p["line"], "notificationToast.border": p["line"],
        "quickInput.background": p["panel"], "quickInputList.focusBackground": p["raised"],
        "peekView.border": p["accent"], "peekViewEditor.background": p["panel"], "peekViewResult.background": p["panel"],
        "peekViewTitle.background": p["panel"], "textLink.foreground": p["function"], "textLink.activeForeground": p["accent"],
        "textCodeBlock.background": p["panel"],
    }
    names = ["Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White"]
    for i, n in enumerate(names):
        colors[f"terminal.ansi{n}"] = a[i]
        colors[f"terminal.ansiBright{n}"] = a[i + 8]

    def tok(scope, fg, style=None):
        s = {"foreground": fg}
        if style:
            s["fontStyle"] = style
        return {"scope": scope, "settings": s}

    tonal = p.get("tonal", False)
    kw_style = "bold" if tonal else None
    ty_style = "italic" if tonal else None
    token_colors = [
        tok(["comment", "punctuation.definition.comment"], p["comment"], "italic"),
        tok(["keyword", "storage", "storage.type", "storage.modifier", "keyword.control", "keyword.operator.new",
             "keyword.operator.expression", "keyword.operator.logical.python"], p["keyword"], kw_style),
        tok(["keyword.control.flow", "keyword.control.return"], p["keyword"], "bold italic" if tonal else "italic"),
        tok(["string", "string.quoted", "string.template", "markup.inline.raw", "markup.fenced_code"], p["string"]),
        tok(["constant.character.escape", "string.regexp", "constant.other.placeholder"], p["special"]),
        tok(["constant.numeric", "constant.language.boolean", "constant.language"], p["number"]),
        tok(["constant", "variable.other.constant", "variable.other.enummember", "support.constant"], p["constant"]),
        tok(["entity.name.type", "entity.name.class", "support.type", "support.class", "entity.other.inherited-class",
             "storage.type.class", "entity.name.namespace"], p["type"], ty_style),
        tok(["entity.name.function", "support.function", "meta.function-call", "variable.function"], p["function"]),
        tok(["variable.other.property", "variable.other.object.property", "support.variable.property",
             "entity.other.attribute-name", "meta.object-literal.key"], p["property"]),
        tok(["variable", "variable.other.readwrite", "meta.definition.variable"], p["fg"]),
        tok(["variable.parameter"], p["fg"], "italic"),
        tok(["variable.language", "variable.language.this", "variable.language.self"], p["keyword"], "italic"),
        tok(["keyword.operator", "punctuation", "meta.brace"], p["dim"]),
        tok(["entity.name.tag", "meta.tag"], p["keyword"]),
        tok(["entity.name.function.decorator", "meta.decorator", "entity.name.function.macro", "meta.preprocessor"], p["special"]),
        tok(["markup.heading", "entity.name.section"], p["accent"], "bold"),
        tok(["markup.bold"], p["fg"], "bold"), tok(["markup.italic"], p["fg"], "italic"),
        tok(["markup.underline.link", "markup.link"], p["function"], "underline"),
        tok(["markup.list.unnumbered", "markup.list.numbered", "punctuation.definition.list"], p["accent"]),
        tok(["markup.quote"], p["dim"], "italic"),
        tok(["markup.inserted"], p["ok"]), tok(["markup.deleted"], p["error"]), tok(["markup.changed"], p["info"]),
        tok(["invalid", "invalid.illegal"], p["error"]),
    ]
    semantic = {
        "class": {"foreground": p["type"], "fontStyle": ty_style or ""}, "interface": {"foreground": p["type"], "fontStyle": "italic"},
        "enum": {"foreground": p["type"], "fontStyle": ty_style or ""},
        "struct": {"foreground": p["type"], "fontStyle": ty_style or ""}, "type": {"foreground": p["type"], "fontStyle": ty_style or ""}, "typeParameter": {"foreground": p["type"], "fontStyle": "italic"},
        "namespace": p["type"], "function": p["function"], "method": p["function"], "macro": p["special"],
        "decorator": p["special"], "property": p["property"], "enumMember": p["constant"],
        "parameter": {"foreground": p["fg"], "fontStyle": "italic"}, "variable": p["fg"],
        "variable.readonly": p["constant"], "keyword": {"foreground": p["keyword"], "fontStyle": kw_style or ""}, "string": p["string"], "number": p["number"],
        "regexp": p["special"], "operator": p["dim"], "*.deprecated": {"fontStyle": "strikethrough"},
    }
    return json.dumps({
        "name": "Omarchy", "type": "dark" if dark else "light", "semanticHighlighting": True,
        "colors": colors, "tokenColors": token_colors, "semanticTokenColors": semantic,
    }, indent=2, ensure_ascii=False) + "\n"


# ── Картинки: unlock.png и обои ───────────────────────────────────────────

def recolor_png(src, dst, black, white):
    from PIL import Image, ImageOps
    img = Image.open(src).convert("L")
    ImageOps.colorize(img, black=black, white=white).save(dst, optimize=True)


def unlock_png(dst, color):
    from PIL import Image
    src = Image.open("/usr/share/omarchy/themes/catppuccin/unlock.png").convert("RGBA")
    r, g, b = hex2rgb(color)
    out = Image.new("RGBA", src.size, (r, g, b, 0))
    out.putalpha(src.getchannel("A"))
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            px[x, y] = (r, g, b, px[x, y][3])
    out.save(dst, optimize=True)


WALLPAPERS = {
    # вариант: [(имя файла dotmatrix, цвет точек — роль или hex)]
    "signal": [("01-night.png", "fg"), ("blackhole.png", "accent"), ("galaxy.png", "fg"), ("02-arch.png", "accent")],
    "cmf": [("01-night.png", "accent"), ("tokyo.png", "number"), ("space.png", "fg"), ("02-arch.png", "accent")],
    "glyph": [("01-night.png", "fg"), ("antenna.png", "accent"), ("galaxy.png", "fg"), ("02-arch.png", "accent")],
    "ash": [("01-night.png", "dim"), ("blackhole.png", "accent"), ("space.png", "fg"), ("02-arch.png", "accent")],
    "ember": [("01-night.png", "accent"), ("tokyo.png", "number"), ("blackhole.png", "keyword"), ("02-arch.png", "accent")],
    "steel": [("galaxy.png", "string"), ("blackhole.png", "accent"), ("antenna.png", "function"), ("02-arch.png", "accent")],
    "ashlight": [("01-night.png", "fg"), ("blackhole.png", "accent"), ("space.png", "dim"), ("02-arch.png", "accent")],
    "glyph-dark": [("01-night.png", "fg"), ("02-arch.png", "accent"), ("galaxy.png", "fg"), ("antenna.png", "dim"),
                   ("blackhole.png", "accent")],
    "glyph-light": [("01-night.png", "fg"), ("02-arch.png", "accent"), ("galaxy.png", "dim"), ("antenna.png", "fg")],
}


def wallpapers(variant, p, out_dir):
    bg_dir = os.path.join(out_dir, "backgrounds")
    os.makedirs(bg_dir, exist_ok=True)
    for i, (src, role) in enumerate(WALLPAPERS[variant], 1):
        dot = p.get(role, role)
        dst = os.path.join(bg_dir, f"{i}-{os.path.splitext(src)[0]}.png")
        if os.path.exists(dst):
            continue
        # Светлая тема: фон светлый, точки тёмные — инверсия яркости исходника.
        recolor_png(os.path.join(DOTMATRIX, "backgrounds", src), dst, p["bg"], dot)


# ── Сборка ────────────────────────────────────────────────────────────────

def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(text)


def build(variant):
    p = PALETTES[variant]
    problems = check(variant, p)
    if problems:
        sys.exit(f"{variant}: {'; '.join(problems)}")
    # name / out — для чужих палитр (omarchy-themes/vitreus/build.py): имя темы и каталог; по умолчанию nothing-<вариант>
    out = p.get("out", os.path.join(HERE, variant))
    name = p.get("name", f"nothing-{variant}")
    files = {
        "colors.toml": colors_toml(p),
        "kitty.conf": kitty(p),
        "ghostty.conf": ghostty(p),
        "alacritty.toml": alacritty(p),
        "foot.ini": foot(p),
        "hyprland.lua": hyprland(p),
        "btop.theme": btop(p),
        "cava_theme": cava(p),
        "helix.toml": helix(p),
        "neovim.lua": neovim_spec(name),
        f"nvim/colors/{name}.lua": nvim_colors(name, p),
        f"nvim/lua/lualine/themes/{name}.lua": lualine_theme(p),
        "vscode-theme.json": vscode(p),
        "icons.theme": ("Yaru-dark" if p["mode"] == "dark" else "Yaru") + "\n",
        "apps/lazygit.yml": lazygit(p),
        "apps/gitui.ron": gitui(p),
        "apps/atuin.toml": atuin(p),
        "apps/television.toml": television(p),
        "apps/fzf.opts": fzf(p),
        "apps/tmux.conf": tmux(p),
        "apps/yatline-palette.toml": yatline_palette(p),
        "apps/env": env(p),
        "apps/fastfetch.jsonc": fastfetch(p),
        "apps/yazi.toml": '[flavor]\ndark = "omarchy"\nlight = "omarchy"\n',
        "apps/yazi-flavor/flavor.toml": from_efter("apps/yazi-flavor/flavor.toml", p),
        "apps/yazi-flavor/tmtheme.xml": from_efter("apps/yazi-flavor/tmtheme.xml", p),
        "apps/nushell.nu": from_efter("apps/nushell.nu", p),
        "apps/lla.toml": from_efter("apps/lla.toml", p),
        "apps/rmpc.ron": from_efter("apps/rmpc.ron", p),
        "apps/glow.json": from_efter("apps/glow.json", p),
    }
    for rel, text in files.items():
        write(os.path.join(out, rel), text)
    unlock_png(os.path.join(out, "unlock.png"), p["fg"])
    if variant in WALLPAPERS:
        wallpapers(variant, p, out)
    elif p.get("wallpapers"):
        p["wallpapers"](p, os.path.join(out, "backgrounds"))
    # light.mode — метка светлой темы для Omarchy (GTK, браузеры и т. п. переходят на светлое). Только по флагу,
    # чтобы не менять поведение уже настроенных вариантов.
    if p.get("light_mode_file"):
        with open(os.path.join(out, "light.mode"), "w") as f:
            f.write("")
    print(f"{name}: {len(files)} files")


if __name__ == "__main__":
    for v in sys.argv[1:] or list(PALETTES):
        build(v)
