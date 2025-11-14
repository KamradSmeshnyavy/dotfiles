local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Создаем элемент для отображения раскладки
local keyboard = sbar.add("item", "widgets.keyboard", {
  position = "right",
  icon = {
    string = icons.keyboard,
    color = colors.white,
    font = {
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
  },
  label = {
    string = "EN",
    color = colors.white,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 13.0,
    },
    padding_left = 0,
    padding_right = settings.paddings,
  },
  update_freq = 2,
  background = {
    color = colors.bg1,
    border_color = colors.black,
    border_width = 1,
    height = 26,
  },
  padding_left = 1,
  padding_right = 1,
})

-- Добавляем скобку для двойной границы
sbar.add("bracket", "widgets.keyboard.bracket", { keyboard.name }, {
  background = {
    color = colors.transparent,
    height = 28,
    border_color = colors.grey,
    border_width = 2,
  }
})

-- Добавляем отступ
sbar.add("item", "widgets.keyboard.padding", {
  position = "right",
  width = settings.group_paddings
})

-- Функция для получения текущей раскладки через im-select
local function update_keyboard_layout()
  sbar.exec("im-select", function(layout_id)
    if layout_id and layout_id ~= "" then
      layout_id = layout_id:gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n", "")

      local short_layout = "EN" -- по умолчанию

      if string.find(layout_id, "Russian") then
        short_layout = "RU"
      elseif string.find(layout_id, "ABC") then
        short_layout = "EN"
      elseif layout_id == "com.apple.keylayout.US" then
        short_layout = "EN"
      elseif layout_id == "com.apple.keylayout.RussianWin" then
        short_layout = "RU"
      end

      keyboard:set({ label = short_layout })
    else
      keyboard:set({ label = "??" })
    end
  end)
end

-- Подписываемся на события для обновления раскладки
keyboard:subscribe({ "forced", "routine", "system_woke" }, update_keyboard_layout)

-- Также обновляем при клике
keyboard:subscribe("mouse.clicked", update_keyboard_layout)

-- Инициализируем при загрузке
update_keyboard_layout()