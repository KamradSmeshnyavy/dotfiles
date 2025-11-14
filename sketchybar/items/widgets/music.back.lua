local colors = require("colors")
local settings = require("settings")

local music = sbar.add("item", "widgets.music", {
    position = "right",
    -- icon = {
    --     string = "♫",
    --     color = colors.grey,
    --     font = {
    --         size = 12.0,
    --     },
    -- },
    label = {
        string = "No music",
        color = colors.white,
        font = {
            family = settings.font.text,
            size = 12.0,
        },
        width = "130", --or dynamic
    },
    update_freq = 3,
    background = {
        color = colors.bg1,
        height = 26,
    },
    padding_left = 4,
    padding_right = 4,
})

-- Скобка
-- sbar.add("bracket", "widgets.music.bracket", { music.name }, {
--     background = {
--         color = colors.transparent,
--         height = 28,
--         border_color = colors.grey,
--     }
-- })

-- Отступ
sbar.add("item", "widgets.music.padding", {
    position = "right",
    width = settings.group_paddings
})

-- Безопасная функция обновления
local function update_music()
    sbar.exec([[
        osascript -e '
            try
                tell application "Spotify"
                    if player state is playing then
                        set trackName to name of current track
                        return "PLAYING:" & trackName
                    else
                        return "NOT_PLAYING"
                    end if
                end tell
            on error
                return "ERROR"
            end try
        ' 2>/dev/null
    ]], function(result)
        if not result then return end

        result = result:gsub("\n", "")

        if result:find("PLAYING:") then
            local track = result:gsub("PLAYING:", "")
            if #track > 20 then
                track = track:sub(1, 20) .. "..."
            end
            music:set({
                label = track,
                icon = { color = colors.green }
            })
        else
            music:set({
                label = "No music",
                icon = { color = colors.grey }
            })
        end
    end)
end

-- Простые подписки
music:subscribe("routine", update_music)
music:subscribe("mouse.clicked", function()
    sbar.exec("open -a 'Spotify'")
end)

-- Начальное обновление
update_music()