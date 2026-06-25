#!/data/data/com.termux/files/usr/bin/bash
# =================================================================
# 🛡️ UL-PRO MAXIMUM FORTIFIED SYSTEM | GITHUB LIVE CLUSTER v10.2
# =================================================================

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; MAGENTA='\033[1;35m'; CYAN='\033[1;36m'; WHITE='\033[1;37m'; RESET='\033[0m'
BOLD='\033[1m'; DIM='\033[2m'

# 🟢 LIVE REPOSITORY RE-LINKED CONFIGURATION
GITHUB_USER="niranjanpal1"
GITHUB_REPO="downloader"
RAW_JSON_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/key.json"

FB_URL="https://www.facebook.com/akash.pal.niranjan"
YTDL="yt-dlp --no-cache-dir --rm-cache-dir --concurrent-fragments 5"

DOWNLOAD_DIR="/sdcard/Download"
VIDEO_DIR="$DOWNLOAD_DIR/UL-Videos"; AUDIO_DIR="$DOWNLOAD_DIR/UL-Audio"; IMAGE_DIR="$DOWNLOAD_DIR/UL-Images"

SESSION_TOKEN="$HOME/.vd_session"
BAN_FILE="$HOME/.vd_ban_sys"
MAX_ATTEMPTS=3
SCRIPT_VERSION="10.2-GIT-LIVE"

# --- Core History & Session Wipe Function ---
clean_terminal_traces() {
    rm -f "$SESSION_TOKEN"
    history -c
    history -w
    cat /dev/null > ~/.bash_history
}
trap 'clean_terminal_traces; clear; exit' SIGINT SIGTERM

check_runtime_integrity() {
    if [[ $(ps -ef | grep -E "strace|gdb|ltrace" | grep -v grep) ]]; then
        echo -e "${RED}⚠️ SECURITY FAULT: REVERSE ENGINEERING DETECTED!${RESET}"; exit 1
    fi
}

# --- Secure Hardware Signature Generator ---
get_secure_hw_sig() {
    echo -n "$(uname -m)$(getprop ro.serialno)$(getprop ro.product.model)$(uname -r)" | md5sum | cut -c1-16 | tr 'a-z' 'A-Z'
}
CURRENT_HW_ID=$(get_secure_hw_sig)

calculate_days_left() {
    local expiry_date=$1
    if [ -z "$expiry_date" ] || [ "$expiry_date" = "null" ]; then echo "0"; return; fi
    local diff=$(( $(date -d "$expiry_date" +%s 2>/dev/null) - $(date +%s) ))
    local days=$((diff / 86400))
    if [ $days -lt 0 ]; then echo "0"; else echo "$days"; fi
}

redirect_fb() {
    termux-open-url "$FB_URL" 2>/dev/null || am start -a android.intent.action.VIEW -d "$FB_URL" &>/dev/null
}

if [ -f "$BAN_FILE" ] && [ $(date +%s) -lt $(cat "$BAN_FILE") ]; then
    clear
    echo -e "${RED}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}${BOLD}║  ⛔ SYSTEM ACCESS SUSPENDED DUE TO TAMPERING       ║${RESET}"
    echo -e "${RED}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
    echo -e "${CYAN} Get your verification key from Bio: ${FB_URL}${RESET}"
    clean_terminal_traces
    exit 1
fi

check_device_lock() {
    check_runtime_integrity
    if [ -f "$SESSION_TOKEN" ]; then
        SAVED_KEY=$(cat "$SESSION_TOKEN")
        SERVER_DATA=$(curl -s --fail --max-time 10 "$RAW_JSON_URL")
        if [ $? -eq 0 ] && [ "$SERVER_DATA" != "null" ] && [ ! -z "$SERVER_DATA" ]; then
            USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".status" 2>/dev/null)
            USER_EXPIRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".expiry" 2>/dev/null)
            ALLOWED_HW_ID=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".device_id" 2>/dev/null)

            if [ "$USER_STATUS" = "active" ] && [ "$ALLOWED_HW_ID" = "$CURRENT_HW_ID" ] && [[ ! "$(date +%Y-%m-%d)" > "$USER_EXPIRY" ]]; then
                GLOBAL_DAYS_LEFT=$(calculate_days_left "$USER_EXPIRY")
                return 0
            fi
        fi
    fi
    return 1
}

print_header() {
    clear
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║  🚀 ULTIMATE PREMIUM DOWNLOADER - PRO ELITE   ║${RESET}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════╝${RESET}"
}

