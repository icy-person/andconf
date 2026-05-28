#!/bin/bash

# --- ۱. بهینه‌سازی وحشیانه هسته لینوکس (Kernel Tuning) ---
echo "🛠 Tuning System for Ultra-Low Latency Gaming..."

# فعال‌سازی BBR و بهینه‌سازی صف پکت‌ها
sudo modprobe tcp_bbr
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
sudo sysctl -w net.core.default_qdisc=fq_codel

# تنظیمات اختصاصی پینگ پایین
sudo sysctl -w net.ipv4.tcp_fastopen=3
sudo sysctl -w net.ipv4.tcp_low_latency=1
sudo sysctl -w net.ipv4.tcp_autocorking=0
sudo sysctl -w net.ipv4.tcp_no_metrics_save=1
sudo sysctl -w net.ipv4.tcp_timestamps=0
sudo sysctl -w net.ipv4.tcp_sack=1

# افزایش بافرهای شبکه برای استفاده از ۸ گیگ رم
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216'
sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216'


sudo ip link set dev eth0 mtu 1350 2>/dev/null || echo "⚠️ Could not change MTU, skipping..."
# بالا بردن محدودیت فایل‌های باز (مانع قطع شدن کانکشن‌های زیاد)
ulimit -n 1000000

echo "📦 Installing dependencies (unzip, wget)..."
sudo apt update && sudo apt install -y unzip  wget > /dev/null 2>&1

# --- ۲. نصب Xray (نسخه 64 بیتی بهینه) ---
if [ ! -f "/usr/local/bin/xray" ]; then
    echo "📥 Downloading Xray Core..."
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
    sudo unzip -q -o Xray-linux-64.zip -d /usr/local/bin/ xray
    sudo chmod +x /usr/local/bin/xray
    rm Xray-linux-64.zip
    echo "✅ Xray Installed."
else
    echo "✔ Xray is already there."
fi

# --- ۳. آماده‌سازی محیط اجرا ---
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$WORKING_DIR/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: config.json not found in $WORKING_DIR"
    exit 1
fi

sudo pkill xray > /dev/null 2>&1

# --- ۴. اجرای Xray با اولویت Real-time و مانیتورینگ ---
echo "🚀 GOD MODE: Xray is now the Boss of this Server!"
echo "🔗 GitHub Port Forwarding: Set Port 8888 to PUBLIC in the Ports tab."

# اجرای در یک حلقه که اگر پروسس بسته شد، دوباره باز شود
(
    while true; do
        # اجرای Xray با اولویت ۹۹ (بالاترین) و قفل کردن روی هر دو هسته CPU
        sudo taskset -c 0,1 sudo chrt -f 99 /usr/local/bin/xray run -c "$CONFIG_FILE" > /dev/null 2>&1
        echo "⚠️ Xray crashed or stopped, restarting in 1 second..."
        sleep 1
    done
) &

# --- ۵. حلقه بیدارباش هوشمند (Keep-Alive) ---
# این بخش باعث میشه Codespace فکر کنه شما دارید کار سنگین می‌کنید و خاموش نشه
echo "☕ Keeping Codespace alive and kicking..."
while true; do
    # چاپ وضعیت در کنسول گیت‌هاب برای زنده نگه داشتن محیط
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] - Status: Active - CPU Priority: Real-time"
    
    # یک فعالیت فیک روی فایل
    echo "Alive at $TIMESTAMP" >> .keep_alive
    
    # خواب ۵ دقیقه‌ای (۳۰۰ ثانیه)
    sleep 300
done
