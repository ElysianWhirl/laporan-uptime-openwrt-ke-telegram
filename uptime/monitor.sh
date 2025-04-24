#!/bin/sh

URL="https://www.bing.com"
LOGFILE="/root/uptime/httping.log"
DATE=$(date +%s)

LINE=$(httping -c 4 -s "$URL" 2>/dev/null | grep round)
if [ -n "$LINE" ]; then
    RESULT=$(echo "$LINE" | awk '{print $4}' | sed 's/ms//')
    echo "$DATE|$RESULT|1" >> "$LOGFILE"   # Status 1 = UP
else
    echo "$DATE|0|0" >> "$LOGFILE"         # Status 0 = DOWN (timeout, dll)
fi

# Batasi ukuran log hanya untuk 90 hari (5 menit interval = ~25920 baris)
tail -n 26000 "$LOGFILE" > "$LOGFILE.tmp" && mv "$LOGFILE.tmp" "$LOGFILE"
