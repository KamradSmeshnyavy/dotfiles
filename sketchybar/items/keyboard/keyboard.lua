local keyboard = SBAR.add("item", "widgets.keyboard", {
  position = "right",
  update_freq = 2,
  icon = {
    string = ICONS.keyboard or "KB",
    color = COLORS.text,
    font = {
      family = FONT.icon_font,
      style = FONT.style_map["Bold"],
      size = 14.0,
    },
    padding_left = PADDINGS,
    padding_right = PADDINGS,
  },
  label = {
    string = "??",
    color = COLORS.text,
    font = {
      family = FONT.label_font,
      style = FONT.style_map["Semibold"],
      size = 12.5,
    },
    padding_left = 0,
    padding_right = PADDINGS,
  },
--   background = {
--     color = COLORS.surface0,
--     border_color = COLORS.surface1,
--     border_width = 1,
--     height = 26,
--   },
  padding_left = 1,
  padding_right = 1,
})

SBAR.add("bracket", "widgets.keyboard.bracket", { keyboard.name }, {
--   background = {
--     color = COLORS.transparent,
--     height = 28,
--     border_color = COLORS.surface1,
--     border_width = 2,
--   },
})

SBAR.add("item", "widgets.keyboard.padding", {
  position = "right",
  width = GROUP_PADDINGS,
  drawing = true,
  background = { drawing = false },
  icon = { drawing = false },
  label = { drawing = false },
})

local layout_map = {
  ["com.apple.keylayout.US"] = "EN",
  ["com.apple.keylayout.ABC"] = "EN",
  ["com.apple.keylayout.British"] = "EN",
  ["com.apple.keylayout.Russian"] = "RU",
  ["com.apple.keylayout.RussianWin"] = "RU",
}

local layout_patterns = {
  russian = "RU",
  ru = "RU",
  us = "EN",
  abc = "EN",
  english = "EN",
}

local function normalize_layout_id(raw)
  if not raw then
    return nil
  end

  local trimmed = raw:gsub("\r", ""):gsub("\n", ""):gsub("^%s+", ""):gsub("%s+$", "")
  if trimmed == "" then
    return nil
  end

  if trimmed:find("not found", 1, true) or trimmed:find("cannot find", 1, true) then
    return nil
  end

  return trimmed
end

local last_short

local function layout_to_short(layout_id)
  if not layout_id then
    return "??"
  end

  local explicit = layout_map[layout_id]
  if explicit then
    return explicit
  end

  local lowered = layout_id:lower()
  for pattern, short in pairs(layout_patterns) do
    if lowered:find(pattern, 1, true) then
      return short
    end
  end

  local suffix = layout_id:match("%.([%a%d]+)$")
  if suffix and #suffix == 2 then
    return suffix:upper()
  end

  return "??"
end

local function apply_layout(short_code)
  if short_code == last_short then
    return
  end

  last_short = short_code
  keyboard:set({ label = { string = short_code } })
end

-- Poll current input source and update the label.
local function update_keyboard_layout()
  SBAR.exec("im-select", function(result)
    local layout_id = normalize_layout_id(result)
    local short_code = layout_to_short(layout_id)
    apply_layout(short_code)
  end)
end

keyboard:subscribe({ "forced", "routine", "system_woke" }, update_keyboard_layout)
keyboard:subscribe("mouse.clicked", update_keyboard_layout)

update_keyboard_layout()
