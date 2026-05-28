#!/bin/bash

# --- تنظیمات ---
PORT=8888
CONFIG_FILE="config.json"
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "🎯 Starting All-in-One Setup..."

# ۱. نصب پیش‌نیازها
echo "📦 Installing dependencies (unzip, dbus, screen)..."
sudo apt update && sudo apt install -y unzip dbus-x11 screen wget > /dev/null 2>&1

# ۲. دانلود و نصب Xray (روش دستی برای دور زدن خطای 403)
if [ ! -f "/usr/local/bin/xray" ]; then
    echo "📥 Downloading Xray Core..."
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
    sudo unzip -q Xray-linux-64.zip -d xray_temp
    sudo mv xray_temp/xray /usr/local/bin/
    sudo chmod +x /usr/local/bin/xray
    rm -rf xray_temp Xray-linux-64.zip
    echo "✅ Xray installed successfully!"
else
    echo "✔ Xray is already installed."
fi

# ۳. بررسی وجود فایل کانفیگ
if [ ! -f "$WORKING_DIR/$CONFIG_FILE" ]; then
    echo "❌ Error: $CONFIG_FILE not found in $WORKING_DIR!"
    echo "Please make sure your config.json is in the repository."
    exit 1
fi

# ۴. آزادسازی پورت و اجرای Xray
echo "🚀 Killing old processes and starting Xray..."
sudo pkill xray > /dev/null 2>&1
sudo nice -n -20 ionice -c 1 -n 0 /usr/local/bin/xray run -c "$WORKING_DIR/$CONFIG_FILE" > /dev/null 2>&1 &

# ۵. حلقه بیدارباش (۶ ساعت)
echo "☕ Everything is set! Keeping Codespace alive for 6 hours..."
echo "🔗 Remember to set Port $PORT to PUBLIC in the Ports tab!"

for ((i=1; i<=72; i++)); do
    REMAINING=$(( (72 - i) * 5 ))
    # چاپ وضعیت برای اینکه گیت‌هاب بفهمد فعالیت داریم
    echo "Status: [$(date +%H:%M:%S)] - Active - $REMAINING mins remaining"
    # یک فعالیت فیک برای زنده نگه داشتن محیط
    touch .keep_alive
    sleep 300
done

# ۶. پایان و صرفه‌جویی در سهمیه
echo "🛑 Time's up! Shutting down to save your GitHub quota."
sudo pkill xray
rm .keep_alive
