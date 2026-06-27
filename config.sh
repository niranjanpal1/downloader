#!/data/data/com.termux/files/usr/bin/bash

# ===============================
# UL Downloader Configuration
# ===============================

SCRIPT_NAME="UL Downloader"
SCRIPT_VERSION="11.0"

# GitHub
GITHUB_USER="niranjanpal1"
GITHUB_REPO="downloader"
RAW_JSON_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main/key.json"

# Facebook
FB_URL="https://www.facebook.com/akash.pal.niranjan"

# yt-dlp
YTDL="yt-dlp --no-cache-dir --rm-cache-dir --concurrent-fragments 5"

# Download directories
DOWNLOAD_DIR="/sdcard/Download"

VIDEO_DIR="$DOWNLOAD_DIR/UL-Videos"
AUDIO_DIR="$DOWNLOAD_DIR/UL-Audio"
IMAGE_DIR="$DOWNLOAD_DIR/UL-Images"

# Runtime files
SESSION_TOKEN="$HOME/.vd_session"
BAN_FILE="$HOME/.vd_ban_sys"

MAX_ATTEMPTS=3
