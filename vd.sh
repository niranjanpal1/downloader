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

# --- Configuration & Paths ---
FB_URL="https://www.facebook.com/akash.pal.niranjan"
KEY_URL="https://raw.githubusercontent.com/niranjanpal1/downloader/main/key.txt"
YTDL="yt-dlp --no-cache-dir --rm-cache-dir"
DOWNLOAD_DIR="/sdcard/Download"
HISTORY_FILE="$DOWNLOAD_DIR/download_history.txt"
SCRIPT_DIR="$HOME/downloader"

# Auto install yt-dlp if missing
if! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}📦 yt-dlp nai. Install korchi...${RESET}"
    pip install -U yt-dlp
fi

# Storage Permission and Directory setup
if [! -d "$DOWNLOAD_DIR" ]; then
    echo -e "${YELLOW}🔑 Storage Permission lagche... Allow koro!${RESET}"
    termux-setup-storage
    sleep 2
    mkdir -p "$DOWNLOAD_DIR"
fi

clear
# --- Online Verification Lock ---
while true; do
    clear
    echo -e "${RED}=================================================${RESET}"
    echo -e "${RED} 🔒 PREMIUM APP IS LOCKED BY ADMIN 🔒 ${RESET}"
    echo -e "${RED}=================================================${RESET}"
    echo -e "${WHITE} 📢 USER INSTRUCTIONS:${RESET}"
    echo -e "${GREEN} 1. Find the secret code in Admin's Facebook Bio.${RESET}"
    echo -e "${CYAN} 2. Enter the code below to unlock the app.${RESET}"
    echo -e "${YELLOW} 3. Internet Required for Verification.${RESET}"
    echo -e "${RED}=================================================${RESET}"
    echo
    echo -e "${CYAN}🔗 Facebook Link: ${FB_URL}${RESET}"
    echo -e "${MAGENTA}-------------------------------------------------${RESET}"
    echo -e "${WHITE}👉 Press ENTER to Open Facebook & Get Secret Key...${RESET}"
    read

    if command -v termux-open &> /dev/null; then
        termux-open "$FB_URL"
    else
        am start -a android.intent.action.VIEW -d "$FB_URL" &> /dev/null
    fi

    echo
    printf "${WHITE}🔑 Enter Secret Key Here: ${RESET}"
    read user_code

    # Online Key Verification
    echo -e "${YELLOW}⏳ Verifying Key Online...${RESET}"
    REAL_KEY=$(curl -s --fail --max-time 10 "$KEY_URL" | tr -d '\n\r')

    if [ -z "$REAL_KEY" ]; then
        echo -e "\n${RED}❌ Network Error! Server theke key ana gelo na.${RESET}"
        echo -e "${WHITE}Net check kore ENTER press koro...${RESET}"
        read
        continue
    fi

    if [ "$user_code" = "$REAL_KEY" ]; then
        clear
        echo -e "${GREEN}=================================================${RESET}"
        echo -e "${GREEN}🎉 CONGRATULATIONS! ACCESS GRANTED ✔${RESET}"
        echo -e "${GREEN}=================================================${RESET}"
        echo -e "${WHITE}Secret Key Verified Successfully! App is unlocked.🔥${RESET}"
        echo -e "${CYAN}Press Enter to Open the Main Menu...${RESET}"
        read
        break
    else
        echo -e "\n${RED}❌ Invalid Key! Check the correct key from Admin's Bio.${RESET}"
        echo -e "${WHITE}Press ENTER to try again...${RESET}"
        read
    fi
done

