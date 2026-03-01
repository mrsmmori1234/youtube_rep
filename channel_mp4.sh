#!/bin/bash
# channel_mp4.sh
# Download only the latest 2 videos from each URL, skip existing
# Subtitles in English only

OUTBASE="/mnt/d/Youtube"
DOWNLOAD_ARCHIVE="$HOME/youtube/logs/archive.txt"
OUTPUT_TEMPLATE="$OUTBASE/%(playlist_title)s/%(upload_date>%Y-%m-%d)s - %(title)s - %(id)s.%(ext)s"

CHANNELS=(
  "https://www.youtube.com/@ShigeTravel/videos|n"
  "https://www.youtube.com/@BappaShota/videos|n"
  "https://www.youtube.com/@iketomo-ch/videos|n"
  "https://www.youtube.com/@ai_masaou/videos|n"
)

mkdir -p "$OUTBASE"
touch "$DOWNLOAD_ARCHIVE"

for entry in "${CHANNELS[@]}"; do
    url="${entry%%|*}"
    flag="${entry##*|}"

    echo "----"
    echo "Processing: $url (subs=$flag)"

    if [[ "$flag" =~ ^([yY])$ ]]; then
        SUB_OPTS=( --write-subs --write-auto-subs --sub-lang "en" --sub-format srt --convert-subs srt )
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
      --format "bestvideo+bestaudio/best" \
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
