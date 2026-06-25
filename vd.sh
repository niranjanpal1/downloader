#!/data/data/com.termux/files/usr/bin/bash            
# --- UL Color Codes ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# --- UL Configurations ---
FB_URL="https://www.facebook.com/akash.pal.niranjan"
KEY_URL="https://raw.githubusercontent.com/niranjanpal1/downloader/main/key.json"
YTDL="yt-dlp --no-cache-dir --rm-cache-dir"

# Storage Directories
DOWNLOAD_DIR="/sdcard/Download"
VIDEO_DIR="$DOWNLOAD_DIR/UL-Videos"
AUDIO_DIR="$DOWNLOAD_DIR/UL-Audio"
IMAGE_DIR="$DOWNLOAD_DIR/UL-Images"
HISTORY_FILE="$DOWNLOAD_DIR/download_history.txt"

SCRIPT_DIR="$HOME/downloader"
DEVICE_FILE="$HOME/.vd_device_lock"
BAN_FILE="$HOME/.vd_ban"
MAX_ATTEMPTS=3
SCRIPT_VERSION="2.0-UL"

# Auto install UL dependencies
if ! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}📦 [UL-CORE] Installing yt-dlp dependency...${RESET}"
    pip install -U yt-dlp
fi
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}📦 [UL-CORE] Installing jq processing tool...${RESET}"
    pkg install jq -y
fi

# UL Storage setup and structural directory mapping
if [ ! -d "$DOWNLOAD_DIR" ]; then
    echo -e "${YELLOW}🔑 [UL-ACCESS] Requesting Storage Access...${RESET}"
    termux-setup-storage
    sleep 2
fi
mkdir -p "$VIDEO_DIR" "$AUDIO_DIR" "$IMAGE_DIR"

clear
# --- UL Security Functions ---
check_ban() {
    if [ -f "$BAN_FILE" ]; then
        BAN_TIME=$(cat "$BAN_FILE")
        NOW=$(date +%s)
        if [ $NOW -lt $BAN_TIME ]; then
            REMAIN=$(( ($BAN_TIME - $NOW) / 60 ))
            echo -e "${RED}⛔ [UL-BAN] Too many wrong attempts! Access suspended for ${REMAIN} minutes.${RESET}"
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
        if [ $? -eq 0 ] && [ ! -z "$SERVER_DATA" ]; then
            USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".status")
            USER_EXPIRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".expiry")
            TODAY=$(date +%Y-%m-%d)
            
            if [ "$USER_STATUS" = "active" ] && [[ ! "$TODAY" > "$USER_EXPIRY" ]]; then
                return 0
            fi
        fi
    fi
    return 1
}

# --- UL Verification Core ---
attempts=0
check_ban

# Fetch server configurations initially
SERVER_DATA=$(curl -s --fail --max-time 10 "$KEY_URL")
if [ -z "$SERVER_DATA" ]; then
    echo -e "${RED}❌ [UL-ERROR] Server offline or Network drop. Cannot verify license.${RESET}"
    exit 1
fi

ADMIN_NOTICE=$(echo "$SERVER_DATA" | jq -r '.notice')

