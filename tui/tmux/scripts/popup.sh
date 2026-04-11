SESSION="popup"

if [ "$(tmux display-message -p -F "#{session_name}")" = "$SESSION" ]; then
    tmux detach-client
else
    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION"
    fi
        tmux popup -h 70% -w 70% -E "tmux attach -t $SESSION || tmux new -s popup" &
    tmux source "$XDG_CONFIG_HOME/tmux/tmux.conf"
fi