#!/data/data/com.termux/files/usr/bin/bash
# =================================================================
# 👑 UL DOWNLOADING SYSTEM - ADMIN CONTROL PANEL v1.6 (FULL PRO)
# =================================================================

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; MAGENTA='\033[1;35m'; CYAN='\033[1;36m'; WHITE='\033[1;37m'; RESET='\033[0m'
BOLD='\033[1m'; DIM='\033[2m'

JSON_FILE="key.json"

# --- Initialization & Safety Core ---
if [ ! -f "$JSON_FILE" ]; then
    echo -e "${YELLOW}⚠️ Notice: $JSON_FILE missing. Creating default layout...${RESET}"
    echo '{"notice":"Welcome to UL Downloader System","users":{}}' > "$JSON_FILE"
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}📦 Installing package 'jq' for core operations...${RESET}"
    pkg install jq -y
fi

# --- Core Helper Functions ---
print_line() {
    echo -e "${CYAN}=================================================================${RESET}"
}

calculate_future_date() {
    local days=$1
    if [[ "$OSTYPE" == "linux-android"* ]]; then
        date -d "+$days days" +%Y-%m-%d 2>/dev/null
    else
        date -v+"$days"d +%Y-%m-%d 2>/dev/null
    fi
}

# --- UI Layout Menu ---
show_menu() {
    clear
    print_line
    echo -e "   👑 ${GREEN}${BOLD}UL DOWNLOADING SYSTEM - COMPLEX ADMIN CONTROL PANEL${RESET} 👑 "
    print_line
    
    # Live mini-counter on the main menu dashboard
    TOTAL_KEYS=$(jq '.users | length' "$JSON_FILE" 2>/dev/null || echo "0")
    echo -e " 📊 Database Live Status: [ ${GREEN}${BOLD}Total Loaded Keys: $TOTAL_KEYS${RESET} ]"
    print_line
    
    echo -e " ${WHITE}[1] ➕  Add / Register New User Key (Auto Expiry)${RESET}"
    echo -e " ${WHITE}[2] 🚫  Block / Unblock Existing User Key${RESET}"
    echo -e " ${WHITE}[3] 🔄  Change/Update System Notice Board${RESET}"
    echo -e " ${WHITE}[4] 🚀  Push Configuration Live to GitHub${RESET}"
    echo -e " ${WHITE}[5] 📋  List All Registered Keys & Live Status Count${RESET}"
    echo -e " ${WHITE}[0] ❌  Exit Control Panel${RESET}"
    print_line
}

