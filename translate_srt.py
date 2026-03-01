import os
import sys
import re
import deepl
import pysrt
import time

# --- 設定 ---
DEFAULT_PATH = "/mnt/d/Youtube/Most popular TED Talks of 2025"

def convert_windows_path(win_path):
    path = win_path.strip().strip('"').strip("'")
    match = re.match(r'^([a-zA-Z]):\\(.*)', path)
    if match:
        drive = match.group(1).lower()
        rest = match.group(2).replace('\\', '/')
        return f"/mnt/{drive}/{rest}"
    return path

def get_target_directory():
    print("="*50)
    print("    SRT字幕 一括併記翻訳ツール (DeepL版)")
    print("="*50)
    print(f"\nデフォルト: {DEFAULT_PATH}")
    user_input = input("対象ディレクトリを入力 (Enterでデフォルト) >> ").strip()
    target_path = DEFAULT_PATH if not user_input else convert_windows_path(user_input)

    if not os.path.isdir(target_path):
        print(f"エラー: '{target_path}' が見つかりません。")
        sys.exit(1)
    return target_path

def translate_srt():
    input_dir = get_target_directory()
    translator = deepl.Translator(DEEPL_API_KEY)

    # 元ファイル（.srt）を取得し、すでに翻訳済みのものは除外対象とする準備
    files = [f for f in os.listdir(input_dir) if f.endswith(".srt") and not f.endswith("_bilingual.srt")]

    for filename in files:
        file_path = os.path.join(input_dir, filename)
        # 出力ファイル名を先に生成
        output_filename = filename.replace(".srt", "_bilingual.srt")
        output_path = os.path.join(input_dir, output_filename)

        # --- 【追加】スキップ判定 ---
        if os.path.exists(output_path):
            print(f"\n>>> スキップ: {output_filename} は既に存在します。")
            continue
        # ------------------------

        print(f"\n--- 翻訳中: {filename} ---")

        try:
            try:
                subs = pysrt.open(file_path, encoding='utf-8')
            except:
                subs = pysrt.open(file_path, encoding='cp1252')

            texts = [sub.text for sub in subs]

            print(f"  DeepLで翻訳リクエスト中 ({len(texts)}行)...")
            results = translator.translate_text(texts, source_lang="EN", target_lang="JA")

            for sub, translated in zip(subs, results):
                sub.text = f"{sub.text}\n{translated.text}"

            subs.save(output_path, encoding='utf-8')
            print(f"  完了: {output_filename}")

        except Exception as e:
            print(f"  エラー発生: {e}")

if __name__ == "__main__":
    translate_srt()