# --- Main Download Menu ---
while true; do
    clear
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${MAGENTA} 🚀 ULTIMATE MULTI-DOWNLOADER (PRO HUB) ${RESET}"
    echo -e "${CYAN}=================================================${RESET}"
    echo -e "${YELLOW}👤 Admin: Akash Pal Niranjan${RESET}"
    echo

    echo -e " [1] ${GREEN}⭐ Max Video Quality (1080p / Best Overall)${RESET}"
    echo -e " [2] ${BLUE}🎬 720p HD Video Download (Data Saver)${RESET}"
    echo -e " [3] ${YELLOW}🎧 MP3 Audio Only (High Quality Extraction)${RESET}"
    echo -e " [4] ${MAGENTA}🖼️ Image/Photo Download (Direct URL)${RESET}"
    echo -e " [5] ${CYAN}📸 Download Video Thumbnail Only${RESET}"
    echo -e " [6] ${WHITE}📜 View Download History Log${RESET}"
    echo -e " [7] ${RED}🗑️ Clear Download History Log${RESET}"
    echo -e " [8] ${GREEN}🔄 Update Script from GitHub${RESET}"
    echo -e " [9] ${RED}❌ Exit${RESET}"
    echo
    echo -e "${CYAN}-------------------------------------------------${RESET}"

    printf "${WHITE}👉 Choose an option (1-9): ${RESET}"
    read op

    if [ "$op" = "6" ]; then
        clear
        echo -e "${YELLOW}====================================================================${RESET}"
        echo -e "${MAGENTA} 📜 --- DOWNLOAD HISTORY LOG --- ${RESET}"
        echo -e "${YELLOW}====================================================================${RESET}"
        printf "${WHITE}%-11s | %-8s | %-15s | %-s\n${RESET}" " DATE" " TIME" " TYPE" "URL / LINK"
        echo -e "${CYAN}--------------------------------------------------------------------${RESET}"

        if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
            while IFS='|' read -r datetime type url; do
                datetime=$(echo "$datetime" | xargs)
                type=$(echo "$type" | xargs)
                url=$(echo "$url" | xargs)
                v_date=$(echo "$datetime" | cut -d' ' -f1)
                v_time=$(echo "$datetime" | cut -d' ' -f2)
                printf "${WHITE}%-11s${RESET} | ${WHITE}%-8s${RESET} | ${GREEN}%-15s${RESET} | ${CYAN}%-s${RESET}\n" "$v_date" "$v_time" "$type" "$url"
            done < "$HISTORY_FILE"
        else
            echo -e " ${RED}⚠️ No download history logs found yet!${RESET}"
        fi
        echo -e "${YELLOW}====================================================================${RESET}"
        echo -e "${WHITE}Press ENTER to return to Main Menu...${RESET}"
        read
        continue
    fi

    if [ "$op" = "7" ]; then
        clear
        echo -e "${RED}=================================================${RESET}"
        echo -e "${YELLOW} 🗑️ CLEAR DOWNLOAD HISTORY LOG ${RESET}"
        echo -e "${RED}=================================================${RESET}"
        printf "${WHITE}Are you sure you want to delete all history? (y/n): ${RESET}"
        read confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            > "$HISTORY_FILE"
            echo -e "\n${GREEN}🗑️ Download history cleared successfully!${RESET}"
        else
            echo -e "\n${BLUE}❌ Action cancelled. History was not deleted.${RESET}"
        fi
        echo -e "${RED}=================================================${RESET}"
        echo -e "${WHITE}Press ENTER to return to Main Menu...${RESET}"
        read
        continue
    fi

    if [ "$op" = "8" ]; then
        clear
        echo -e "${YELLOW}=================================================${RESET}"
        echo -e "${GREEN} 🔄 UPDATING SCRIPT FROM GITHUB ${RESET}"
        echo -e "${YELLOW}=================================================${RESET}"
        cd "$SCRIPT_DIR"
        echo -e "${CYAN}⏳ Checking for updates...${RESET}"
        git pull
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}✔ Script updated successfully! 🎉${RESET}"
            echo -e "${WHITE}Please restart the script to use new version.${RESET}"
            echo -e "${YELLOW}Restarting in 3 seconds...${RESET}"
            sleep 3
            exec bash "$0"
        else
            echo -e "\n${RED}❌ Update Failed! Check your internet or git setup.${RESET}"
        fi
        echo -e "${YELLOW}=================================================${RESET}"
        echo -e "${WHITE}Press ENTER to return to Main Menu...${RESET}"
        read
        continue
    fi

    if [ "$op" = "9" ]; then
        echo -e "\n${RED}Goodbye 👋 Thank you for using the app!${RESET}\n"
        exit 0
    fi

    if [[! "$op" =~ ^[1-5]$ ]]; then
        echo -e "\n${RED}❌ Invalid Option! Please select between 1 and 9.${RESET}"
        echo -e "${WHITE}Press ENTER to try again...${RESET}"
        read
        continue
    fi

    echo
    if [ "$op" = "4" ]; then
        printf "${WHITE}🔗 Paste Image Direct URL (JPG/PNG): ${RESET}"
    else
        printf "${WHITE}🔗 Paste Media Link here: ${RESET}"
    fi
    read url

    if [ -z "$url" ]; then
        echo -e "\n${RED}⚠️ URL cannot be empty! Please provide a valid link.${RESET}"
        echo -e "${WHITE}Press ENTER to continue...${RESET}"
        read
        continue
    fi

    if [[! "$url" =~ ^https?:// ]]; then
        echo -e "\n${RED}❌ Error: Invalid URL Format! Must start with http:// or https://${RESET}"
        echo -e "${WHITE}Press ENTER to continue...${RESET}"
        read
        continue
    fi

    PLAYLIST_ARG="--no-playlist"
    if [[ "$op" =~ ^[1-3]$ ]]; then
        printf "${YELLOW}❓ Is this link a Playlist? (y/n): ${RESET}"
        read is_playlist
        if [ "$is_playlist" = "y" ] || [ "$is_playlist" = "Y" ]; then
            PLAYLIST_ARG="--yes-playlist"
            echo -e "${GREEN}▶ Playlist Mode Enabled!${RESET}"
        else
            echo -e "${BLUE}▶ Single Video Mode Enabled!${RESET}"
        fi
    fi

    echo -e "\n${YELLOW}⏳ Processing Request... Please wait...${RESET}\n"

    OUT="$DOWNLOAD_DIR/%(title).50s.%(ext)s"

    case $op in
        1) $YTDL $PLAYLIST_ARG -f "bestvideo+bestaudio/best" -o "$OUT" "$url" ; type_str="Video(1080p)" ;;
        2) $YTDL $PLAYLIST_ARG -f "bestvideo[height<=720]+bestaudio/best[height<=720]" -o "$OUT" "$url" ; type_str="Video(720p)" ;;
        3) $YTDL $PLAYLIST_ARG -x --audio-format mp3 --audio-quality 0 -o "$OUT" "$url" ; type_str="MP3 Audio" ;;
        4)
            FILE_NAME=$(basename "$url" | cut -d? -f1)
            if [ -z "$FILE_NAME" ] || [[! "$FILE_NAME" =~ \.(jpg|jpeg|png|gif|webp)$ ]]; then
                FILE_NAME="Img_$(date +%Y%m%d_%H%M%S).jpg"
            fi
            FILE_NAME=$(echo "$FILE_NAME" | tr -cd 'A-Za-z0-9._-')
            curl -L -s --fail -o "$DOWNLOAD_DIR/$FILE_NAME" "$url"
            type_str="Direct Image"
            ;;
        5)
            $YTDL --skip-download --write-thumbnail --convert-thumbnails jpg -o "$DOWNLOAD_DIR/%(title).50s" "$url"
            type_str="Thumbnail"
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✔ Action Completed Successfully! 🎉${RESET}"
        echo -e "${GREEN}📂 Files saved to folder: $DOWNLOAD_DIR${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') | $type_str | $url" >> "$HISTORY_FILE"
    else
        echo -e "\n${RED}❌ Action Failed! Reason: Invalid link, Network drop or Restricted Video.${RESET}"
    fi

    echo
    echo -e "${WHITE}Press ENTER to continue...${RESET}"
    read
done
