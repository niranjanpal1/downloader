#!/data/data/com.termux/files/usr/bin/bash

# --- Color Codes ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# --- Configuration ---
FB_URL="https://www.facebook.com/akash.pal.niranjan"
KEY_URL="https://raw.githubusercontent.com/niranjanpal1/downloader/main/key.txt"
YTDL="yt-dlp --no-cache-dir --rm-cache-dir"
DOWNLOAD_DIR="/sdcard/Download"
HISTORY_FILE="$DOWNLOAD_DIR/download_history.txt"
SCRIPT_DIR="$HOME/downloader"
DEVICE_FILE="$HOME/.vd_device_lock"
BAN_FILE="$HOME/.vd_ban"
MAX_ATTEMPTS=3
SCRIPT_VERSION="1.0"

# Auto install dependencies
if! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}📦 yt-dlp install korchi...${RESET}"
    pip install -U yt-dlp
fi
if! command -v jq &> /dev/null; then
    echo -e "${YELLOW}📦 jq install korchi...${RESET}"
    pkg install jq -y
fi

# Storage setup
if [! -d "$DOWNLOAD_DIR" ]; then
    termux-setup-storage
    sleep 2
    mkdir -p "$DOWNLOAD_DIR"
fi

clear
# --- Security Functions ---
check_ban() {
    if [ -f "$BAN_FILE" ]; then
        BAN_TIME=$(cat "$BAN_FILE")
        NOW=$(date +%s)
        if [ $NOW -lt $BAN_TIME ]; then
            REMAIN=$(( ($BAN_TIME - $NOW) / 60 ))
            echo -e "${RED}⛔ Too many wrong attempts! Try after ${REMAIN} minutes.${RESET}"
            exit 1
        else
            rm "$BAN_FILE"
        fi
    fi
}

check_device_lock() {
    if [ -f "$DEVICE_FILE" ]; then
        SAVED_KEY=$(cat "$DEVICE_FILE")
        SERVER_DATA=$(curl -s --fail --max-time 10 "$KEY_URL")
        REAL_KEY=$(echo "$SERVER_DATA" | jq -r '.key')
        if [ "$SAVED_KEY" = "$REAL_KEY" ]; then
            echo -e "${GREEN}🔓 Device already verified!${RESET}"
            sleep 1
            return 0
        fi
    fi
    return 1
}

# --- Verification ---
attempts=0
check_ban

if! check_device_lock; then
    while true; do
        clear
        echo -e "${RED}=================================================${RESET}"
        echo -e "${RED} 🔒 PREMIUM APP LOCKED - SECURE v${SCRIPT_VERSION} 🔒 ${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo -e "${WHITE} 1. Get code from Admin's Facebook Bio${RESET}"
        echo -e "${YELLOW} 2. ${MAX_ATTEMPTS} wrong attempts = 1 hour ban${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo
        echo -e "${CYAN}🔗 Facebook: ${FB_URL}${RESET}"
        echo -e "${WHITE}👉 Press ENTER to Open Facebook...${RESET}"
        read

        if command -v termux-open &> /dev/null; then
            termux-open "$FB_URL"
        fi

        echo
        printf "${WHITE}🔑 Enter Secret Key: ${RESET}"
        read user_code

        echo -e "${YELLOW}⏳ Verifying with server...${RESET}"
        SERVER_DATA=$(curl -s --fail --max-time 10 "$KEY_URL")

        if [ -z "$SERVER_DATA" ]; then
            echo -e "\n${RED}❌ Server connection failed!${RESET}"
            read
            continue
        fi

        REAL_KEY=$(echo "$SERVER_DATA" | jq -r '.key')
        EXPIRY=$(echo "$SERVER_DATA" | jq -r '.expiry')

        TODAY=$(date +%Y-%m-%d)
        if [[ "$TODAY" > "$EXPIRY" ]]; then
            echo -e "\n${RED}⛔ Key Expired! Valid till: ${EXPIRY}${RESET}"
            read
            exit 1
        fi

        if [ "$user_code" = "$REAL_KEY" ]; then
            echo "$REAL_KEY" > "$DEVICE_FILE"
            clear
            echo -e "${GREEN}=================================================${RESET}"
            echo -e "${GREEN}🎉 ACCESS GRANTED - DEVICE REGISTERED ✔${RESET}"
            echo -e "${GREEN}=================================================${RESET}"
            echo -e "${WHITE}Valid Till: ${EXPIRY}${RESET}"
            echo -e "${CYAN}Press Enter...${RESET}"
            read
            break
        else
            attempts=$((attempts + 1))
            REMAIN=$((MAX_ATTEMPTS - attempts))
            if [ $attempts -ge $MAX_ATTEMPTS ]; then
                BAN_UNTIL=$(($(date +%s) + 3600))
                echo "$BAN_UNTIL" > "$BAN_FILE"
                echo -e "\n${RED}⛔ Banned for 1 hour!${RESET}"
                exit 1
            fi
            echo -e "\n${RED}❌ Invalid Key! ${REMAIN} attempts left.${RESET}"
            read
        fi
    done
