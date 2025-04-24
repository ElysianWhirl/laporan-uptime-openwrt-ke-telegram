#!/bin/sh

# Konfigurasi
LOGFILE="/root/uptime/httping.log"
NOW=$(date +%s)
TOKEN="your_token_bot"
CHAT_ID="chat_id"

# Fungsi untuk ambil statistik berdasarkan rentang waktu
get_stats() {
    local from=$1
    local label="$2"

    awk -F"|" -v now=$NOW -v from=$from -v label="$label" '
    BEGIN { count=0; sum=0; min=999999; max=0; up=0; }
    {
        if ($1 >= now - from) {
            count++;
            if ($3 == 1) {   # Hanya jika status up
                val = $2 + 0;
                if (val < min) min = val;
                if (val > max) max = val;
                sum += val;
                up++;
            }
        }
    }
    END {
        if (count > 0 && up > 0) {
            avg = sum / up;
            uptime = (up / count) * 100;
            printf "*%s*\nAvg: %.2f ms\nMin: %.2f ms\nMax: %.2f ms\nUptime: %.2f%%\n", label, avg, min, max, uptime;
        } else {
            printf "*%s*\nNo data available.\n", label;
        }
    }' "$LOGFILE"
}



# Buat pesan laporan
MSG=$(cat <<EOF
📡 *Monitoring Report* (bing.com)

$(get_stats $((2*86400)) "Last 2 Days Response Time")

$(get_stats $((1*86400)) "Uptime 24 Jam")

$(get_stats $((7*86400)) "Uptime 7 Hari")

$(get_stats $((30*86400)) "Uptime 30 Hari")

$(get_stats $((90*86400)) "Uptime 90 Hari")
EOF
)

# Kirim ke Telegram
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  --data-urlencode "text=$MSG" \
  -d "parse_mode=Markdown"
