import speedtest

def measure_speed():
    print("Measuring... Please wait.")
    
    # Create Speedtest instance
    st = speedtest.Speedtest()
    
    # Select best server
    st.get_best_server()
    
    # Measure download speed (convert bits/s to Mbps)
    download_speed = st.download() / 1_000_000
    
    # Measure upload speed (convert bits/s to Mbps)
    upload_speed = st.upload() / 1_000_000
    
    # Get Ping value (latency)
    ping = st.results.ping

    print(f"Download: {download_speed:.2f} Mbps")
    print(f"Upload: {upload_speed:.2f} Mbps")
    print(f"Ping: {ping:.2f} ms")

if __name__ == "__main__":
    measure_speed()