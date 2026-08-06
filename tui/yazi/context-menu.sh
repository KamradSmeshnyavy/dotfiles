#!/bin/bash
choice=$(printf "1. 📂 Open\n2. 🔍 Open with...\n3. 📦 Compress/Extract (Ouch)\n4. 📋 Copy\n5. ✂️ Cut\n6. 🗑️ Trash\n7. ❌ Delete Permanently\n8. 📝 Rename\n9. 💿 Mount/Unmount\n10. 🔌 Drag and Drop" | fzf --prompt="Context Menu> " --height=13 --layout=reverse --border=rounded)

case "$choice" in
    1.*) ya emit open ;;
    2.*) ya emit open --interactive ;;
    3.*) ya emit plugin ouch ;;
    4.*) ya emit yank ;;
    5.*) ya emit yank --cut ;;
    6.*) ya emit remove ;;
    7.*) ya emit remove --permanently ;;
    8.*) ya emit rename ;;
    9.*) ya emit plugin mount ;;
    10.*) ripdrag "$@" -x 2>/dev/null & ;;
esac