fi

# --- Main Menu ---
while true; do
    clear
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${MAGENTA} 🚀 ULTIMATE DOWNLOADER - SECURE PRO v${SCRIPT_VERSION} ${RESET}"
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${GREEN}🔓 Status: Verified | 👤 Admin: Akash Pal${RESET}"
    echo

    echo -e " [1] ${GREEN}⭐ 1080p Video${RESET}"
    echo -e " [2] ${BLUE}🎬 720p HD Video${RESET}"
    echo -e " [3] ${YELLOW}🎧 MP3 Audio${RESET}"
    echo -e " [4] ${MAGENTA}🖼️ Image Download${RESET}"
    echo -e " [5] ${CYAN}📸 Thumbnail${RESET}"
    echo -e " [6] ${WHITE}📜 History${RESET}"
    echo -e " [7] ${RED}🗑️ Clear History${RESET}"
    echo -e " [8] ${GREEN}🔄 Update${RESET}"
    echo -e " [9] ${YELLOW}🔐 Lock Device${RESET}"
    echo -e " [0] ${RED}❌ Exit${RESET}"
    echo
    printf "${WHITE}👉 Option (0-9): ${RESET}"
    read op

    case $op in
        6) clear; cat "$HISTORY_FILE" 2>/dev/null || echo "No history"; read ;;
        7) > "$HISTORY_FILE"; echo "Cleared!"; sleep 1 ;;
        8) cd "$SCRIPT_DIR"; git pull; exec bash "$0" ;;
        9) rm -f "$DEVICE_FILE"; echo "Locked!"; sleep 1; exit 0 ;;
        0) exit 0 ;;
        [1-5])
            printf "${WHITE}🔗 URL: ${RESET}"; read url
            if [ -z "$url" ] || [[! "$url" =~ ^https?:// ]]; then
                echo "${RED}Invalid URL!${RESET}"; read; continue
            fi
            OUT="$DOWNLOAD_DIR/%(title).50s.%(ext)s"
            case $op in
                1) $YTDL -f "bestvideo+bestaudio/best" -o "$OUT" "$url"; type_str="1080p" ;;
                2) $YTDL -f "bestvideo[height<=720]+bestaudio/best" -o "$OUT" "$url"; type_str="720p" ;;
                3) $YTDL -x --audio-format mp3 -o "$OUT" "$url"; type_str="MP3" ;;
                4) curl -L -o "$DOWNLOAD_DIR/img_$(date +%s).jpg" "$url"; type_str="Image" ;;
                5) $YTDL --skip-download --write-thumbnail -o "$DOWNLOAD_DIR/thumb" "$url"; type_str="Thumb" ;;
            esac
            [ $? -eq 0 ] && echo "$(date '+%Y-%m-%d %H:%M:%S') | $type_str | $url" >> "$HISTORY_FILE"
            read
            ;;
        *) echo "${RED}Invalid!${RESET}"; sleep 1 ;;
    esac
done
