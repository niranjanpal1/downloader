#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader Login
# ===================================

APP_KEY="UL2026"

login() {
    clear
    echo "=================================="
    echo "      UL Downloader Login"
    echo "=================================="
    echo

    read -p "Enter Access Key: " KEY

    if [ "$KEY" = "$APP_KEY" ]; then
        echo
        echo "Login Successful!"
        sleep 1
        return 0
    else
        echo
        echo "Invalid Key!"
        sleep 2
        exit 1
    fi
}
