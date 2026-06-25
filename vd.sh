#!/data/data/com.termux/files/usr/bin/bash            
# --- User Terminal UI Colors ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# --- Configurations ---
FB_URL="https://www.facebook.com/akash.pal.niranjan"
KEY_URL="https://raw.githubusercontent.com/niranjanpal1/downloader/main/key.json"
YTDL="yt-dlp --no-cache-dir --rm-cache-dir --concurrent-fragments 5"

DOWNLOAD_DIR="/sdcard/Download"
VIDEO_DIR="$DOWNLOAD_DIR/UL-Videos"
AUDIO_DIR="$DOWNLOAD_DIR/UL-Audio"
IMAGE_DIR="$DOWNLOAD_DIR/UL-Images"
HISTORY_FILE="$DOWNLOAD_DIR/download_history.txt"

DEVICE_FILE="$HOME/.vd_device_lock"
BAN_FILE="$HOME/.vd_ban"
MAX_ATTEMPTS=3
SCRIPT_VERSION="3.5-UL-SECURE"

# Install Tooling dependencies
if ! command -v yt-dlp &> /dev/null || ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}📦 Initializing Core Dependencies...${RESET}"
    pkg install jq -y && pip install -U yt-dlp
fi

mkdir -p "$VIDEO_DIR" "$AUDIO_DIR" "$IMAGE_DIR"

get_device_id() {
    echo "UL-$(uname -m | md5sum | cut -c1-8 | tr 'a-z' 'A-Z')-HW"
}
CURRENT_HW_ID=$(get_device_id)

calculate_days_left() {
    local expiry_date=$1
    if [ -z "$expiry_date" ] || [ "$expiry_date" = "null" ]; then echo "0"; return; fi
    local diff=$(( $(date -d "$expiry_date" +%s 2>/dev/null) - $(date +%s) ))
    local days=$((diff / 86400))
    if [ $days -lt 0 ]; then echo "0"; else echo "$days"; fi
}

# License Guard Security 
if [ -f "$BAN_FILE" ] && [ $(date +%s) -lt $(cat "$BAN_FILE") ]; then
    echo -e "${RED}⛔ Too many wrong attempts! Access suspended for 1 hour.${RESET}"; exit 1
fi

check_device_lock() {
    if [ -f "$DEVICE_FILE" ]; then
        SAVED_KEY=$(cat "$DEVICE_FILE")
        SERVER_DATA=$(curl -s --fail --max-time 10 "$KEY_URL")
        if [ $? -eq 0 ] && [ ! -z "$SERVER_DATA" ]; then
            USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".status")
            USER_EXPIRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".expiry")
            ALLOWED_HW_ID=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".device_id")
            if [ "$USER_STATUS" = "active" ] && [ "$ALLOWED_HW_ID" = "$CURRENT_HW_ID" ] && [[ ! "$(date +%Y-%m-%d)" > "$USER_EXPIRY" ]]; then
                GLOBAL_DAYS_LEFT=$(calculate_days_left "$USER_EXPIRY")
                return 0
            fi
        fi
    fi
    return 1
}

if ! check_device_lock; then
    attempts=0
    SERVER_DATA=$(curl -s --fail --max-time 10 "$KEY_URL")
    ADMIN_NOTICE=$(echo "$SERVER_DATA" | jq -r '.notice')
    
    while true; do
        clear
        echo -e "${RED}=================================================${RESET}"
        echo -e "${RED}   🔒 HARDWARE LEVEL ANTI-SHARE LOCKED - v${SCRIPT_VERSION} ${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo -e "${WHITE} 📲 YOUR DEVICE ID : ${CYAN}$CURRENT_HW_ID${RESET}"
        echo -e "${YELLOW} 📢 NOTICE: $ADMIN_NOTICE${RESET}"
        echo -e "${CYAN}🔗 Contact Admin to Register: ${FB_URL}${RESET}"
        echo -e "${RED}-------------------------------------------------${RESET}"
        printf "${WHITE}🔑 Enter Your Registered UL Key: ${RESET}"
        read user_code

        USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".status")
        USER_EXPIRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".expiry")
        ALLOWED_HW_ID=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".device_id")
        USER_REASON=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".reason")

        if [ "$USER_STATUS" = "null" ]; then
            attempts=$((attempts + 1))
            if [ $attempts -ge $MAX_ATTEMPTS ]; then
                echo $(($(date +%s) + 3600)) > "$BAN_FILE"; exit 1
            fi
            echo -e "${RED}❌ Invalid Key!${RESET}"; read
        elif [ "$USER_STATUS" = "blocked" ]; then
            echo -e "${RED}⛔ Blocked! Reason: $USER_REASON${RESET}"; read; exit 1
        elif [ "$ALLOWED_HW_ID" != "null" ] && [ "$ALLOWED_HW_ID" != "$CURRENT_HW_ID" ]; then
            echo -e "${RED}⛔ HARDWARE MISMATCH! Registered to another phone.${RESET}"; read; exit 1
        elif [[ "$(date +%Y-%m-%d)" > "$USER_EXPIRY" ]]; then
            echo -e "${RED}⛔ Key Expired!${RESET}"; read; exit 1
        elif [ "$USER_STATUS" = "active" ]; then
            if [ "$ALLOWED_HW_ID" = "null" ]; then
                echo -e "${YELLOW}⚠️ Key device unmapped! Provide Device ID to Admin.${RESET}"; read; continue
            fi
            echo "$user_code" > "$DEVICE_FILE"
            GLOBAL_DAYS_LEFT=$(calculate_days_left "$USER_EXPIRY")
            break
        fi
    done
fi

# --- Main Downloader Hub Loop ---
while true; do
    clear
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${MAGENTA} 🚀  ULTIMATE DOWNLOADER - UL HARDENED PRO HUB ${RESET}"
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${GREEN}🔓 Device Identity: Verified | ⏳ Validity: $GLOBAL_DAYS_LEFT Days Left${RESET}"
    echo
    echo -e " [1] 💎 Max 1080p Quality Video     [4] 🖼️ Direct Image Downloader"
    echo -e " [2] 🎬 720p HD Quality Video      [5] 📸 Video Thumbnail Extractor"
    echo -e " [3] 🎧 High Quality Audio MP3      [0] ❌ Exit Downloader"
    echo -e "${CYAN}-------------------------------------------------${RESET}"
    printf "${WHITE}👉 Choice (0-5): ${RESET}"
    read op

    [ "$op" = "0" ] && exit 0
    if [[ "$op" =~ ^[1-5]$ ]]; then
        printf "${WHITE}🔗 Paste Media URL: ${RESET}"; read url
        [ -z "$url" ] && continue
        
        echo -e "${YELLOW}⏳ Downloading via Secure Core Pipelines...${RESET}"
        case $op in
            1) $YTDL -f "bestvideo+bestaudio/best" -o "$VIDEO_DIR/%(title).50s.%(ext)s" "$url" ;;
            2) $YTDL -f "bestvideo[height<=720]+bestaudio/best" -o "$VIDEO_DIR/%(title).50s.%(ext)s" "$url" ;;
            3) $YTDL -x --audio-format mp3 -o "$AUDIO_DIR/%(title).50s.%(ext)s" "$url" ;;
            4) curl -L -o "$IMAGE_DIR/IMG_$(date +%s).jpg" "$url" ;;
            5) $YTDL --skip-download --write-thumbnail --convert-thumbnails jpg -o "$IMAGE_DIR/%(title).50s" "$url" ;;
        esac
        echo -e "${GREEN}✔ Task Completed Successfully!${RESET}"; read
    fi
done
