#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader UI
# ===================================

print_header() {
    clear

    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║         UL DOWNLOADER PRO v11               ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"

    echo -e "${GREEN}Status : VERIFIED${RESET}"
    echo -e "${YELLOW}Version: ${SCRIPT_VERSION}${RESET}"
    echo
}

show_menu() {

    echo -e "${WHITE}[1]${CYAN} Best Quality Video"
    echo -e "${WHITE}[2]${CYAN} 720P Video"
    echo -e "${WHITE}[3]${CYAN} MP3 Audio"
    echo -e "${WHITE}[4]${CYAN} Image Download"
    echo -e "${WHITE}[5]${CYAN} Thumbnail"
    echo -e "${WHITE}[6]${CYAN} Download History"
    echo -e "${WHITE}[7]${CYAN} Check Update"
    echo -e "${WHITE}[0]${RED} Exit${RESET}"

    echo
    read -p "Select: " MENU
}
