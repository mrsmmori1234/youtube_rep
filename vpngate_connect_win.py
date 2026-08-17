import csv
import base64
import os
import subprocess
import sys
import tempfile
import urllib.request

API_URL = "http://www.vpngate.net/api/iphone/"
OPENVPN_PATH = r"C:\Program Files\OpenVPN\bin\openvpn.exe"

def check_admin():
    """Windows管理者権限の確認"""
    try:
        import ctypes
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except Exception:
        return False

def get_best_vpn_config():
    print("VPN Gateから最新のサーバーリストを取得中...")
    try:
        req = urllib.request.Request(API_URL, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            lines = [line.decode('utf-8', errors='ignore') for line in response.readlines()]
    except Exception as e:
        print(f"エラー: サーバーリストの取得に失敗しました: {e}")
        sys.exit(1)

    csv_data = [line for line in lines if not line.startswith('*') and line.strip()]
    reader = csv.DictReader(csv_data)

    best_server = None
    max_score = -1

    # 日本国内(JP)かつ最高スコアのサーバーを選出
    for row in reader:
        try:
            country = row.get("CountryShort", "")
            score = int(row.get("Score", 0))
            ovpn_b64 = row.get("OpenVPN_ConfigData_Base64", "")

            if country == "JP" and score > max_score and ovpn_b64:
                max_score = score
                best_server = row
        except (ValueError, KeyError):
            continue

    if not best_server:
        print("利用可能な日本のVPNサーバーが見つかりませんでした。")
        sys.exit(1)

    print(f"接続先決定: {best_server['IP']} ({best_server['HostName']}) - スコア: {max_score}")
    return base64.b64decode(best_server["OpenVPN_ConfigData_Base64"]).decode('utf-8')

def connect_vpn(ovpn_config):
    if not os.path.exists(OPENVPN_PATH):
        print(f"エラー: OpenVPNが見つかりません。\nパスを確認してください: {OPENVPN_PATH}")
        sys.exit(1)

    # 一時的な .ovpn ファイルを作成
    with tempfile.NamedTemporaryFile(mode='w', suffix='.ovpn', delete=False) as tmp:
        tmp.write(ovpn_config)
        tmp_path = tmp.name

    print("\n--- VPN接続を開始します ---")
    print("切断するにはこのウィンドウで Ctrl + C を押してください。\n")

    try:
        # OpenVPNコマンドを実行
        subprocess.run([OPENVPN_PATH, "--config", tmp_path])
    except KeyboardInterrupt:
        print("\nVPN接続を終了しました。")
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

if __name__ == "__main__":
    if not check_admin():
        print("エラー: ネットワーク設定を変更するため『管理者として実行』が必要です。")
        print("右クリックして『管理者として実行』するか、batファイルから起動してください。")
        input("\nEnterキーを押して終了...")
        sys.exit(1)

    config = get_best_vpn_config()
    connect_vpn(config)
