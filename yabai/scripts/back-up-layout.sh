#!/bin/bash
# window_layout_backup.sh - Backup of the current window arrangement

BACKUP_DIR="$HOME/.config/yabai/backups"
BACKUP_FILE="$BACKUP_DIR/layout_$(date +%Y%m%d_%H%M%S).json"

mkdir -p "$BACKUP_DIR"

# Сохраняем текущее состояние
yabai -m query --spaces | jq 'map({index: .index, windows: [.[] | .id]})' > "$BACKUP_FILE"

echo "Layout saved to: $BACKUP_FILE"