#!/data/data/com.termux/files/usr/bin/bash
# --- Admin UI Colors ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ==========================================
# 🔒 ADMIN SECURITY CONFIGURATIONS
# ==========================================
ADMIN_PASSWORD="AKASH_SECRET_PASS" # <--- Ekhane apnar icchemoto secure password din
ALLOWED_ADMIN_DEV="UL-4F2CC979-HW" # <--- Apnar nijer personal Device ID
# ==========================================

# 1. Device Verification Layer
get_device_id() {
    echo "UL-$(uname -m | md5sum | cut -c1-8 | tr 'a-z' 'A-Z')-HW"
}
CURRENT_HW_ID=$(get_device_id)

if [ "$CURRENT_HW_ID" != "$ALLOWED_ADMIN_DEV" ]; then
    echo -e "${RED}⛔ ACCESS DENIED! Your device is not registered as Admin.${RESET}"
    exit 1
fi

# 2. Password Verification Layer
clear
echo -e "${YELLOW}=================================================${RESET}"
echo -e "${YELLOW}       🔒 UL ADMIN ENGINE - SECURITY GATEWAY     ${RESET}"
echo -e "${YELLOW}=================================================${RESET}"
printf "${WHITE}🔑 Enter Admin Secure Password: ${RESET}"
read -s pass_input
echo ""

if [ "$pass_input" != "$ADMIN_PASSWORD" ]; then
    echo -e "${RED}❌ Invalid Admin Password! Security alert triggered.${RESET}"
    exit 1
fi

# --- Core Setup ---
JSON_FILE="key.json"
if [ ! -f "$JSON_FILE" ]; then
    echo -e "${RED}❌ key.json file khunje paowa jayni! GitHub repository folder-e thake eiti run korun.${RESET}"
    exit 1
fi

while true; do
    clear
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${GREEN}    👑 UL DOWNLOADING SYSTEM - ADMIN CONTROL PANEL 👑   ${RESET}"
    echo -e "${CYAN}=================================================${RESET}"
    echo -e " [1] ➕ Add / Register New User Key"
    echo -e " [2] 🛑 Block an Existing User Key"
    echo -e " [3] 🔄 Change/Update System Notice Board"
    echo -e " [4] 📤 Push Configuration Changes to GitHub"
    echo -e " [0] ❌ Exit Control Panel"
    echo -e "${CYAN}=================================================${RESET}"
    printf "${WHITE}👉 Choice Option: ${RESET}"
    read opt

    case $opt in
        1)
            printf "${WHITE}🔑 Enter New User Key (e.g., USER-SAYAN-UL7): ${RESET}"
            read ukey
            printf "${WHITE}📅 Enter Expiry Date (YYYY-MM-DD): ${RESET}"
            read uexp
            printf "${WHITE}📲 Enter User Device ID (If unknown, type null): ${RESET}"
            read uhw
            
            tmp=$(mktemp)
            jq --arg k "$ukey" --arg exp "$uexp" --arg hw "$uhw" '.users[$k] = {"status": "active", "expiry": $exp, "device_id": $hw, "reason": ""}' "$JSON_FILE" > "$tmp" && mv "$tmp" "$JSON_FILE"
            echo -e "${GREEN}✔ User $ukey added successfully locally!${RESET}"
            sleep 2
            ;;
        2)
            printf "${WHITE}🔑 Enter User Key to Block: ${RESET}"
            read bkey
            printf "${WHITE}💬 Enter Block Reason: ${RESET}"
            read breason
            
            tmp=$(mktemp)
            jq --arg k "$bkey" --arg r "$breason" '.users[$k].status = "blocked" | .users[$k].reason = $r' "$JSON_FILE" > "$tmp" && mv "$tmp" "$JSON_FILE"
            echo -e "${RED}⛔ User $bkey has been blocked locally!${RESET}"
            sleep 2
            ;;
        3)
            printf "${WHITE}📢 Enter New Notice Board Text: ${RESET}"
            read ntxt
            tmp=$(mktemp)
            jq --arg n "$ntxt" '.notice = $n' "$JSON_FILE" > "$tmp" && mv "$tmp" "$JSON_FILE"
            echo -e "${GREEN}✔ Notice updated locally!${RESET}"
            sleep 2
            ;;
        4)
            echo -e "${YELLOW}📤 Syncing and pushing database to GitHub...${RESET}"
            git add key.json
            git commit -m "Database dynamically modified via Secure Admin Console"
            git push origin main
            echo -e "${GREEN}✔ Changes successfully deployed to Cloud!${RESET}"
            sleep 2
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option!${RESET}"; sleep 1 ;;
    esac
done
