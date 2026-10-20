#!/bin/bash

EVE_FILE="/var/log/suricata/eve.json"

if [ ! -f "$EVE_FILE" ]; then
    echo "Error: $EVE_FILE not found."
    exit 1
fi

echo "=================================================="
echo "      SURICATA LIVE STATS MONITORING TASK"
echo "=================================================="
echo "Press [CTRL+C] to stop tracking."
echo "--------------------------------------------------"

# Tail the eve.json file and look exclusively for "stats" events
tail -f "$EVE_FILE" | while read -r line; do
    # Verify the line is a stats event type
    EVENT_TYPE=$(echo "$line" | jq -r '.event_type')
    
    if [ "$EVENT_TYPE" == "stats" ]; then
        TIMESTAMP=$(echo "$line" | jq -r '.timestamp' | cut -d'T' -f2 | cut -d'-' -f1)
        PACKETS=$(echo "$line" | jq -r '.stats.decoder.pkts')
        DROPS=$(echo "$line" | jq -r '.stats.capture.kernel_drops')
        INVALID=$(echo "$line" | jq -r '.stats.decoder.invalid')
        ALERTS=$(echo "$line" | jq -r '.stats.detect.alert')
        
        clear
        echo "=================================================="
        echo "      SURICATA LIVE PERFORMANCE METRICS"
        echo "=================================================="
        echo " Last Update Check : $TIMESTAMP"
        echo "--------------------------------------------------"
        echo " Total Packets Processed : $PACKETS"
        echo " Kernel Packets Dropped  : $DROPS"
        echo " Invalid Decoder Packets : $INVALID"
        echo " Total Alerts Triggered  : $ALERTS"
        echo "=================================================="
    fi
done
