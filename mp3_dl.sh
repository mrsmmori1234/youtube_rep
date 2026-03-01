#!/bin/bash

# Download directory
DOWNLOAD_DIR=/mnt/d/Youtube_Music
LOG_FILE="$HOME/youtube/logs/archive.txt"

mkdir -p "$DOWNLOAD_DIR"
touch "$LOG_FILE"

while true; do
    # Enter URL
    read -p "Enter YouTube URL to download (empty to exit): " url
    [[ -z "$url" ]] && break

    echo "Downloading MP3: $url"

    # Download with yt-dlp
    yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 --no-video \
        --download-archive "$LOG_FILE" \
        --rm-cache-dir -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"

    if [ $? -eq 0 ]; then
        echo "Download completed: $url"
    else
        echo "Download failed: $url"
    fi
done

# Delete .webm files
echo "Deleting .webm files..."
find "$DOWNLOAD_DIR" -type f -name "*.webm" -delete

echo "Download and cleanup completed."
