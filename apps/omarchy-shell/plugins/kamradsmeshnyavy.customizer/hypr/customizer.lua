-- Optional Hyprland hook for the Customizer. Re-applies the saved choices while the config
-- loads, so a `hyprctl reload` never flashes back to the defaults. Without it the Customizer
-- still restores them right after every reload (it listens for `configreloaded`).
--
-- Load it last, e.g. at the end of ~/.config/hypr/looknfeel.lua:
--   dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/hypr/customizer.lua")

local home = os.getenv("HOME")
local state = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")
local plugin = home .. "/.config/omarchy/plugins/kamradsmeshnyavy.customizer"

local function read_line(path)
	local f = io.open(path, "r")
	local line = f and f:read("*l")
	if f then
		f:close()
	end
	return line
end

local function exists(path)
	local f = path and io.open(path, "r")
	if f then
		f:close()
	end
	return f ~= nil
end

-- "<name> <numbers…>" saved by scripts/opacity.sh and scripts/blur.sh.
local function values(name)
	local out = {}
	for n in (read_line(state .. "/hypr/" .. name) or ""):gmatch("%s([%d.]+)") do
		out[#out + 1] = tonumber(n)
	end
	return out
end

-- Screen shader + the damage_tracking it needs: "<path> <damage_tracking>" (scripts/crt-toggle.sh).
do
	local path, dt = (read_line(state .. "/hypr/screen-shader") or ""):match("^(%S+)%s+(%d)$")
	if path and not exists(path) then
		-- Saved by an older layout: find the shader by name.
		local name = path:match("([^/]+)%.frag$") or ""
		for _, dir in ipairs({ home .. "/.config/omarchy/customizer/shaders", plugin .. "/shaders" }) do
			if exists(dir .. "/" .. name .. ".frag") then
				path = dir .. "/" .. name .. ".frag"
				break
			end
		end
	end
	if path and exists(path) then
		hl.config({ decoration = { screen_shader = path }, debug = { damage_tracking = tonumber(dt) } })
	end
end

do
	local o = values("opacity")
	if #o == 2 then
		hl.config({ decoration = { active_opacity = o[1], inactive_opacity = o[2] } })
	end

	local b = values("blur")
	if #b == 4 then
		hl.config({
			decoration = {
				blur = {
					enabled = b[1] > 0,
					size = math.max(1, b[1]),
					passes = b[2],
					vibrancy = b[3],
					noise = b[4],
				},
			},
		})
	end
end

-- The animation preset picked in the Customizer.
local anims = state .. "/omarchy-customizer/animations.lua"
if exists(anims) then
	dofile(anims)
end

-- Blur behind the Customizer overlay itself.
hl.layer_rule({ match = { namespace = "omarchy-customizer" }, blur = true, ignore_alpha = 0.6 })
