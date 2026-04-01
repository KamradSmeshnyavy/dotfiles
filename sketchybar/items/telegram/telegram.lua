-- ============================================================================
-- Telegram Unread Counter Widget
-- ============================================================================

-- Иконка Telegram (добавь в таблицу ICONS, если используешь Nerd Fonts)
-- ICONS.telegram = ""   -- или "", либо просто эмодзи "📱"

local telegram = SBAR.add("item", "widgets.telegram", {
  position = "right",
  update_freq = 60, -- частота обновления (routine)
  icon = {
    string = ICONS.telegram or "📱", -- замени на свою иконку
    color = COLORS.text,
    font = {
      family = FONT.icon_font,
      style = FONT.style_map["Bold"],
      size = 14.0,
    },
    padding_left = PADDINGS,
    padding_right = 0, -- отступ справа будет от padding-элемента
  },
  label = {
    string = "0", -- начальное значение
    color = COLORS.text,
    font = {
      family = FONT.label_font,
      style = FONT.style_map["Semibold"],
      size = 12.5,
    },
    padding_left = 4,
    padding_right = PADDINGS,
  },
  -- Фон по желанию (раскомментируй, если нужен)
  -- background = {
  --   color = COLORS.surface0,
  --   border_color = COLORS.surface1,
  --   border_width = 1,
  --   height = 26,
  -- },
  padding_left = 1,
  padding_right = 1,
})

-- Добавляем элемент в bracket (группу) – опционально
SBAR.add("bracket", "widgets.telegram.bracket", { telegram.name }, {
  -- background = {
  --   color = COLORS.transparent,
  --   height = 28,
  --   border_color = COLORS.surface1,
  --   border_width = 2,
  -- },
})

-- Элемент-отступ справа для аккуратного выравнивания
SBAR.add("item", "widgets.telegram.padding", {
  position = "right",
  width = GROUP_PADDINGS,
  drawing = true,
  background = { drawing = false },
  icon = { drawing = false },
  label = { drawing = false },
})

-- ----------------------------------------------------------------------------
-- Функция получения количества непрочитанных уведомлений Telegram
-- ----------------------------------------------------------------------------
local function fetch_telegram_badge(callback)
  -- Команда использует lsappinfo для чтения бейджа из Dock
  -- Возвращает число или пустую строку, если уведомлений нет / приложение не запущено
  local cmd = [[
    lsappinfo info -only statuslabel Telegram | 
    sed -n 's/.*statuslabel = "\(.*\)"/\1/p'
  ]]

  SBAR.exec(cmd, function(badge)
    badge = badge:gsub("%s+", "") -- убираем пробелы и переносы
    if badge == nil or badge == "" then
      badge = "0"
    end
    callback(badge)
  end)
end

-- ----------------------------------------------------------------------------
-- Обновление отображения (вызывается по таймеру, при пробуждении и т.д.)
-- ----------------------------------------------------------------------------
local function update_telegram()
  fetch_telegram_badge(function(badge)
    telegram:set({ label = { string = badge } })
  end)
end

-- ----------------------------------------------------------------------------
-- Обработчик клика: открывает Telegram и принудительно обновляет бейдж
-- ----------------------------------------------------------------------------
local function on_click()
  os.execute("open -a Telegram") -- запуск/активация приложения
  update_telegram() -- немедленное обновление виджета
end

-- Подписка на события
telegram:subscribe({ "forced", "routine", "system_woke" }, update_telegram)
telegram:subscribe("mouse.clicked", on_click)

-- Первичное обновление при загрузке конфига
update_telegram()
