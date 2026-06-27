#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader History Manager
# ===================================

HISTORY_FILE="$HOME/.ul_download_history"

save_history() {
    local type="$1"
    local url="$2"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | $type | $url" >> "$HISTORY_FILE"
}

show_history() {

    clear

    echo "========================================"
    echo "        DOWNLOAD HISTORY"
    echo "========================================"

    if [ ! -f "$HISTORY_FILE" ]; then
        echo
        echo "No history found."
        echo
        read -p "Press Enter..."
        return
    fi

    nl -w2 -s'. ' "$HISTORY_FILE"

    echo
    read -p "Press Enter..."
}

clear_history() {

    > "$HISTORY_FILE"

    echo
    echo "History cleared."
    sleep 1
}
