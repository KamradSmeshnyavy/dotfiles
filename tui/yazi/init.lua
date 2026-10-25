-- Цвета yatline от темы Omarchy: plugins/yatline-omarchy.yazi/main.lua — слот omarchy-app-themes
local omarchy_theme = require("yatline-omarchy"):setup()

require("yatline"):setup({
  theme = omarchy_theme,
  section_separator = { open = "", close = "" },
  part_separator = { open = "", close = "" },
  inverse_separator = { open = "", close = "" },

  tab_width = 20,
  tab_use_inverse = false,
  show_background = true,

  display_header_line = true,
  display_status_line = true,

  component_positions = { "header", "tab", "status" },

  header_line = {
    left = {
      section_a = {
        { type = "line", custom = false, name = "tabs", params = { "left" } },
      },
      section_b = {},
      section_c = {},
    },
    right = {
      section_a = {},
      section_b = {},
      section_c = {},
    },
  },

  status_line = {
    left = {
      section_a = {
        { type = "string", custom = false, name = "tab_mode" },
      },
      section_b = {
        { type = "string", custom = false, name = "hovered_size" },
      },
      section_c = {
        { type = "string", custom = false, name = "hovered_path" },
        { type = "coloreds", custom = false, name = "count" },
      },
    },
    right = {
      section_a = {
        { type = "string", custom = false, name = "cursor_position" },
      },
      section_b = {
        { type = "string", custom = false, name = "cursor_percentage" },
      },
      section_c = {
        { type = "string", custom = false, name = "hovered_file_extension", params = { true } },
        { type = "coloreds", custom = false, name = "permissions" },
      },
    },
  },
})

require("smart-enter"):setup({
	open_multi = true,
})
require("git"):setup()

-- mactag — теги Finder, работают только на macOS (на Linux нет команды `tag`)
if ya.target_os() == "macos" then
	require("mactag"):setup({
		-- Keys used to add or remove tags
		keys = {
			r = "",
			o = "Study",
			y = "IMPORTANT",
			g = "git",
			b = "exec",
			p = "Sync",
			s = "System",
		},
		-- Colors used to display tags
		colors = {
			Red = "#ee7b70",
			Study = "#f5bd5c",
			IMPORTANT = "#fbe764",
			git = "#91fc87",
			exec = "#5fa3f8",
			Sync = "#cb88f8",
			System = "#cbffff",
		},
	})
end

require("full-border"):setup()

require("mime-ext.local"):setup({
	with_exts = {
		heic = "image/heic",
		heif = "image/heif",
		nu = "text/x-nushell",
	},
	fallback_file1 = true,
})
