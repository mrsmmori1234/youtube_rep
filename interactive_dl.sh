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

    RAW_TITLE=$(yt-dlp --get-title "$url")
    SAFE_TITLE=$(echo "$RAW_TITLE" | tr -d '/\?%*:|"<>')
    SAFE_TITLE=${SAFE_TITLE:0:50}   # Shorten to 50 chars

    echo "Download started: $SAFE_TITLE"

    # ---------- Video Download ----------
    yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" \
        --merge-output-format mp4 \
        --ffmpeg-location /usr/bin/ffmpeg \
        --download-archive "$LOG_FILE" \
        -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
        "$url"

    DL_STATUS=$?

    # ---------- Subtitle Processing ----------
    if [[ "$DL_STATUS" -eq 0 && "$sub_choice" == "y" ]]; then
        echo "Fetching subtitles: attempting ja"

        yt-dlp --skip-download \
            --write-subs \
            --sub-lang "ja" \
            --convert-subs srt \
            --ffmpeg-location /usr/bin/ffmpeg \
            -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
            "$url"

        # If ja not found, get en
        if ! ls "$MP4_DIR/${SAFE_TITLE}-"*".ja.srt" >/dev/null 2>&1; then
            echo "No ja subtitles → fetching en"
            yt-dlp --skip-download \
                --write-subs \
                --sub-lang "en" \
                --convert-subs srt \
                --ffmpeg-location /usr/bin/ffmpeg \
                -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
                "$url"
        fi
    fi

    # ---------- Result Processing ----------
    if [[ "$DL_STATUS" -eq 0 ]]; then
        echo "✅ Download completed: $SAFE_TITLE"

        if [[ "$sub_choice" == "y" ]]; then
            if ls "$MP4_DIR/${SAFE_TITLE}-"*.srt &>/dev/null; then
                echo "Subtitles fetched:"
                ls "$MP4_DIR/${SAFE_TITLE}-"*.srt
            else
                echo "⚠️ Could not fetch subtitles."
            fi
        fi
    else
        echo "❌ Download failed: $url"
    fi

done

echo "🎉 All download processes completed."
