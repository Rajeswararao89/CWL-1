#!/bin/bash
# monitor.sh - logs CPU, memory and other stats for a running container
# runs every minute via cron, writes to /opt/container-monitor/logs/

CONTAINER_NAME="devops-container"
LOG_DIR="/opt/container-monitor/logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m-%d).log"
CSV_FILE="$LOG_DIR/monitor_$(date +%Y-%m-%d).csv"

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# bail out early if container isn't running - no point collecting stats
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)

if [ "$CONTAINER_STATUS" != "running" ]; then
    echo "[$TIMESTAMP] WARNING: $CONTAINER_NAME is not running (status: ${CONTAINER_STATUS:-not found})" >> "$LOG_FILE"
    exit 1
fi

# grab a single snapshot - pipe-separated so we can split it cleanly
STATS=$(docker stats "$CONTAINER_NAME" --no-stream --format \
    "{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}|{{.NetIO}}|{{.BlockIO}}|{{.PIDs}}")

CPU=$(echo "$STATS"     | cut -d'|' -f1)
MEM_USAGE=$(echo "$STATS" | cut -d'|' -f2)
MEM_PERC=$(echo "$STATS"  | cut -d'|' -f3)
NET_IO=$(echo "$STATS"    | cut -d'|' -f4)
BLOCK_IO=$(echo "$STATS"  | cut -d'|' -f5)
PIDS=$(echo "$STATS"      | cut -d'|' -f6)

# human-readable log block
{
    echo "-----------------------------------------------------"
    echo "  TIMESTAMP   : $TIMESTAMP"
    echo "  CONTAINER   : $CONTAINER_NAME"
    echo "  CPU         : $CPU"
    echo "  MEMORY      : $MEM_USAGE ($MEM_PERC)"
    echo "  NETWORK I/O : $NET_IO"
    echo "  BLOCK  I/O  : $BLOCK_IO"
    echo "  PROCESSES   : $PIDS PIDs"
    echo "-----------------------------------------------------"
    echo ""
} >> "$LOG_FILE"

# csv line - useful if you ever want to graph this or import it somewhere
if [ ! -f "$CSV_FILE" ]; then
    echo "timestamp,container,cpu,mem_usage,mem_percent,net_io,block_io,pids" >> "$CSV_FILE"
fi

echo "$TIMESTAMP,$CONTAINER_NAME,$CPU,$MEM_USAGE,$MEM_PERC,$NET_IO,$BLOCK_IO,$PIDS" >> "$CSV_FILE"
