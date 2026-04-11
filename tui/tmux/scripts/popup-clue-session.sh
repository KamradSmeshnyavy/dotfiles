SESSION="popup-clue"

if [ "$(tmux display-message -p -F "#{session_name}")" = "$SESSION" ]; then
    tmux detach-client
else
    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION"
    fi
    tmux popup -h 70% -w 70% -E "tmux attach -t $SESSION \; list-keys -T SESSION_MODE | column -t"
fi