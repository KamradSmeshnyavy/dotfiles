#!/bin/bash

# Гасит mouseless на время работы wl-kbptr и возвращает его в прежнее состояние
# (в том числе при отмене по Esc, ошибке или убийстве скрипта).
#
# Состояние берём из /tmp/mouseless_state, который mouseless пишет сам в
# enterCommand/exitCommand — единственный источник правды, он не рассинхронится.
# Гасим через TCP-сервер kanata: kanata тапает виртуальную клавишу mless-off (f21)
# в своё виртуальное устройство, а именно его и слушает mouseless (обратно — mless-on, f20).
#
# Слой `mouse` у kanata при этом НЕ переключается — и это правильно: пока идёт
# wl-kbptr, буквы остаются голыми, без homerow-модов, что для набора меток лучше.

KANATA_ADDR=127.0.0.1
KANATA_PORT=10000
STATE_FILE=/tmp/mouseless_state

# Отдельные сигналы, а не общий тоггл: потерянный или лишний тап тогда
# ничего не инвертирует, а просто ничего не делает.
tap_kanata() {
    exec 3<>"/dev/tcp/$KANATA_ADDR/$KANATA_PORT" 2>/dev/null || return 1
    printf '{"ActOnFakeKey":{"name":"%s","action":"Tap"}}\n' "$1" >&3
    exec 3>&-
}

STATE=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if [ "$STATE" = "1" ]; then
    if ! tap_kanata mless-off; then
        # Лучше сказать прямо, чем молча уронить пользователя в конфликт клавиш.
        notify-send 'wl-kbptr' 'kanata TCP недоступен: mouseless не выключен'
        STATE=0
    fi
    sleep 0.1
fi

restore_mouseless() {
    if [ "$STATE" = "1" ]; then
        tap_kanata mless-on
    fi
}
trap restore_mouseless EXIT

wl-kbptr "$@"
