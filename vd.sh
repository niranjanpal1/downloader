#!/data/data/com.termux/files/usr/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/config.sh"
source "$BASE_DIR/lib/colors.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/network.sh"
source "$BASE_DIR/ui.sh"
source "$BASE_DIR/auth.sh"
source "$BASE_DIR/download.sh"
source "$BASE_DIR/history.sh"
source "$BASE_DIR/update.sh"

login

while true
do
    print_header
    show_menu

    case "$MENU" in

        1)
            download_best
            ;;

        2)
            download_720p
            ;;

        3)
            download_mp3
            ;;

        4)
            download_image
            ;;

        5)
            download_thumbnail
            ;;

        6)
            show_history
            ;;

        7)
            check_update
            ;;

        0)
            echo "Goodbye!"
            exit 0
            ;;

        *)
            echo "Invalid option!"
            sleep 1
            ;;

    esac
done
