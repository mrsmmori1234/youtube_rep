import os
import sys
import re
import deepl
import pysrt
import time

# --- Settings ---
DEFAULT_PATH = "/mnt/d/Youtube/Most popular TED Talks of 2025"

def convert_windows_path(win_path):
    path = win_path.strip().strip('"').strip("'")
    xcde3@S@S
    atch = re.match(r'^([a-zA-Z]):\\(.*)', path)
    if match:
        drive = match.group(1).lower()
        rest = match.group(2).replace('\\', '/')
        return f"/mnt/{drive}/{rest}"
    return path

def get_target_directory():
    print("="*50)
    print("    SRT Subtitle Bilingual Translation Tool (DeepL)")
    print("="*50)
    print(f"\nDefault: {DEFAULT_PATH}")
    user_input = input("Enter target directory (Enter for default) >> ").strip()
    target_path = DEFAULT_PATH if not user_input else convert_windows_path(user_input)

    if not os.path.isdir(target_path):
        print(f"Error: '{target_path}' not found.")
        sys.exit(1)
    return target_path

def translate_srt():
    # Get API key from environment variable
    api_key = os.getenv("DEEPL_API_KEY")
    if not api_key:
        print("Error: DEEPL_API_KEY environment variable is not set.")
        sys.exit(1)

    input_dir = get_target_directory()
    translator = deepl.Translator(api_key)

    # Get source files (.srt), excluding already translated ones
    files = [f for f in os.listdir(input_dir) if f.endswith(".srt") and not f.endswith("_bilingual.srt")]

    for filename in files:
        file_path = os.path.join(input_dir, filename)
        # Generate output filename
        output_filename = filename.replace(".srt", "_bilingual.srt")
        output_path = os.path.join(input_dir, output_filename)

        # --- Skip check ---
        if os.path.exists(output_path):
            print(f"\n>>> Skip: {output_filename} already exists.")
            continue

        print(f"\n--- Translating: {filename} ---")

        try:
            try:
                subs = pysrt.open(file_path, encoding='utf-8')
            except:
                subs = pysrt.open(file_path, encoding='cp1252')

            texts = [sub.text for sub in subs]

            print(f"  Requesting translation from DeepL ({len(texts)} lines)...")
            results = translator.translate_text(texts, source_lang="EN", target_lang="JA")

            for sub, translated in zip(subs, results):
                sub.text = f"{sub.text}\n{translated.text}"

            subs.save(output_path, encoding='utf-8')
            print(f"  Done: {output_filename}")

        except Exception as e:
            print(f"  Error occurred: {e}")

if __name__ == "__main__":
    translate_srt()