# --- Main Logic Loop ---
while true; do
    show_menu
    printf "${YELLOW}${BOLD}👉 Choice Option (0-5): ${RESET}"
    read choice

    case $choice in
        1)
            print_line
            printf "${WHITE}🔑 Enter New User Key (e.g., USER-SAYAN-UL7): ${RESET}"
            read new_key
            [ -z "$new_key" ] && continue
            
            # Key Duplication Audit
            existing_check=$(jq --arg k "$new_key" '.users[$k]' "$JSON_FILE")
            if [ "$existing_check" != "null" ]; then
                echo -e "${YELLOW}⚠️ Warning: Key already exists! Database will overwrite this entry.${RESET}"
                echo -e "Current Status: $(echo "$existing_check" | jq -r '.status') | Expiry: $(echo "$existing_check" | jq -r '.expiry')"
                print_line
            fi
            
            # --- Automatic Expiry Selection Matrix ---
            echo -e "${MAGENTA}${BOLD}📅 Select Expiry Period Matrix:${RESET}"
            echo -e "  [1] 1 Month  (30 Days Auto)"
            echo -e "  [2] 3 Months (90 Days Auto)"
            echo -e "  [3] 6 Months (180 Days Auto)"
            echo -e "  [4] 1 Year   (365 Days Auto)"
            echo -e "  [5] Fixed Till End of Year ($(date +%Y)-12-31)"
            echo -e "  [6] Custom Dynamic Days (Manual Entry)"
            print_line
            printf "${YELLOW}👉 Select Option (Default is 1): ${RESET}"
            read exp_opt
            
            case $exp_opt in
                2) expiry_date=$(calculate_future_date 90) ;;
                3) expiry_date=$(calculate_future_date 180) ;;
                4) expiry_date=$(calculate_future_date 365) ;;
                5) expiry_date="$(date +%Y)-12-31" ;;
                6) 
                    printf "${WHITE}🔢 Enter number of active days: ${RESET}"
                    read custom_days
                    if [[ "$custom_days" =~ ^[0-9]+$ ]]; then
                        expiry_date=$(calculate_future_date "$custom_days")
                    else
                        echo -e "${RED}Invalid number. Defaulting to 30 days.${RESET}"
                        expiry_date=$(calculate_future_date 30)
                    fi
                    ;;
                *) expiry_date=$(calculate_future_date 30) ;;
            esac
            
            echo -e "${GREEN}⏳ System Lock Expiry Date Set To: ${BOLD}$expiry_date${RESET}"
            
            # Injecting into localized key array node
            jq --arg k "$new_key" --arg exp "$expiry_date" '.users[$k] = {"status": "active", "expiry": $exp, "device_id": "null", "reason": ""}' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"
            echo -e "\n${GREEN}${BOLD}✔ SUCCESS: Key successfully deployed with dynamic auto-expiry!${RESET}"
            read -p "Press Enter to continue..."
            ;;
            
        2)
            print_line
            printf "${WHITE}🔑 Enter Target User Key: ${RESET}"
            read target_key
            [ -z "$target_key" ] && continue
            
            user_node=$(jq --arg k "$target_key" '.users[$k]' "$JSON_FILE")
            if [ "$user_node" = "null" ]; then
                echo -e "${RED}❌ Error: Key not found inside the active schema!${RESET}"
                read -p "Press Enter to continue..."
                continue
            fi
            
            current_status=$(echo "$user_node" | jq -r '.status')
            echo -e "${CYAN}Current Key Status is: ${BOLD}${current_status}${RESET}"
            echo -e " [1] 🚫 Block Key\n [2] 🟢 Unblock (Activate) Key"
            printf "${YELLOW}👉 Operation choice: ${RESET}"
            read action_choice
            
            if [ "$action_choice" = "1" ]; then
                printf "${WHITE}💬 Enter Block Reason: ${RESET}"
                read reason
                [ -z "$reason" ] && reason="Terms Violated by User."
                jq --arg k "$target_key" --arg r "$reason" '.users[$k].status = "blocked" | .users[$k].reason = $r' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"
                echo -e "\n${RED}${BOLD}✔ Key successfully blacklisted.${RESET}"
            elif [ "$action_choice" = "2" ]; then
                jq --arg k "$target_key" '.users[$k].status = "active" | .users[$k].reason = ""' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"
                echo -e "\n${GREEN}${BOLD}✔ Key successfully unblocked/activated.${RESET}"
            else
                echo -e "${RED}Operation cancelled.${RESET}"
            fi
            read -p "Press Enter to continue..."
            ;;
            
        3)
            print_line
            current_notice=$(jq -r '.notice' "$JSON_FILE")
            echo -e "${WHITE}Current Notice: ${YELLOW}$current_notice${RESET}"
            print_line
            printf "${WHITE}📢 Enter New Notice text: ${RESET}"
            read new_notice
            [ -z "$new_notice" ] && continue
            
            jq --arg n "$new_notice" '.notice = $n' "$JSON_FILE" > tmp.json && mv tmp.json "$JSON_FILE"
            echo -e "\n${GREEN}${BOLD}✔ Global Notice board structure updated!${RESET}"
            read -p "Press Enter to continue..."
            ;;
            
        4)
            print_line
            echo -e "${YELLOW}🚀 Initializing Cloud Sync Protocol...${RESET}"
            if ! git rev-parse --is-inside-work-tree &>/dev/null; then
                echo -e "${RED}❌ Git Repository Not Initialized Here! Run git init first.${RESET}"
                read -p "Press Enter to continue..."
                continue
            fi
            
            git add "$JSON_FILE"
            git commit -m "Live database modification backup: $(date +'%Y-%m-%d %H:%M:%S')"
            echo -e "${YELLOW}🛰️ Pushing blocks to branch 'main'...${RESET}"
            git push origin main
            
            if [ $? -eq 0 ]; then
                echo -e "\n${GREEN}${BOLD}✔ PRODUCTION DATA LIVE ON GITHUB SERVER CLUSTER!${RESET}"
            else
                echo -e "\n${RED}❌ GIT PUSH FAILED! Check internet, credentials, or remote setup.${RESET}"
            fi
            read -p "Press Enter to continue..."
            ;;
            
        5)
            print_line
            echo -e "               📋 ${MAGENTA}${BOLD}REGISTERED KEYS OVERVIEW${RESET}               "
            print_line
            
            # --- Live Counter Engine ---
            TOTAL_USERS=$(jq '.users | length' "$JSON_FILE")
            ACTIVE_USERS=$(jq '[.users[] | select(.status == "active")] | length' "$JSON_FILE")
            BLOCKED_USERS=$(jq '[.users[] | select(.status == "blocked")] | length' "$JSON_FILE")
            
            echo -e " 📊 Total Users: ${WHITE}${BOLD}$TOTAL_USERS${RESET} | 🟢 Active: ${GREEN}$ACTIVE_USERS${RESET} | 🔴 Blocked: ${RED}$BLOCKED_USERS${RESET}"
            print_line
            printf "${WHITE}%-22s %-10s %-12s %s${RESET}\n" "KEY NAME" "STATUS" "EXPIRY" "DEVICE LOCK"
            print_line
            
            # Parsing array keys using custom jq formatter loops
            jq -r '.users | to_entries[] | "\(.key) \(.value.status) \(.value.expiry) \(.value.device_id)"' "$JSON_FILE" | while read -r kname kstat kexp kdev; do
                if [ "$kstat" = "active" ]; then
                    printf "${GREEN}%-22s %-10s${RESET} %-12s %s\n" "$kname" "$kstat" "$kexp" "$kdev"
                else
                    printf "${RED}%-22s %-10s${RESET} %-12s %s\n" "$kname" "$kstat" "$kexp" "$kdev"
                fi
            done
            print_line
            read -p "Press Enter to return to menu..."
            ;;
            
        0)
            print_line
            echo -e "${RED}🔒 System Panel De-authenticated safely. Goodbye!${RESET}"
            exit 0
            ;;
            
        *)
            echo -e "\n${RED}❌ Unknown Option! Use 0 to 5 numbers only.${RESET}"
            sleep 1.2
            ;;
    esac
done
