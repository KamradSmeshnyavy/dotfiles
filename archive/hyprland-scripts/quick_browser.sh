#!/bin/bash

APP_CLASS="chrome-google.com__-Default"

# Дефолтные значения, сохраненные с 1 воркспейса
DEFAULT_SIZE="exact 500 840"
DEFAULT_POS="exact 930 50"

# Получаем имя рабочего пространства, на котором сейчас находится браузер
window_workspace=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$APP_CLASS\") | .workspace.name")

if [ -z "$window_workspace" ]; then
    # 1. Браузера нет вообще. Запускаем на текущем воркспейсе.
    hyprctl dispatch exec "chromium --app=https://google.com"
    
    # Ждем появления окна (до 2 секунд), чтобы применить размеры
    for i in {1..20}; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$APP_CLASS\")" > /dev/null; then
            sleep 0.1
            break
        fi
        sleep 0.1
    done
    
    # Принудительно задаем дефолтные размеры ТОЛЬКО при создании окна
    hyprctl dispatch resizewindowpixel "$DEFAULT_SIZE,class:$APP_CLASS"
    hyprctl dispatch movewindowpixel "$DEFAULT_POS,class:$APP_CLASS"
else
    # Получаем имя активного (текущего) рабочего пространства
    active_workspace=$(hyprctl activeworkspace -j | jq -r '.name')
    
    if [ "$window_workspace" == "$active_workspace" ]; then
        # 2. Окно находится на нашем текущем воркспейсе. Прячем его в scratchpad.
        hyprctl dispatch movetoworkspacesilent "special:browser,class:$APP_CLASS"
    else
        # 3. Окно спрятано. Призываем на текущий воркспейс.
        # ВАЖНО: Мы НЕ вызываем resize и move, чтобы сохранить текущее состояние окна.
        hyprctl dispatch movetoworkspace "$active_workspace,class:$APP_CLASS"
        hyprctl dispatch focuswindow "class:$APP_CLASS"
    fi
fi
