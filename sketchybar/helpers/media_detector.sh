#!/bin/bash

# Универсальный детектор медиа-контента
detect_media() {
    # 1. Пробуем nowplaying-cli
    local title=$(nowplaying-cli get title 2>/dev/null)
    local artist=$(nowplaying-cli get artist 2>/dev/null)
    local state=$(nowplaying-cli get state 2>/dev/null)

    if [ "$title" != "null" ] && [ -n "$title" ]; then
        echo "$state||$title||$artist"
        return 0
    fi

    # 2. Проверяем браузеры на YouTube
    local youtube_title=$(osascript -e '
        try
            tell application "Google Chrome"
                repeat with w in every window
                    repeat with t in every tab of w
                        if URL of t contains "youtube.com/watch" then
                            return name of t
                        end if
                    end repeat
                end repeat
            end tell
        on error
            try
                tell application "Safari"
                    repeat with w in every window
                        repeat with t in every tab of w
                            if URL of t contains "youtube.com/watch" then
                                return name of t
                            end if
                        end repeat
                    end repeat
                end tell
            on error
                return ""
            end try
        end try
    ' 2>/dev/null)

    if [ -n "$youtube_title" ]; then
        # Убираем " - YouTube" из названия
        local clean_title=$(echo "$youtube_title" | sed 's/ - YouTube$//')
        echo "playing||$clean_title||YouTube"
        return 0
    fi

    echo "not_playing||No media||"
}

detect_media