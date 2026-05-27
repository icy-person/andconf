#!/bin/bash
# اجرای Xray با اولویت پردازشی بالا برای کاهش پینگ
sudo nice -n -20 xray run -c ~/config.json > /dev/null 2>&1 &
echo "🚀 Server is UP on port 8888!"

# حلقه بیدار نگه داشتن برای ۶ ساعت (هر ۵ دقیقه یک سیگنال)
echo "☕ Stayin' alive for 6 hours... Grab a coffee!"
for ((i=1; i<=72; i++)); do
    echo "Status: Active - $(date +%H:%M:%S)"
    sleep 300
done

# بستن برنامه برای جلوگیری از جریمه سهمیه
sudo pkill xray
echo "🛑 Time is up! Quota saved."