if ! check_device_lock; then
    while true; do
        clear
        echo -e "${RED}=================================================${RESET}"
        echo -e "${RED}   🔒 ULTIMATE MULTI-USER CLOUD LOCKED - v${SCRIPT_VERSION} ${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo -e "${WHITE} 📢 NOTICE BOARD:${RESET}"
        echo -e "${YELLOW}  $ADMIN_NOTICE ${RESET}"
        echo -e "${RED}-------------------------------------------------${RESET}"
        echo -e "${WHITE} 👤 1. Get your unique license key from Admin.${RESET}"
        echo -e "${WHITE} ⚠️  2. ${MAX_ATTEMPTS} wrong keys = 1 Hour UL System Ban.${RESET}"
        echo -e "${RED}=================================================${RESET}"
        echo
        echo -e "${CYAN}🔗 Admin Facebook Profile: ${FB_URL}${RESET}"
        echo -e "${MAGENTA}-------------------------------------------------${RESET}"
        echo -e "${WHITE}👉 Press ENTER to Open Facebook...${RESET}"
        read

        if command -v termux-open &> /dev/null; then
            termux-open "$FB_URL"
        else
            am start -a android.intent.action.VIEW -d "$FB_URL" &> /dev/null
        fi

        echo
        printf "${WHITE}🔑 Enter Your Unique UL Key: ${RESET}"
        read user_code

        USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".status")
        USER_EXPIRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".expiry")
        TODAY=$(date +%Y-%m-%d)

        if [ "$USER_STATUS" = "null" ]; then
            attempts=$((attempts + 1))
            REMAIN=$((MAX_ATTEMPTS - attempts))
            if [ $attempts -ge $MAX_ATTEMPTS ]; then
                BAN_UNTIL=$(($(date +%s) + 3600))
                echo "$BAN_UNTIL" > "$BAN_FILE"
                echo -e "\n${RED}⛔ [UL-BLOCK] Device banned for 1 hour due to excessive failures!${RESET}"
                exit 1
            fi
            echo -e "\n${RED}❌ Invalid License Key! ${REMAIN} UL validation attempts left.${RESET}"
            read
        elif [ "$USER_STATUS" = "blocked" ]; then
            echo -e "\n${RED}⛔ [UL-REVOKED] This key has been blocked by the admin!${RESET}"
            read
            exit 1
        elif [[ "$TODAY" > "$USER_EXPIRY" ]]; then
            echo -e "\n${RED}⛔ [UL-EXPIRED] Key validity has ended! Expired on: ${USER_EXPIRY}${RESET}"
            read
            exit 1
        elif [ "$USER_STATUS" = "active" ]; then
            echo "$user_code" > "$DEVICE_FILE"
            clear
            echo -e "${GREEN}=================================================${RESET}"
            echo -e "${GREEN}🎉 ACCESS GRANTED - CLOUD LICENSE CONNECTED ✔   ${RESET}"
            echo -e "${GREEN}=================================================${RESET}"
            echo -e "${WHITE}🛡️ License Valid Till: ${USER_EXPIRY}${RESET}"
            echo -e "${CYAN}Press Enter to step into the Engine...${RESET}"
            read
            break
        fi
    done
fi

