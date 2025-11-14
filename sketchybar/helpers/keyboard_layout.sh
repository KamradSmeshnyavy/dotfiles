# #!/bin/bash

# get_keyboard_layout() {
#     # Используем AppleScript для получения текущей раскладки
#     layout=$(osascript -e 'tell application "System Events" to get the name of first input source whose selected is true' 2>/dev/null)

#     # Очищаем вывод
#     layout=$(echo "$layout" | tr -d '\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

#     # Определяем короткое имя на основе ваших раскладок
#     case "$layout" in
#         "ABC") echo "EN" ;;
#         "Russian – PC") echo "RU" ;;
#         *"Russian"*) echo "RU" ;;
#         *"U.S."*) echo "EN" ;;
#         *"ABC"*) echo "EN" ;;
#         *) echo "$layout" | cut -c1-2 ;;
#     esac
# }

# # Основная логика
# if [ "$1" = "get" ]; then
#     get_keyboard_layout
# else
#     # Режим наблюдения
#     while true; do
#         layout=$(get_keyboard_layout)
#         echo "$layout"
#         sleep 2
#     done
# fi