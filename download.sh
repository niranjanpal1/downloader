#!/data/data/com.termux/files/usr/bin/bash

# ===================================
# UL Downloader Download Engine
# ===================================

create_dirs() {
    mkdir -p "$VIDEO_DIR"
    mkdir -p "$AUDIO_DIR"
    mkdir -p "$IMAGE_DIR"
}

download_best() {
    read -p "URL: " url
    [ -z "$url" ] && return

    create_dirs

    $YTDL \
        -f "bestvideo+bestaudio/best" \
        -o "$VIDEO_DIR/%(title).50s.%(ext)s" \
        "$url"
}

download_720p() {
    read -p "URL: " url
    [ -z "$url" ] && return

    create_dirs

    $YTDL \
        -f "bestvideo[height<=720]+bestaudio/best" \
        -o "$VIDEO_DIR/%(title).50s.%(ext)s" \
        "$url"
}

download_mp3() {
    read -p "URL: " url
    [ -z "$url" ] && return

    create_dirs

    $YTDL \
        -x \
        --audio-format mp3 \
        -o "$AUDIO_DIR/%(title).50s.%(ext)s" \
        "$url"
}

download_thumbnail() {
    read -p "URL: " url
    [ -z "$url" ] && return

    create_dirs

    $YTDL \
        --skip-download \
        --write-thumbnail \
        --convert-thumbnails jpg \
        -o "$IMAGE_DIR/%(title).50s" \
        "$url"
}

download_image() {
    read -p "Image URL: " url
    [ -z "$url" ] && return

    create_dirs

    curl -L "$url" \
        -o "$IMAGE_DIR/IMG_$(date +%s).jpg"
}