# --- UL Main Menu Engine ---
while true; do
    clear
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${MAGENTA} 🚀  ULTIMATE DOWNLOADER - UL MULTI-PRO HUB v${SCRIPT_VERSION} ${RESET}"
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${GREEN}🔓 License: Active/Verified | 👤 Admin: Akash Pal${RESET}"
    echo -e "${YELLOW}📢 Notice: $ADMIN_NOTICE${RESET}"
    echo -e "${CYAN}=================================================${RESET}"
    echo

    echo -e " [1] ${GREEN}⭐ Max 1080p Video Quality (Saves to UL-Videos)${RESET}"
    echo -e " [2] ${BLUE}🎬 720p HD Video Download (Saves to UL-Videos)${RESET}"
    echo -e " [3] ${YELLOW}🎧 High Quality MP3 Extraction (Saves to UL-Audio)${RESET}"
    echo -e " [4] ${MAGENTA}🖼️ Direct Image Download (Saves to UL-Images)${RESET}"
    echo -e " [5] ${CYAN}📸 Grab Video Thumbnail (UL Snapshot Engine)${RESET}"
    echo -e " [6] ${WHITE}📜 View UL Download History Logs${RESET}"
    echo -e " [7] ${RED}🗑️ Clear All Saved UL Logs${RESET}"
    echo -e " [8] ${GREEN}🔄 Sync & Pull Latest UL Updates${RESET}"
    echo -e " [9] ${YELLOW}🔐 Emergency Lock/Unlink Device License${RESET}"
    echo -e " [0] ${RED}❌ Exit UL Engine${RESET}"
    echo
    echo -e "${CYAN}-------------------------------------------------${RESET}"
    printf "${WHITE}👉 Select UL Core Option (0-9): ${RESET}"
    read op

    case $op in
        6) 
            clear
            echo -e "${YELLOW}====================================================================${RESET}"
            echo -e "${MAGENTA}                 📜 --- UL DOWNLOAD HISTORY LOG ---                 ${RESET}"
            echo -e "${YELLOW}====================================================================${RESET}"
            printf "${WHITE}%-11s | %-8s | %-15s | %-s\n${RESET}" "  DATE" " TIME" "   TYPE" "URL / LINK"
            echo -e "${CYAN}--------------------------------------------------------------------${RESET}"
            if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
                while read -r raw_line; do
                    clean_line=$(echo "$raw_line" | sed -E 's/\\033\[[0-9;]*m//g; s/URL://g; s/\[|\]//g')
                    IFS='|' read -r datetime type url <<< "$clean_line"
                    datetime=$(echo "$datetime" | xargs)
                    type=$(echo "$type" | xargs)
                    url=$(echo "$url" | xargs)
                    v_date=$(echo "$datetime" | cut -d' ' -f1)
                    v_time=$(echo "$datetime" | cut -d' ' -f2)
                    [ -z "$url" ] && url="$type" && type="UL Download"
                    printf "${WHITE}%-11s${RESET} | ${WHITE}%-8s${RESET} | ${GREEN}%-15s${RESET} | ${CYAN}%-s${RESET}\n" "$v_date" "$v_time" "$type" "$url"
                done < "$HISTORY_FILE"
            else
                echo -e "              ${RED}⚠️ No UL history logs found yet!${RESET}"
            fi
            echo -e "${YELLOW}====================================================================${RESET}"
            echo -e "${WHITE}Press ENTER to return to UL Main Menu...${RESET}"
            read 
            ;;
        7) 
            > "$HISTORY_FILE"
            echo -e "\n${GREEN}🗑️ [UL-CLEAN] History cache database cleared successfully!${RESET}"
            sleep 1 
            ;;
        8) 
            echo -e "\n${YELLOW}🔄 [UL-UPDATE] Syncing scripts with GitHub...${RESET}"
            cd "$SCRIPT_DIR" 2>/dev/null || cd "$HOME/downloader"
            git reset --hard
            git pull
            echo -e "${GREEN}✔ Update synced. Rebooting UL Engine!${RESET}"
            sleep 1
            exec bash "$0" 
            ;;
        9) 
            rm -f "$DEVICE_FILE"
            echo -e "\n${RED}🔐 [UL-SECURITY] Device unlinked! Access key verification re-enabled.${RESET}"
            sleep 1
            exit 0 
            ;;
        0) 
            echo -e "\n${RED}Goodbye 👋 Thank you for using UL Premium Downloader Hub!${RESET}\n"
            exit 0 
            ;;
        [1-5])
            echo
            if [ "$op" = "4" ]; then
                printf "${WHITE}🔗 Paste UL Image Direct URL (JPG/PNG): ${RESET}"
            else
                printf "${WHITE}🔗 Paste UL Supported Media URL: ${RESET}"
            fi
            read url
            
            if [ -z "$url" ] || [[ ! "$url" =~ ^https?:// ]]; then
                echo -e "\n${RED}❌ Invalid URL Format! Links must start with http:// or https://${RESET}"
                read; continue
            fi
            
            PLAYLIST_ARG="--no-playlist"
            if [[ "$op" =~ ^[1-3]$ ]]; then
                printf "${YELLOW}❓ Process link as Playlist? (y/n): ${RESET}"
                read is_playlist
                if [ "$is_playlist" = "y" ] || [ "$is_playlist" = "Y" ]; then
                    PLAYLIST_ARG="--yes-playlist"
                    echo -e "${GREEN}▶ UL Playlist Pipeline Enabled!${RESET}"
                fi
            fi

            echo -e "\n${YELLOW}⏳ Processing request through UL Downloader Pipelines...${RESET}\n"
            
            case $op in
                1) 
                    OUT="$VIDEO_DIR/%(title).50s.%(ext)s"
                    $YTDL $PLAYLIST_ARG -f "bestvideo+bestaudio/best" -o "$OUT" "$url"
                    type_str="UL-1080p Video" 
                    ;;
                2) 
                    OUT="$VIDEO_DIR/%(title).50s.%(ext)s"
                    $YTDL $PLAYLIST_ARG -f "bestvideo[height<=720]+bestaudio/best" -o "$OUT" "$url"
                    type_str="UL-720p Video" 
                    ;;
                3) 
                    OUT="$AUDIO_DIR/%(title).50s.%(ext)s"
                    $YTDL $PLAYLIST_ARG -x --audio-format mp3 -o "$OUT" "$url"
                    type_str="UL-MP3 Audio" 
                    ;;
                4) 
                    FILE_NAME="UL_IMG_$(date +%s).jpg"
                    curl -L -s --fail -o "$IMAGE_DIR/$FILE_NAME" "$url"
                    type_str="UL-Image" 
                    ;;
                5) 
                    OUT="$IMAGE_DIR/%(title).50s"
                    $YTDL --skip-download --write-thumbnail --convert-thumbnails jpg -o "$OUT" "$url"
                    type_str="UL-Thumbnail" 
                    ;;
            esac
            
            if [ $? -eq 0 ]; then
                echo -e "\n${GREEN}✔ UL Core Pipeline Executed Successfully! 🎉${RESET}"
                echo "$(date '+%Y-%m-%d %H:%M:%S') | $type_str | $url" >> "$HISTORY_FILE"
            else
                echo -e "\n${RED}❌ UL Pipeline Fault! Connection timed out or link restricted.${RESET}"
            fi
            read
            ;;
        *) 
            echo -e "\n${RED}❌ Invalid Choice! Choose options between 0 and 9.${RESET}"
            sleep 1 
            ;;
    esac
done
