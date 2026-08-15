-- Monitors configuration

-- Prepend ~/.local/bin to PATH so wrappers (like quickshell) are intercepted
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))

hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = "2" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })

-- Global scaling variables (Applies 1.5x to all apps like Ghidra)
hl.env("QT_ENABLE_HIGHDPI_SCALING", "1")
hl.env("QT_SCALE_FACTOR", "1.5")
hl.env("QT_SCALE_FACTOR_ROUNDING_POLICY", "PassThrough")
hl.env("GDK_SCALE", "1.5")
hl.env("XFT_DPI", "144")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Update DBus env
o.exec_on_start("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_SCALE_FACTOR QT_QPA_PLATFORM GDK_SCALE XFT_DPI PATH")
