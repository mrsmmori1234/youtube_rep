#!/bin/bash

# TVer batch download script (no subtitles)

URL_FILE="tver_urls.txt"
MP4_DIR=/mnt/d/TVer
LOG_FILE="$HOME/youtube/logs/archive.txt"

mkdir -p "$MP4_DIR"
touch "$LOG_FILE"

if [ ! -f "$URL_FILE" ]; then
    echo "❌ URL list file $URL_FILE not found."
    exit 1
fi

while IFS= read -r url; do
    # Skip empty lines
    [[ -z "$url" ]] && continue

    RAW_TITLE=$(yt-dlp --get-title "$url" 2>/dev/null)
    SAFE_TITLE=$(echo "$RAW_TITLE" | tr -d '/\?%*:|"<>')
    SAFE_TITLE=${SAFE_TITLE:0:50}
    FILE_PATH="$MP4_DIR/${SAFE_TITLE}-$(yt-dlp --get-id "$url").mp4"

    # Check if file actually exists
    if [ -f "$FILE_PATH" ]; then
        echo "✅ Already saved: $FILE_PATH"
        continue
    fi

    echo "▶️ Download started: $SAFE_TITLE"

    yt-dlp \
        --merge-output-format mp4 \
        --ffmpeg-location /usr/bin/ffmpeg \
        --download-archive "$LOG_FILE" \
        -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
        "$url"

    if [ $? -eq 0 ]; then
        echo "✅ Download completed: $SAFE_TITLE"
    else
        echo "❌ Download failed: $url"
        echo "ℹ️ To check formats:"
        echo "   yt-dlp -F \"$url\""
    fi

done < "$URL_FILE"

echo "🎉 Batch download process completed."
