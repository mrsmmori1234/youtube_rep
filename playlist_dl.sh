#!/bin/bash
# playlist_dl.sh

OUTBASE="/mnt/d/Youtube"

read -p "Please enter the YouTube playlist or channel URL to download: " PLAYLIST_URL
if [ -z "$PLAYLIST_URL" ]; then
    echo "No URL entered. Exiting."
    exit 1
fi

read -p "Sort by popularity (view count)? (y/n): " SORT_CHOICE
SORT_OPTS=""
if [[ "$SORT_CHOICE" == "y" || "$SORT_CHOICE" == "Y" ]]; then
    # Highly compatible option for sorting by view count
    SORT_OPTS="--match-filter !is_live --sort-format view_count"
    echo "💡 Attempting to sort by popularity (most views)."
fi

echo "Please specify the number of items or range to download"
read -p "Start number (default: 1): " START_NUM
read -p "End number (e.g., 30): " END_NUM

START_NUM=${START_NUM:-1}
RANGE_OPTS="--playlist-start $START_NUM"
if [ -n "$END_NUM" ]; then
    RANGE_OPTS="$RANGE_OPTS --playlist-end $END_NUM"
fi

read -p "Download subtitles as well? (y/n): " SUB_CHOICE
SUB_OPTS=""
if [[ "$SUB_CHOICE" == "y" || "$SUB_CHOICE" == "Y" ]]; then
    SUB_OPTS="--write-subs --write-auto-subs --sub-langs ja,en --sub-format srt"
fi

# Execute
# Instead of --order-by to avoid errors, or modern --parse-metadata alternatives,
# changed to specify view_count directly
yt-dlp \
  --format "bv*+ba/b" \
  --merge-output-format mp4 \
  --yes-playlist \
  --match-filter "!is_live" \
  $SORT_OPTS \
  $RANGE_OPTS \
  --download-archive "$HOME/youtube/logs/archive.txt" \
  --no-overwrites \
  --output "$OUTBASE/%(uploader)s/%(title)s - %(id)s.%(ext)s" \
  $SUB_OPTS \
  --ignore-errors \
  --sleep-interval 5 \
  --max-sleep-interval 30 \
  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "$PLAYLIST_URL"

echo "✅ Process completed. Saved to: $OUTBASE"
