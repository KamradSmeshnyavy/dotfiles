-- Monitors configuration
-- ~/.local/bin первым и один раз: файл выполняется при каждом `hyprctl reload` (Customizer делает это часто),
-- и безусловное добавление копило сотни копий в PATH оболочки и всего, что из неё запускается.
do
  local bin = os.getenv("HOME") .. "/.local/bin"
  local kept = { bin }
  for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
    if entry ~= bin then table.insert(kept, entry) end
  end
  hl.env("PATH", table.concat(kept, ":"))
end
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
