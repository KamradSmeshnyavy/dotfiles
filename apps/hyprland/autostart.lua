-- Extra autostart processes

-- Environment variables migrated from env.conf
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GTK_USE_PORTAL", "1")

-- Autostart programs
o.exec_on_start("/usr/lib/libexec/kdeconnectd")
o.exec_on_start("kdeconnect-indicator")
o.exec_on_start("wl-paste --type text --watch cliphist store")
o.exec_on_start("wl-paste --type image --watch cliphist store")
o.exec_on_start("hyprctl setcursor BreezeX-RosePine-Linux 24")

-- Omarchy 4 uses Quickshell for notifications natively.
-- Old mako/swaync replacement is no longer needed.
