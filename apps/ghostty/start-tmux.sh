#!/bin/bash
tmux has-session -t work-flow 2>/dev/null
if [ $? -eq 0 ]; then
  tmux attach-session -t work-flow
else
  tmux new-session -s work-flow
fi
