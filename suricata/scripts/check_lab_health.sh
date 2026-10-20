#!/bin/bash

LOG_FILE="/var/log/lab_health.log"
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

echo "[${CURRENT_TIME}] Starting Automated Lab Health Check..." >> $LOG_FILE

# 1. Check Suricata Service Status
if systemctl is-active --quiet suricata; then
    echo "  [OK] Suricata Service is running." >> $LOG_FILE
else
    echo "  [CRITICAL] Suricata Service is DOWN!" >> $LOG_FILE
fi

# 2. Check EveBox Local Agent Status
if systemctl is-active --quiet evebox-agent-local.service; then
    echo "  [OK] EveBox Local Agent is running." >> $LOG_FILE
else
    echo "  [CRITICAL] EveBox Local Agent is DOWN!" >> $LOG_FILE
fi

# 3. Check if eve.json is actively being written to (modified in last 5 minutes)
if [ -f /var/log/suricata/eve.json ]; then
    LAST_MOD=$(stat -c %Y /var/log/suricata/eve.json)
    NOW=$(date +%s)
    DIFF=$((NOW - LAST_MOD))
    
    if [ $DIFF -le 300 ]; then
        echo "  [OK] eve.json is actively updating." >> $LOG_FILE
    else
        echo "  [WARN] eve.json has not updated in the last 5 minutes (No traffic or engine freeze)." >> $LOG_FILE
    fi
else
    echo "  [CRITICAL] eve.json log file does not exist!" >> $LOG_FILE
fi

echo "--------------------------------------------------" >> $LOG_FILE
