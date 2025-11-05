bash
#!/bin/bash
LOG_FILE="/root/vpn-monthly.log"
CURRENT_MONTH=$(date "+%Y-%m")

echo "====== Amnezia VPN Детальная Статистика ======"
echo "Текущий месяц: $CURRENT_MONTH"
echo "Время: $(date)"
echo ""

# Получаем данные от WireGuard
docker exec amnezia-avg wg show | while read line; do
    if [[ $line == peer:* ]]; then
        peer=$(echo $line | cut -d' ' -f2)
        echo "---"
        echo "Устройство: ${peer:0:8}..."
    elif [[ $line == *"allowed ips"* ]]; then
        ip=$(echo $line | cut -d' ' -f3)
        echo "Внутренний IP: $ip"
    elif [[ $line == *"endpoint"* ]]; then
        endpoint=$(echo $line | cut -d' ' -f2 | cut -d':' -f1)
        echo "Внешний IP: $endpoint"
    elif [[ $line == *"latest handshake"* ]]; then
        handshake=$(echo $line | cut -d' ' -f3-)
        echo "Активен: $handshake назад"
    elif [[ $line == *"transfer"* ]]; then
        transfer=$(echo $line | cut -d' ' -f2-)
        echo "Общий трафик: $transfer"
        
        # Сохраняем в лог для месячной статистики
        echo "$(date): $ip - $transfer" >> $LOG_FILE
    fi
done

echo ""
echo "📈 МЕСЯЧНАЯ СТАТИСТИКА:"
echo "======================"

# Показываем трафик по месяцам из vnstat
vnstat -m

echo ""
echo "📱 Трафик по устройствам за текущий месяц:"
echo "=========================================="

# Анализируем наш лог за текущий месяц
if [ -f "$LOG_FILE" ]; then
    grep "$CURRENT_MONTH" $LOG_FILE | awk '
    {
        ip = $4;
        received = $6;
        sent = $9;
        traffic[ip]["received"] += received;
        traffic[ip]["sent"] += sent;
    }
    END {
        for (ip in traffic) {
            printf "IP %s: 📥 %.2f MiB 📤 %.2f MiB\n", 
                ip, 
                traffic[ip]["received"]/1024/1024, 
                traffic[ip]["sent"]/1024/1024;
        }
    }'
else
    echo "Лог файл не найден. Статистика появится после первого запуска."
fi
