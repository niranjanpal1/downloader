#!/data/data/com.termux/files/usr/bin/bash

# Colors for UI
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; WHITE='\033[1;37m'; RESET='\033[0m'
BOLD='\033[1m'

JSON_FILE="key.json"

# Header UI
clear
echo -e "${CYAN}=======================================================${RESET}"
echo -e "   👑 ${WHITE}${BOLD}UL-PRO ELITE | REGISTRATION GATEWAY${RESET} 👑"
echo -e "${CYAN}=======================================================${RESET}"

# HW ID Generator
get_hw_id() {
    echo -n "$(uname -m)$(getprop ro.serialno)$(getprop ro.product.model)" | md5sum | cut -c1-16 | tr 'a-z' 'A-Z'
}

# Input
printf "${YELLOW}👉 Enter your Key Name: ${RESET}"
read user_key

if [ -z "$user_key" ]; then
    echo -e "\n${RED}❌ Error: Name cannot be empty!${RESET}"
    exit 1
fi

# Check Existence
if [[ $(jq ".users.\"$user_key\"" "$JSON_FILE" 2>/dev/null) != "null" ]]; then
    echo -e "\n${RED}❌ Access Denied: Key already exists!${RESET}"
    exit 1
fi

# Registration Process
echo -e "${WHITE}⏳ Validating Device...${RESET}"
DEV_ID=$(get_hw_id)

jq --arg k "$user_key" --arg dev "$DEV_ID" \
'.users[$k] = {"status": "active", "expiry": "2026-12-31", "device_id": $dev, "reason": "Self-Reg"}' \
"$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"

# Footer UI
echo -e "\n${GREEN}${BOLD}✔ REGISTRATION SUCCESSFUL!${RESET}"
echo -e "${WHITE}-------------------------------------------------------${RESET}"
echo -e "🔑 KEY   : ${CYAN}$user_key${RESET}"
echo -e "📱 HW-ID : ${CYAN}$DEV_ID${RESET}"
echo -e "📅 STATUS: ${GREEN}ACTIVE${RESET}"
echo -e "${WHITE}-------------------------------------------------------${RESET}"
echo -e "${YELLOW}Note: Your device is now locked to this key.${RESET}"
