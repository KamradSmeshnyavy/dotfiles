#!/usr/bin/env bash

# 1. Пути к файлу меню BlackArch
if [ -f "$HOME/.fluxbox/menu" ]; then
    MENU_FILE="$HOME/.fluxbox/menu"
elif [ -f "/usr/share/blackarch/config/fluxbox/menu" ]; then
    MENU_FILE="/usr/share/blackarch/config/fluxbox/menu"
else
    exit 1
fi

# 2. Если аргументов нет — отдаем категории для Rofi
if [ -z "$1" ]; then
    awk -F'[()]' '/\[submenu\]/ {print $2}' "$MENU_FILE" | grep -v -E "BlackArch|Fluxbox|Styles|System"
    exit 0
fi

# 3. Проверяем, является ли выбор категорией
IS_SUBCATEGORY=$(awk -F'[()]' -v cat="$1" '/\[submenu\]/ && $2 == cat {print 1}' "$MENU_FILE")

if [ "$IS_SUBCATEGORY" ] && [ "$IS_SUBCATEGORY" -eq 1 ]; then
    # Отдаем список утилит внутри выбранной категории
    awk -v category="$1" '
    BEGIN { FS="[()]"; show=0 }
    /\[submenu\]/ { if ($2 == category) show=1; next }
    /\[end\]/ { if (show==1) show=0 }
    /\[exec\]/ { if (show==1) print $2 }
    ' "$MENU_FILE"
else
    # 4. Работаем с конечной командой
    ESCAPED_CMD=$(echo "$1" | sed 's/[.[\*^$()+?{|]/\\&/g')
    RAW_COMMAND=$(awk -F'[{}]' -v binary="($ESCAPED_CMD)" '$0 ~ binary {print $2}' "$MENU_FILE" | head -n 1)
    
    if [ -n "$RAW_COMMAND" ]; then
        # ОЧИСТКА: Удаляем вызовы популярных терминалов и их флаги (-e, -hold, --hold, --noclose)
        # Это гарантирует, что мы получим чистую бинарную команду утилиты
        COMMAND=$(echo "$RAW_COMMAND" | sed -E 's/^(kitty|alacritty|xterm|urxvt|st|xfce4-terminal)\s+((-e|--hold|--noclose|-hold)\s+)?//g')

        # Проверяем, является ли программа графической (GUI)
        if [[ "$COMMAND" =~ "wireshark" || "$COMMAND" =~ "zenmap" || "$COMMAND" =~ "burpsuite" || "$COMMAND" =~ "ghidra" ]]; then
            # GUI-софт запускаем напрямую в фоне через i3-msg
            i3-msg exec -- "$COMMAND"
        else
            # Консольный софт запускаем полностью скрытно без создания окон
            SAFE_NAME=$(echo "$1" | tr '[:space:].-/' '_')
            LOG_FILE="/tmp/blackarch_${SAFE_NAME}.log"
            
            echo "=== Запуск команды: $COMMAND ===" > "$LOG_FILE"
            
            # setsid полностью изолирует процесс, убирая любые окна
            setsid bash -c "$COMMAND" >> "$LOG_FILE" 2>&1 &
            
            # Завершаем скрипт для Rofi
            exit 0
        fi
    fi
fi

