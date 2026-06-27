#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader Utility Functions
# ===================================

clean_terminal_traces() {
    rm -f "$SESSION_TOKEN"
    history -c 2>/dev/null
    history -w 2>/dev/null
    [ -f ~/.bash_history ] && : > ~/.bash_history
}

calculate_days_left() {
    local expiry_date="$1"

    if [ -z "$expiry_date" ] || [ "$expiry_date" = "null" ]; then
        echo 0
        return
    fi

    local now=$(date +%s)
    local exp=$(date -d "$expiry_date" +%s 2>/dev/null)

    if [ -z "$exp" ]; then
        echo 0
        return
    fi

    local days=$(((exp-now)/86400))

    [ "$days" -lt 0 ] && days=0

    echo "$days"
}

get_secure_hw_sig() {
    echo -n "$(uname -m)$(getprop ro.serialno)$(getprop ro.product.model)$(uname -r)" \
    | md5sum | cut -c1-16 | tr 'a-z' 'A-Z'
}
