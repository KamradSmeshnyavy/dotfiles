-- User Custom Bindings

hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"')

hl.unbind("SUPER + ALT + RETURN")
o.bind(
	"SUPER + ALT + RETURN",
	"Tmux",
	'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" bash -c "tmux attach || tmux new -s Work"'
)

hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", "uwsm-app -- nautilus --new-window")
o.bind(
	"SUPER + ALT + SHIFT + F",
	"File manager (cwd)",
	'uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"'
)

hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Browser", "omarchy-launch-browser")
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")

o.bind("SUPER + SHIFT + M", "Music", "omarchy-launch-or-focus spotify")
o.bind("SUPER + SHIFT + ALT + M", "Music TUI", "omarchy-launch-or-focus-tui cliamp")

-- Media Controls
o.bind("Pause", "Play/Pause", "playerctl play-pause", { locked = true })
o.bind("Scroll_Lock", "Next track", "playerctl next", { locked = true })
o.bind("Break", "Previous track", "playerctl previous", { locked = true })

-- Window Management
hl.unbind("SUPER + S")
o.bind("SUPER + S", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + semicolon", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + CTRL + semicolon", "Keybindings Cheatsheet", "omarchy-menu-keybindings")

hl.unbind("SUPER + D")
hl.unbind("SUPER + SHIFT + D")
hl.unbind("SUPER + CTRL + D")

o.bind("SUPER + CTRL + D", "Move to workspace 0", hl.dsp.window.move({ workspace = "+0" }))
o.bind(
	"SUPER + SHIFT + D",
	"Move window to scratchpad",
	hl.dsp.window.move({ workspace = "special:scratchpad", follow = false })
)
o.bind("SUPER + D", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))

hl.unbind("SUPER + H")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + H", "Smart focus left", "~/.config/hypr/scripts/smart_focus.sh l")
o.bind("SUPER + L", "Smart focus right", "~/.config/hypr/scripts/smart_focus.sh r")
o.bind("SUPER + K", "Smart focus up", "~/.config/hypr/scripts/smart_focus.sh u")
o.bind("SUPER + J", "Smart focus down", "~/.config/hypr/scripts/smart_focus.sh d")

o.bind("SUPER + SHIFT + H", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

hl.unbind("SUPER + CTRL + H")
hl.unbind("SUPER + CTRL + J")
hl.unbind("SUPER + CTRL + K")
hl.unbind("SUPER + CTRL + L")

o.bind("SUPER + CTRL + H", "Resize window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + CTRL + L", "Resize window right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("SUPER + CTRL + K", "Resize window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("SUPER + CTRL + J", "Resize window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

o.bind("SUPER + Period", "Layout consume", hl.dsp.layout("consume"))
o.bind("SUPER + SHIFT + Period", "Layout expel", hl.dsp.layout("expel"))

hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Smart float toggle", "~/.config/hypr/scripts/focus_float_toggle.sh")

-- Omarchy Menus & UI
hl.unbind("SUPER + CTRL + W")
hl.unbind("SUPER + ALT + W")
o.bind("SUPER + ALT + W", "Toggle Shell Layout", "~/.config/omarchy/hooks/shell-layout-toggle")

-- Customizer on SHIFT T
o.bind(
	"SUPER + SHIFT + T",
	"Omarchy Customizer",
	"uwsm-app -- xdg-terminal-exec -- bash -c '~/.local/bin/omarchy-customizer'"
)

-- Emojis
o.bind("SUPER + ALT + E", "Emojis", "omarchy menu emoji")

-- Clipboard
o.bind("SUPER + V", "Clipboard", "omarchy menu clipboard")

-- Power Menu
-- hl.unbind("SUPER + ESCAPE")
-- o.bind("SUPER + ESCAPE", "Power menu", "omarchy system logout")

o.bind("SUPER + ALT + A", "Audio controls", "omarchy-shell shell toggle omarchy.audio")

hl.unbind("SUPER + SHIFT + ALT + Z")
o.bind("SUPER + SHIFT + CTRL + Z", "Reset zoom", "hyprctl keyword cursor:zoom_factor 1")

-- Disabled apps (left as documentation)
-- o.bind("SUPER + I", "kbptr", "wl-kbptr -o modes=floating,click -o mode_floating.source=detect")
-- o.bind("SUPER + Q", "kbptr-wrapper", "~/.config/hypr/scripts/kbptr-wrapper.sh")