# --- GitHub Live Gateway Loop ---
if ! check_device_lock; then
    attempts=0
    SERVER_DATA=$(curl -s --fail --max-time 10 "$RAW_JSON_URL")
    ADMIN_NOTICE=$(echo "$SERVER_DATA" | jq -r '.notice' 2>/dev/null)
    if [ "$ADMIN_NOTICE" = "null" ] || [ -z "$ADMIN_NOTICE" ]; then
        ADMIN_NOTICE="Follow owner Facebook profile to get authorization keys."
    fi

    while true; do
        clear
        echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}${BOLD}║  🚀 UL-PRO ELITE | GITHUB LIVE REVALIDATION   ║${RESET}"
        echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════╝${RESET}"
        echo -e "${WHITE} 📲 DEVICE ID : ${CYAN}$CURRENT_HW_ID${RESET}"
        echo -e "${YELLOW} 📢 NOTICE    : $ADMIN_NOTICE${RESET}"
        echo -e "${MAGENTA} 💎 KEY GUIDE : Check Key inside my FB Bio!${RESET}"
        echo -e "${CYAN} 🔗 PROFILE   : ${FB_URL}${RESET}"
        echo -e "${DIM} ───────────────────────────────────────────────${RESET}"

        if [ $attempts -gt 0 ]; then
            echo -e "${RED}${BOLD} ❌ ACCESS DENIED: INVALID KEY [Attempts: $attempts/$MAX_ATTEMPTS]${RESET}"
            echo -e "${YELLOW} 👉 Type 'help' and enter to contact Admin!${RESET}"
            echo -e "${DIM} ───────────────────────────────────────────────${RESET}"
        fi

        printf "${WHITE}${BOLD} 🔑 Key (or 'help' for support): ${RESET}"
        read user_code

        # --- Help Logic ---
        if [[ "$user_code" == "help" ]]; then
            echo -e "${GREEN} 🔗 Opening Admin Profile...${RESET}"
            redirect_fb
            continue
        fi

        SERVER_DATA=$(curl -s --fail --max-time 10 "$RAW_JSON_URL")
        USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".status" 2>/dev/null)

        if [ "$USER_STATUS" = "null" ] || [ -z "$user_code" ] || [ -z "$SERVER_DATA" ]; then
            attempts=$((attempts + 1))
            if [ $attempts -ge $MAX_ATTEMPTS ]; then
                echo $(($(date +%s) + 3600)) > "$BAN_FILE"
                clean_terminal_traces
                exit 1
            fi
        else
            USER_EXPIRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".expiry" 2>/dev/null)
            ALLOWED_HW_ID=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".device_id" 2>/dev/null)
            USER_REASON=$(echo "$SERVER_DATA" | jq -r ".users.\"$user_code\".reason" 2>/dev/null)

            if [ "$USER_STATUS" = "blocked" ]; then
                echo -e "${RED}⛔ ACCESS TERMINATED! Reason: $USER_REASON${RESET}"; read; clean_terminal_traces; exit 1
            elif [[ "$(date +%Y-%m-%d)" > "$USER_EXPIRY" ]]; then
                echo -e "${RED}⛔ SYSTEM KEY EXPIRED! Update credentials.${RESET}"; read; clean_terminal_traces; exit 1
            elif [ "$USER_STATUS" = "active" ]; then

                if [ "$ALLOWED_HW_ID" = "null" ]; then
                    echo -e "${YELLOW}⚠️ Key Verification Success! Send this ID to Admin to Lock.${RESET}"
                    echo -e "${CYAN}🔑 YOUR DEVICE ID: $CURRENT_HW_ID${RESET}"
                    echo -e "${YELLOW}👉 Press ENTER to copy ID and open FB to contact Admin...${RESET}"
                    echo -n "$CURRENT_HW_ID" | termux-clipboard-set 2>/dev/null
                    read; redirect_fb; clean_terminal_traces; exit 1
                elif [ "$ALLOWED_HW_ID" != "$CURRENT_HW_ID" ]; then
                    echo -e "${RED}⛔ HARDWARE MISMATCH! This key is registered to another device.${RESET}"
                    echo -e "${YELLOW}👉 Press ENTER to close...${RESET}"
                    read; redirect_fb; clean_terminal_traces; exit 1
                fi

                echo "$user_code" > "$SESSION_TOKEN"
                GLOBAL_DAYS_LEFT=$(calculate_days_left "$USER_EXPIRY")
                break
            fi
        fi
    done
fi

# --- Main Core Execution Dashboard ---
while true; do
    print_header
    echo -e "${GREEN}${BOLD} 🔓 STATUS: VERIFIED   |  ⏳ VALIDITY: $GLOBAL_DAYS_LEFT DAYS ${RESET}"
    echo -e "${DIM} ───────────────────────────────────────────────${RESET}"
    echo -e "  ${WHITE}[1]${CYAN} 💎 MAX 1080P PRO      ${WHITE}[4]${CYAN} 🖼️  IMAGE GRABBER"
    echo -e "  ${WHITE}[2]${CYAN} 🎬 720P HD STREAM     ${WHITE}[5]${CYAN} 📸 THUMB EXTRACT"
    echo -e "  ${WHITE}[3]${CYAN} 🎧 HI-RES MP3         ${WHITE}[0]${RED} ❌ SHUTDOWN APP${RESET}"
    echo -e "${DIM} ───────────────────────────────────────────────${RESET}"
    printf "${BOLD} 👉 SELECT OPERATION (0-5) : ${RESET}"
    read op

    if [ "$op" = "0" ]; then
        clean_terminal_traces
        clear
        echo -e "${GREEN}🔒 Session closed safely. History wiped!${RESET}"
        exit 0
    fi

    if [[ "$op" =~ ^[1-5]$ ]]; then
        printf " ${WHITE}🔗 PASTE TARGET URL : ${RESET}"; read url
        [ -z "$url" ] && continue

        echo -e "\n ${YELLOW}⚡ RUNNING SECURE PIPELINE...${RESET}"
        case $op in
            1) $YTDL -f "bestvideo+bestaudio/best" -o "$VIDEO_DIR/%(title).50s.%(ext)s" "$url" ;;
            2) $YTDL -f "bestvideo[height<=720]+bestaudio/best" -o "$VIDEO_DIR/%(title).50s.%(ext)s" "$url" ;;
            3) $YTDL -x --audio-format mp3 -o "$AUDIO_DIR/%(title).50s.%(ext)s" "$url" ;;
            4) curl -L -o "$IMAGE_DIR/UL_IMG_$(date +%s).jpg" "$url" ;;
            5) $YTDL --skip-download --write-thumbnail --convert-thumbnails jpg -o "$IMAGE_DIR/%(title).50s" "$url" ;;
        esac
        echo -e "\n ${GREEN}${BOLD}✔ OPERATION COMPLETED SUCCESSFULLY!${RESET}"; read
    fi
done
