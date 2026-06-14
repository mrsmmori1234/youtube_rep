import httpx
import json
import sys
import re
import os
from typing import Optional, Dict, Any, List
try:
    from playwright.sync_api import sync_playwright
except ImportError:
    sync_playwright = None

def fetch_tver_metadata(episode_id: str) -> Optional[Dict[str, Any]]:
    """
    Fetches metadata for a specific TVer episode.
    Requires a Japanese IP address.
    """
    # TVer's internal API for episode metadata
    url = f"https://statics.tver.jp/content/episode/{episode_id}.json"
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Origin": "https://tver.jp",
        "Referer": "https://tver.jp/",
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.get(url, headers=headers)
            response.raise_for_status()
            return response.json()
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 403:
            print("❌ Error: 403 Forbidden. This is likely due to Geo-blocking (Japan only).")
        else:
            print(f"❌ HTTP Error: {e.response.status_code}")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
    
    return None

def save_urls_to_file(urls: List[str], filename: str = "tver_urls.txt", overwrite: bool = False):
    """URLをファイルに保存します。overwrite=True の場合はファイルを上書き（置き換え）します。"""
    existing_urls = set()
    # 追記モードの場合のみ、既存のURLを読み込んで重複を避ける
    if not overwrite and os.path.exists(filename):
        with open(filename, "r", encoding="utf-8") as f:
            existing_urls = {line.strip() for line in f if line.strip()}

    new_count = 0
    mode = "w" if overwrite else "a"
    try:
        with open(filename, mode, encoding="utf-8") as f:
            for url in urls:
                if url not in existing_urls:
                    f.write(f"{url}\n")
                    existing_urls.add(url)
                    new_count += 1
        if new_count > 0:
            print(f"💾 {new_count} 件のURLを {filename} に{'保存（上書き）' if overwrite else '追記'}しました。")
        else:
            print("✨ すべてのURLは既に保存済みです。")
    except Exception as e:
        print(f"❌ ファイル保存エラー: {e}")

def fetch_favorites_from_browser():
    """Playwrightを使用してブラウザを起動し、お気に入りページからURLを取得します。"""
    if sync_playwright is None:
        print("❌ エラー: playwright がインストールされていません。")
        print("以下のコマンドを実行してください:\npip install playwright && playwright install chromium")
        return []

    with sync_playwright() as p:
        # ユーザーがログイン状態を確認できるよう、headless=False (ブラウザを表示) で起動
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()

        print("🚀 Chromeを起動して、お気に入りページに移動します...")
        page.goto("https://tver.jp/mypage/fav")

        print("\n⏳ ページが完全に読み込まれ、動画リストが表示されるまで待機してください。")
        print("💡 ログインが必要な場合はブラウザ側でログインを完了させてください。")
        input("👉 準備ができたら、このターミナルで Enter キーを押すとURLの抽出を開始します...")

        content = page.content()
        episode_ids = re.findall(r'/episodes/(ep[a-z0-9]+)', content)
        urls = [f"https://tver.jp/episodes/{eid}" for eid in dict.fromkeys(episode_ids)]

        browser.close()
        return urls

def main():
    if len(sys.argv) < 2:
        print("使い方:")
        print("  お気に入り一括取得: python tver_scraper.py fav")
        print("  エピソードID指定: python tver_scraper.py <episode_id>")
        print("  HTMLファイル指定: python tver_scraper.py <saved_page.html>")
        return

    arg = sys.argv[1]

    if arg == "fav":
        urls = fetch_favorites_from_browser()
        if urls:
            save_urls_to_file(urls, overwrite=True)
        else:
            print("⚠️ URLが見つかりませんでした。")
        return

    # 引数がファイルパスの場合は、そのファイル内のURLを抽出する
    if os.path.isfile(arg):
        print(f"📄 ファイル '{arg}' からエピソードURLを抽出しています...")
        with open(arg, "r", encoding="utf-8") as f:
            content = f.read()
        # /episodes/epXXXXXXXX のパターンを抽出
        episode_ids = re.findall(r'/episodes/(ep[a-z0-9]+)', content)
        urls = [f"https://tver.jp/episodes/{eid}" for eid in dict.fromkeys(episode_ids)]
        
        if urls:
            # お気に入りページからの抽出時は、ファイルの中身をすべて置き換える
            save_urls_to_file(urls, overwrite=True)
        else:
            print("⚠️ 有効なエピソードURLが見つかりませんでした。")
            print("※ブラウザでページが完全に表示された状態で保存したHTMLを使用してください。")
        return

    # それ以外は単一のエピソードIDとして処理
    episode_id = arg
    print(f"🔍 {episode_id} のメタデータを取得中...")
    
    metadata = fetch_tver_metadata(episode_id)
    
    if metadata:
        # Extract key fields
        title = metadata.get("title")
        series = metadata.get("seriesTitle")
        broadcaster = metadata.get("broadcasterName")
        
        print("\n✅ Metadata Retrieved:")
        print(f"Title:       {title}")
        print(f"Series:      {series}")
        print(f"Broadcaster: {broadcaster}")
        
        # 個別ID取得時は従来通り追記する
        save_urls_to_file([f"https://tver.jp/episodes/{episode_id}"], overwrite=False)

if __name__ == "__main__":
    main()
