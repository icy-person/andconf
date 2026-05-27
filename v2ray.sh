#!/bin/bash

# پیدا کردن مسیر دقیق پوشه مخزن
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$REPO_DIR/config.json"

echo "🔍 Checking for config file at: $CONFIG_FILE"

# بررسی وجود فایل کانفیگ قبل از اجرا
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: config.json not found in the repository folder!"
    exit 1
fi

# ۱. اجرای Xray با اولویت پردازشی بالا (Real-time priority)
# استفاده از مسیر مستقیم فایل کانفیگ در مخزن
sudo nice -n -20 xray run -c "$CONFIG_FILE" > /dev/null 2>&1 &
echo "🚀 Xray Server is UP on port 8888!"

# ۲. بیدار نگه داشتن محیط برای ۶ ساعت (۷۲ مرتبه ۵ دقیقه)
echo "☕ Keep-alive active for 6 hours. Let's play!"
for ((i=1; i<=72; i++)); do
    # نمایش زمان باقی‌مانده (آپشن اضافه برای کلاس کار!)
    REMAINING=$(( (72 - i) * 5 ))
    echo "Status: Active - $(date +%H:%M:%S) - Approx $REMAINING mins left."
    sleep 300
done

# ۳. عملیات پاک‌سازی و ذخیره سهمیه
echo "🛑 6 hours finished. Shutting down to save your GitHub quota..."
sudo pkill xray
echo "✅ Done. See you tomorrow!"
