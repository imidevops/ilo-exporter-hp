#!/bin/bash

# Check if host is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <host>"
    exit 1
fi

HOST="$1"
COMMUNITY="public"  # Adjust as needed
METRICS_FILE="/var/lib/prometheus/node-exporter/snmp_metrics.prom"
TEMP_FILE="/tmp/snmp_metrics_$$.prom"

# OID definitions
OID_DISK_HEALTH="1.3.6.1.4.1.232.3.2.5.1.1.6"      # Physical Storage (health)
OID_DISK_TEMP="1.3.6.1.4.1.232.3.2.5.1.1.70"      # Temperature
OID_DISK_SMART="1.3.6.1.4.1.232.3.2.5.1.1.57"     # Smart Storage
OID_POWER_SUPPLY="1.3.6.1.4.1.232.6.2.9.3.1.4"    # Power Supply
OID_RAID_STATUS="1.3.6.1.4.1.232.3.2.3.1.1.4.0.1"     # Logical Drive (RAID)

# Ensure output directory exists
mkdir -p "$(dirname "$METRICS_FILE")"

# Function to write metrics to temp file
write_metric() {
    local metric_name="$1"
    local help_text="$2"
    local ip="$3"
    local slot="$4"
    local value="$5"

    echo "# HELP $metric_name $help_text" >> "$TEMP_FILE"
    echo "# TYPE $metric_name gauge" >> "$TEMP_FILE"
    if [ -n "$slot" ]; then
        echo "$metric_name{ip=\"$ip\",slot=\"$slot\"} $value" >> "$TEMP_FILE"
    else
        echo "$metric_name{ip=\"$ip\"} $value" >> "$TEMP_FILE"
    fi
}

# Clear temp file
> "$TEMP_FILE"

# Process table-based OIDs with snmpwalk
for oid in "$OID_DISK_HEALTH" "$OID_DISK_TEMP" "$OID_DISK_SMART" "$OID_POWER_SUPPLY"; do
    case "$oid" in
        "$OID_DISK_HEALTH")
            metric_name="disk_health"
            help_text="Physical Disk Health Status"
            ;;
        "$OID_DISK_TEMP")
            metric_name="disk_temperature"
            help_text="Disk Temperature"
            ;;
        "$OID_DISK_SMART")
            metric_name="disk_health_smart"
            help_text="Smart Physical Storage Value"
            ;;
        "$OID_POWER_SUPPLY")
            metric_name="power_supply"
            help_text="Power Supply Status"
            ;;
    esac
        i=1
    # Walk the OID and parse results
    snmpwalk -v2c -c "$COMMUNITY" "$HOST" "$oid" 2>/dev/null | while read -r line; do
        # Extract OID index and value (e.g., .1.3.6.1.4.1.232.3.2.5.1.1.6.1 = INTEGER: 3)
        index=$(echo "$line" | grep -oE '\.[0-9]+$')
        value=$(echo "$line" | awk '{print $NF}')

        # Skip if no value
        [ -z "$value" ] && continue
        # Convert index to slot name (simplified)
        slot_idx=$(echo "$index" | cut -d'.' -f2)
        slot="Slot $i"

        ((i++))
        # Handle non-numeric values
        if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "Non-numeric value for $oid$index: $value" >&2
            value=0
        fi

        write_metric "$metric_name" "$help_text" "$HOST" "$slot" "$value"
    done
done

# Process single-value OID with snmpget
raid_value=$(snmpget -v2c -c "$COMMUNITY" "$HOST" "$OID_RAID_STATUS" 2>/dev/null | awk '{print $NF}')
if [ -n "$raid_value" ]; then
    if ! [[ "$raid_value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Non-numeric value for $OID_RAID_STATUS: $raid_value" >&2
        raid_value=0
    fi
    write_metric "raid_status" "RAID Status" "$HOST" "" "$raid_value"
fi

# Atomically move temp file to metrics file
mv "$TEMP_FILE" "$METRICS_FILE"
cat $METRICS_FILE

