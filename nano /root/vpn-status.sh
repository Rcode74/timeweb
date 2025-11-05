#!/bin/bash
echo "====== Amnezia VPN Monitor ======"
echo "Время: $(date)"
echo ""

docker exec amnezia-avg wg show | while read line; do
    if [[ $line == peer:* ]]; then
        peer=$(echo $line | cut -d' ' -f2)
        echo "---"
        echo "Peer: ${peer:0:8}..."
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
        echo "Трафик: $transfer"
    fi
done

echo ""
echo "📊 Общая статистика трафика (vnstat):"
vnstat -q
