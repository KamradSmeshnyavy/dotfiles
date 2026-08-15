hl.config({
  input = {
    kb_layout = "custom, custom",
    kb_variant = "us_overlay, ru_overlay",
    kb_options = "grp:alt_space_toggle",
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    sensitivity = 0.35,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
      disable_while_typing = false,
      drag_3fg = 1,
    },
  },
})


o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
