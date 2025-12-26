#!/bin/sh

TARGET_IP=${TARGET_IP}
TARGET_MAC=${TARGET_MAC}
CHECK_INTERVAL=${CHECK_INTERVAL:-300}

echo "--- WOL Monitor Started ---"
echo "Target IP: $TARGET_IP"
echo "Target MAC: $TARGET_MAC"
echo "Check Interval: $CHECK_INTERVAL seconds"
echo "---------------------------"

# Infinite loop to keep container alive
while true; do
    # Ping target with 1 packet, 2 second timeout
    if ping -c 1 -W 2 "$TARGET_IP" > /dev/null 2>&1; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Target is UP. Sleeping..."
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Target is DOWN. Sending Magic Packet..."
        wakeonlan -p 9 "$TARGET_MAC"
    fi
    
    # Wait before next check
    sleep "$CHECK_INTERVAL"
done