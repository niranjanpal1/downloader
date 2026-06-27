#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader Network Library
# ===================================

fetch_server_data() {
    curl -s --fail --max-time 10 "$RAW_JSON_URL"
}

redirect_fb() {
    if command -v termux-open-url >/dev/null 2>&1; then
        termux-open-url "$FB_URL"
    else
        am start -a android.intent.action.VIEW -d "$FB_URL" >/dev/null 2>&1
    fi
}

check_runtime_integrity() {
    if ps -ef | grep -E "strace|gdb|ltrace" | grep -v grep >/dev/null 2>&1; then
        echo -e "${RED}Security warning: debugging tools detected.${RESET}"
        exit 1
    fi
}
