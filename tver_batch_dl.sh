#!/bin/bash

#python "/home/mrsmmori/youtube/speed_test.py"  # Run speed test before downloading

# TVer batch download script (no subtitles)

URL_FILE="/home/mrsmmori/youtube/tver_urls.txt"
MP4_DIR="/mnt/d/TVer"
LOG_FILE="$HOME/youtube/logs/archive.txt" # Share DL history across multiple scripts

mkdir -p "$MP4_DIR"
touch "$LOG_FILE"

if [ ! -f "$URL_FILE" ]; then
    echo "❌ URL list file not found: $URL_FILE"
    exit 1
fi

echo "▶️ Starting batch download. Previously downloaded files will be skipped."

# - Limit title to 50 characters to prevent sub-stream .ytdl files from exceeding Linux 255-byte limit
# - Replaced raw title with ID + truncated title for cleaner, collision-safe filenames
yt-dlp \
    -a "$URL_FILE" \
    --merge-output-format mp4 \
    --ffmpeg-location /usr/bin/ffmpeg \
    --download-archive "$LOG_FILE" \
    --no-overwrites \
    --ignore-errors \
    -o "$MP4_DIR/%(id)s_%(title).50s.%(ext)s"

echo "🎉 Batch download process completed."
