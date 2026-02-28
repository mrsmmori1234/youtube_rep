#!/bin/bash

# MP4 + optional 字幕ダウンロードスクリプト
# 出力ファイル名 = 短縮タイトル(50文字) + 動画ID

MP4_DIR=/mnt/d/Youtube
LOG_FILE=/home/mrsmmori/youtube/logs/downloaded.log

mkdir -p "$MP4_DIR"
touch "$LOG_FILE"

while true; do
    read -p "ダウンロードするYouTube URLを入力してください（終了は空入力）: " url
    [[ -z "$url" ]] && break

    if grep -qF "$url" "$LOG_FILE"; then
        echo "既に処理済み: $url"
        continue
    fi

    # 字幕ダウンロードの選択
    read -p "字幕もダウンロードしますか？ [y/N]: " sub_choice
    sub_choice=${sub_choice,,}  # 小文字化

    RAW_TITLE=$(yt-dlp --get-title "$url")
    SAFE_TITLE=$(echo "$RAW_TITLE" | tr -d '/\?%*:|"<>')
    SAFE_TITLE=${SAFE_TITLE:0:50}   # 50文字に短縮

    echo "ダウンロード開始: $SAFE_TITLE"

    # ---------- 動画ダウンロード ----------
    yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" \
        --merge-output-format mp4 \
        --ffmpeg-location /usr/bin/ffmpeg \
        -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
        "$url"

    DL_STATUS=$?

    # ---------- 字幕処理 ----------
    if [[ "$DL_STATUS" -eq 0 && "$sub_choice" == "y" ]]; then
        echo "字幕取得: ja を試行"

        yt-dlp --skip-download \
            --write-subs \
            --sub-lang "ja" \
            --convert-subs srt \
            --ffmpeg-location /usr/bin/ffmpeg \
            -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
            "$url"

        # ja が無ければ en を取得
        if ! ls "$MP4_DIR/${SAFE_TITLE}-"*".ja.srt" >/dev/null 2>&1; then
            echo "ja 字幕なし → en を取得"
            yt-dlp --skip-download \
                --write-subs \
                --sub-lang "en" \
                --convert-subs srt \
                --ffmpeg-location /usr/bin/ffmpeg \
                -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
                "$url"
        fi
    fi

    # ---------- 結果処理 ----------
    if [[ "$DL_STATUS" -eq 0 ]]; then
        echo "$url | ${SAFE_TITLE}-%(id)s.mp4" >> "$LOG_FILE"
        echo "✅ ダウンロード完了: $SAFE_TITLE"

        if [[ "$sub_choice" == "y" ]]; then
            if ls "$MP4_DIR/${SAFE_TITLE}-"*.srt &>/dev/null; then
                echo "字幕取得済み:"
                ls "$MP4_DIR/${SAFE_TITLE}-"*.srt
            else
                echo "⚠️ 字幕は取得できませんでした。"
            fi
        fi
    else
        echo "❌ ダウンロード失敗: $url"
    fi

done

echo "🎉 すべてのダウンロード処理が完了しました。"

