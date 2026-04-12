#!/bin/bash

# MP4 + optional subtitle download script
# Output filename = Shortened title (50 chars) + Video ID

MP4_DIR=/mnt/d/Youtube
LOG_FILE="$HOME/youtube/logs/archive.txt"

mkdir -p "$MP4_DIR"
touch "$LOG_FILE"

while true; do
    read -p "Enter YouTube URL to download (empty to exit): " url
    [[ -z "$url" ]] && break

    # Subtitle download choice
    read -p "Download subtitles too? [y/N]: " sub_choice
    sub_choice=${sub_choice,,}  # to lowercase
    SUB_OPTS=()

    if [[ "$sub_choice" == "y" ]]; then
        echo "Fetching English subtitles..."
        SUB_OPTS=(--write-subs --write-auto-subs --sub-langs "en" --convert-subs srt)
    fi

    RAW_TITLE=$(yt-dlp --get-title "$url")
    SAFE_TITLE=$(echo "$RAW_TITLE" | tr -d '/\?%*:|"<>')
    SAFE_TITLE=${SAFE_TITLE:0:50}   # Shorten to 50 chars

    echo "Download started: $SAFE_TITLE"

    # ---------- Download (Video & Subtitles) ----------
    yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" \
        --merge-output-format mp4 \
        --ffmpeg-location /usr/bin/ffmpeg \
        --download-archive "$LOG_FILE" \
        -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
        "${SUB_OPTS[@]}" \
        "$url"

    DL_STATUS=$?

    # ---------- Result Processing ----------
    if [[ "$DL_STATUS" -eq 0 ]]; then
        echo "✅ Download completed: $SAFE_TITLE"
        [[ "$sub_choice" == "y" ]] && echo "Subtitles (en) processed if available."
    else
        echo "❌ Download failed: $url"
    fi

done

echo "🎉 All download processes completed."
