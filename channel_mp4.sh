#!/bin/bash
# channel_mp4.sh
# Download only the latest 2 videos from each URL, skip existing
# Subtitles in English only

OUTBASE="/mnt/d/Youtube"
DOWNLOAD_ARCHIVE="$HOME/youtube/logs/archive.txt"
OUTPUT_TEMPLATE="$OUTBASE/%(playlist_title)s/%(upload_date>%Y-%m-%d)s - %(title)s - %(id)s.%(ext)s"
CHANNEL_LIST="$HOME/youtube/channels.txt"

if [ ! -f "$CHANNEL_LIST" ]; then
    echo "❌ Error: Channel list file not found: $CHANNEL_LIST"
    exit 1
fi

mkdir -p "$OUTBASE"
touch "$DOWNLOAD_ARCHIVE"

# Read from file, ignoring comments (#) and empty lines
mapfile -t CHANNELS < <(grep -v -E '^\s*#|^\s*$' "$CHANNEL_LIST")

for entry in "${CHANNELS[@]}"; do
    url="${entry%%|*}"
    flag="${entry##*|}"

    echo "----"
    echo "Processing: $url (subs=$flag)"

    if [[ "$flag" =~ ^([yY])$ ]]; then
        SUB_OPTS=( --write-subs --write-auto-subs --sub-lang "en" --sub-format srt --convert-subs srt --embed-subs )
    else
        SUB_OPTS=()
    fi

    # Get IDs of the latest 2 videos
    ids=$(yt-dlp --get-id --playlist-end 2 "$url")

    # Check if all are already downloaded
    all_downloaded=true
    for id in $ids; do
        if ! grep -q "$id" "$DOWNLOAD_ARCHIVE"; then
            all_downloaded=false
            break
        fi
    done

    if $all_downloaded; then
        echo "➡️ Latest 2 videos already downloaded. Skipping."
        continue
    fi

    # Execute DL
    yt-dlp \
      --format "bestvideo[height<=720]+bestaudio/best[height<=720]" \
      --merge-output-format mp4 \
      --download-archive "$DOWNLOAD_ARCHIVE" \
      --no-overwrites \
      --playlist-end 2 \
      --ignore-errors \
      --output "$OUTPUT_TEMPLATE" \
      "${SUB_OPTS[@]}" \
      "$url"

    echo "Completed: $url"
done

echo "✅ All processes completed"
