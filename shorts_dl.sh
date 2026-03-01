#!/bin/bash
# shorts_dl.sh
# Batch download of Shorts from a channel (no subtitles)

# Base directory for saving
OUTBASE="/mnt/d/Youtube"

# Prompt user for input
read -p "Enter the YouTube Shorts URL to download: " SHORTS_URL

# Exit if input is empty
if [ -z "$SHORTS_URL" ]; then
    echo "No URL entered. Exiting."
    exit 1
fi

# Execute yt-dlp
yt-dlp \
  --format "bestvideo+bestaudio/best" \
  --merge-output-format mp4 \
  --yes-playlist \
  --download-archive "$HOME/youtube/logs/archive.txt" \
  --no-overwrites \
  --output "$OUTBASE/%(channel)s/Shorts/%(upload_date)s - %(title)s - %(id)s.%(ext)s" \
  "$SHORTS_URL"

echo "✅ Shorts download completed. Saved to: $OUTBASE"
