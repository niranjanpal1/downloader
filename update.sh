#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader Update Manager
# ===================================

check_update() {

    clear

    echo "=================================="
    echo "     UL Downloader Updater"
    echo "=================================="
    echo

    if [ ! -d ".git" ]; then
        echo "Git repository not found."
        read -p "Press Enter..."
        return
    fi

    echo "Checking for updates..."
    git fetch origin

    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)

    if [ "$LOCAL" = "$REMOTE" ]; then
        echo
        echo "You are using the latest version."
    else
        echo
        echo "New update found!"
        read -p "Update now? (y/n): " ans

        if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
            git pull
            echo
            echo "Update completed."
        fi
    fi

    echo
    read -p "Press Enter..."
}
