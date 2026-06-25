#!/data/data/com.termux/files/usr/bin/bash

# --- Anti-Debug Protection ---
if [ -n "$LD_PRELOAD" ]; then
    echo "Tampering detected!"
    exit 1
fi

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
# --- Security Check Functions ---
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
            echo -e "${GREEN}🔓 Device already verified! Opening app...${RESET}"
            sleep 1
            return 0
        fi
    fi
    return 1
}

# --- Verification System ---
attempts=0
check_ban

if! check_device_lock; then
    while true; do
        clear
        echo -e "${RED}=================================================${RESET}"
        echo -e "${RED} 🔒 PREMIUM APP LOCKED - ADVANCE SECURITY 🔒 ${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo -e "${WHITE} 📢 Instructions:${RESET}"
        echo -e "${GREEN} 1. Get secret code from Admin's Facebook Bio.${RESET}"
        echo -e "${CYAN} 2. Internet required for online verification.${RESET}"
        echo -e "${YELLOW} 3. ${MAX_ATTEMPTS} wrong attempts = 1 hour ban.${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo
        echo -e "${CYAN}🔗 Facebook: ${FB_URL}${RESET}"
        echo -e "${MAGENTA}-------------------------------------------------${RESET}"
        echo -e "${WHITE}👉 Press ENTER to Open Facebook...${RESET}"
        read

        if command -v termux-open &> /dev/null; then
            termux-open "$FB_URL"
        fi

        echo
        printf "${WHITE}🔑 Enter Secret Key: ${RESET}"
        read user_code

        # Fetch server data
        echo -e "${YELLOW}⏳ Verifying with secure server...${RESET}"
        SERVER_DATA=$(curl -s --fail --max-time 10 "$KEY_URL")

        if [ -z "$SERVER_DATA" ]; then
            echo -e "\n${RED}❌ Server connection failed! Check internet.${RESET}"
            read
            continue
        fi

        REAL_KEY=$(echo "$SERVER_DATA" | jq -r '.key')
        EXPIRY=$(echo "$SERVER_DATA" | jq -r '.expiry')
        SERVER_VER=$(echo "$SERVER_DATA" | jq -r '.version')

        # Check expiry
        TODAY=$(date +%Y-%m-%d)
        if [[ "$TODAY" > "$EXPIRY" ]]; then
            echo -e "\n${RED}⛔ Key Expired! Contact admin for new key.${RESET}"
            echo -e "${WHITE}Key valid till: ${EXPIRY}${RESET}"
            read
            exit 1
        fi

        # Verify key
        if [ "$user_code" = "$REAL_KEY" ]; then
            echo "$REAL_KEY" > "$DEVICE_FILE"
            clear
            echo -e "${GREEN}=================================================${RESET}"
            echo -e "${GREEN}🎉 ACCESS GRANTED - DEVICE REGISTERED ✔${RESET}"
            echo -e "${GREEN}=================================================${RESET}"
            echo -e "${WHITE}Key Valid Till: ${EXPIRY}${RESET}"
            echo -e "${CYAN}Press Enter to continue...${RESET}"
            read
            break
        else
            attempts=$((attempts + 1))
            REMAIN=$((MAX_ATTEMPTS - attempts))
            if [ $attempts -ge $MAX_ATTEMPTS ]; then
                BAN_UNTIL=$(($(date +%s) + 3600))
                echo "$BAN_UNTIL" > "$BAN_FILE"
                echo -e "\n${RED}⛔ 3 Wrong Attempts! Banned for 1 hour.${RESET}"
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

    echo -e " [1] ${GREEN}⭐ 1080p Video (Best Quality)${RESET}"
    echo -e " [2] ${BLUE}🎬 720p HD Video (Data Saver)${RESET}"
    echo -e " [3] ${YELLOW}🎧 MP3 Audio Only${RESET}"
    echo -e " [4] ${MAGENTA}🖼️ Image Download${RESET}"
    echo -e " [5] ${CYAN}📸 Video Thumbnail${RESET}"
    echo -e " [6] ${WHITE}📜 History Log${RESET}"
    echo -e " [7] ${RED}🗑️ Clear History${RESET}"
    echo -e " [8] ${GREEN}🔄 Update Script${RESET}"
    echo -e " [9] ${YELLOW}🔐 Lock Device${RESET}"
    echo -e " [0] ${RED}❌ Exit${RESET}"
    echo
    echo -e "${CYAN}-------------------------------------------------${RESET}"

    printf "${WHITE}👉 Option (0-9): ${RESET}"
    read op

    case $op in
        6)
            clear
            echo -e "${YELLOW}=== DOWNLOAD HISTORY ===${RESET}"
            if [ -f "$HISTORY_FILE" ]; then
                cat "$HISTORY_FILE"
            else
                echo -e "${RED}No history found!${RESET}"
            fi
            read
            ;;
        7)
            > "$HISTORY_FILE"
            echo -e "${GREEN}History cleared!${RESET}"
            sleep 1
            ;;
        8)
            cd "$SCRIPT_DIR"
            git pull
            echo -e "${GREEN}Updated! Restarting...${RESET}"
            sleep 2
            exec bash "$0"
            ;;
        9)
            rm -f "$DEVICE_FILE"
            echo -e "${YELLOW}Device locked! Restart app to enter key.${RESET}"
            sleep 2
            exit 0
            ;;
        0)
            echo -e "${RED}Goodbye! 👋${RESET}"
            exit 0
            ;;
        [1-5])
            if [ "$op" = "4" ]; then
                printf "${WHITE}🔗 Image URL: ${RESET}"
            else
                printf "${WHITE}🔗 Media Link: ${RESET}"
            fi
            read url

            if [ -z "$url" ] || [[! "$url" =~ ^https?:// ]]; then
                echo -e "${RED}❌ Invalid URL!${RESET}"
                read
                continue
            fi

            OUT="$DOWNLOAD_DIR/%(title).50s.%(ext)s"
            case $op in
                1) $YTDL -f "bestvideo+bestaudio/best" -o "$OUT" "$url"; type_str="1080p" ;;
                2) $YTDL -f "bestvideo[height<=720]+bestaudio/best" -o "$OUT" "$url"; type_str="720p" ;;
                3) $YTDL -x --audio-format mp3 -o "$OUT" "$url"; type_str="MP3" ;;
                4) curl -L -o "$DOWNLOAD_DIR/img_$(date +%s).jpg" "$url"; type_str="Image" ;;
                5) $YTDL --skip-download --write-thumbnail -o "$DOWNLOAD_DIR/thumb" "$url"; type_str="Thumbnail" ;;
            esac

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✔ Success! Saved to $DOWNLOAD_DIR${RESET}"
                echo "$(date '+%Y-%m-%d %H:%M:%S') | $type_str | $url" >> "$HISTORY_FILE"
            else
                echo -e "${RED}❌ Download failed!${RESET}"
            fi
            read
            ;;
        *)
            echo -e "${RED}❌ Invalid option!${RESET}"
            sleep 1
            ;;
    esac
done
