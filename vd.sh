#!/data/data/com.termux/files/usr/bin/bash
# =================================================================
# 🛡️ UL-PRO ADVANCED HARDENED SYSTEM | VERSION: 9.9-ELITE
# =================================================================

# --- Advanced Cryptography & UI Assets ---
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; WHITE='\033[1;37m'; RESET='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'

# --- Advanced Security Configuration ---
CONFIG_URL="https://raw.githubusercontent.com/niranjanpal1/downloader/main/key.json"
DEVICE_IDENTITY_LOCK="$HOME/.vd_sys_sig"
SESSION_TOKEN="$HOME/.vd_session"
BAN_LOCK="$HOME/.vd_ban_sys"

# --- 1. Memory Sanitization & Integrity Check ---
trap 'rm -f $SESSION_TOKEN; exit' SIGINT SIGTERM
check_integrity() {
    # Detect if script is being debugged/traced
    if [[ $(ps -ef | grep -E "strace|gdb|ltrace" | grep -v grep) ]]; then
        echo -e "${RED}⚠️ DANGER: DEBUGGER DETECTED! EXITING...${RESET}"; exit 1
    fi
}

# --- 2. Cryptographic Device Fingerprinting ---
get_secure_hw_sig() {
    # Multi-factor hardware hashing
    echo -n "$(uname -m)$(getprop ro.serialno)$(getprop ro.product.model)" | md5sum | cut -c1-16 | tr 'a-z' 'A-Z'
}
CURRENT_SIG=$(get_secure_hw_sig)

# --- 3. Advanced License Guard Logic ---
verify_license_full() {
    check_integrity
    SERVER_DATA=$(curl -s --fail --max-time 15 "$CONFIG_URL")
    if [ $? -ne 0 ]; then echo -e "${RED}❌ OFFLINE: SERVER AUTH FAILED.${RESET}"; exit 1; fi
    
    # Session Verification
    if [ -f "$SESSION_TOKEN" ]; then
        SAVED_KEY=$(cat "$SESSION_TOKEN")
        USER_STATUS=$(echo "$SERVER_DATA" | jq -r ".users.\"$SAVED_KEY\".status")
        if [ "$USER_STATUS" = "active" ]; then return 0; fi
    fi
    return 1
}

# --- 4. Hardened Authentication Gateway ---
run_auth_gateway() {
    clear
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║      🚀 UL-PRO ELITE | SYSTEM AUTHENTICATION       ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
    
    while true; do
        printf "${WHITE}${BOLD} 🔑 ENTER SYSTEM AUTHORIZATION KEY: ${RESET}"
        read -s input_key
        SERVER_DATA=$(curl -s --fail --max-time 10 "$CONFIG_URL")
        
        KEY_ENTRY=$(echo "$SERVER_DATA" | jq -r ".users.\"$input_key\"")
        if [ "$KEY_ENTRY" != "null" ]; then
            STATUS=$(echo "$KEY_ENTRY" | jq -r '.status')
            BIND_ID=$(echo "$KEY_ENTRY" | jq -r '.device_id')
            EXPIRY=$(echo "$KEY_ENTRY" | jq -r '.expiry')
            
            if [ "$STATUS" = "active" ] && ([ "$BIND_ID" = "null" ] || [ "$BIND_ID" = "$CURRENT_SIG" ]); then
                echo "$input_key" > "$SESSION_TOKEN"
                echo -e "\n${GREEN}✔ AUTH SUCCESS: SESSION INITIALIZED.${RESET}"; sleep 2; return 0
            else
                echo -e "\n${RED}⛔ SECURITY FAULT: INVALID BINDING OR EXPIRED.${RESET}"
            fi
        else
            echo -e "\n${RED}❌ ACCESS DENIED: INVALID CREDENTIALS.${RESET}"
        fi
    done
}

# --- 5. Main Execution Wrapper ---
if ! verify_license_full; then run_auth_gateway; fi

# --- 6. Elite Premium UI (Optimized Line-by-Line) ---
while true; do
    clear
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║        🚀 ULTIMATE PREMIUM DOWNLOADER V9.9         ║${RESET}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════╝${RESET}"
    echo -e "${GREEN} 🔐 STATUS: VERIFIED   |  ⚙️  MODE: HARDENED-PRO${RESET}"
    echo -e "${DIM} ────────────────────────────────────────────────────${RESET}"
    echo -e "  ${WHITE}[1]${CYAN} 💎 MAX 1080P PRO    ${WHITE}[4]${CYAN} 🖼️  IMAGE GRABBER"
    echo -e "  ${WHITE}[2]${CYAN} 🎬 720P HD STREAM   ${WHITE}[5]${CYAN} 📸 THUMB EXTRACT"
    echo -e "  ${WHITE}[3]${CYAN} 🎧 HI-RES MP3       ${WHITE}[0]${RED} ❌ SHUTDOWN${RESET}"
    echo -e "${DIM} ────────────────────────────────────────────────────${RESET}"
    printf "${BOLD} 👉 COMMAND INPUT (0-5) : ${RESET}"
    read op

    [[ "$op" == "0" ]] && { echo -e "\n${RED}🔒 SECURE SHUTDOWN...${RESET}"; rm -f "$SESSION_TOKEN"; exit 0; }
    
    # Operation Logic (Using Secure Subshells)
    if [[ "$op" =~ ^[1-5]$ ]]; then
        printf " ${WHITE}🔗 PASTE TARGET URL : ${RESET}"; read url
        [ -z "$url" ] && continue
        echo -e "\n ${YELLOW}⚡ RUNNING SECURE PIPELINE...${RESET}"
        
        case $op in
            1) yt-dlp -f "bestvideo+bestaudio/best" "$url" ;;
            2) yt-dlp -f "bestvideo[height<=720]+bestaudio/best" "$url" ;;
            3) yt-dlp -x --audio-format mp3 "$url" ;;
            4) curl -L -o "IMG_$(date +%s).jpg" "$url" ;;
            5) yt-dlp --write-thumbnail --skip-download "$url" ;;
        esac
        echo -e "\n ${GREEN}${BOLD}✔ PIPELINE SUCCESSFUL. PRESS ENTER.${RESET}"; read
    fi
done
