-- Monitors configuration
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))
hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = "2" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
hl.env("QT_ENABLE_HIGHDPI_SCALING", "1")
hl.env("QT_SCALE_FACTOR_ROUNDING_POLICY", "PassThrough")
hl.env("XFT_DPI", "144")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
o.exec_on_start(
	"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORM XFT_DPI PATH"
)
