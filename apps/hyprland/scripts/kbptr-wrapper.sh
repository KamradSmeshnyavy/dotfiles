#!/bin/bash

STATE_FILE=/tmp/mouseless_state

STATE=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if [ "$STATE" = "1" ]; then
    ydotool key 190:1 190:0
    sleep 0.1
fi

# Гарантированно возвращаем mouseless в прежнее состояние даже при
# отмене wl-kbptr (Esc), ошибках или завершении скрипта.
restore_mouseless() {
    if [ "$STATE" = "1" ]; then
        ydotool key 190:1 190:0
        sleep 0.1
    fi
}
trap restore_mouseless EXIT

wl-kbptr -o modes=tile,bisect