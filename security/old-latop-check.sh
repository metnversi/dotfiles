#!/bin/env bash

# Define Colors
NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'

if grep -iq 'hypervisor' /proc/cpuinfo; then
    echo -e "ERROR: This script is intended for bare-metal hardware, but a VM was detected."
    exit 127
fi

PRODUCT=$(sudo dmidecode -s system-product-name 2>/dev/null || echo "Unknown Product")
MANUFACTURER=$(sudo dmidecode -s system-manufacturer 2>/dev/null || echo "Unknown Vendor")

echo -e "--- Hardware Audit ---"
echo -e "--- Hostname: $(hostname) ---"
echo -e "--- Model: $MANUFACTURER $PRODUCT ---\n"

echo -e "${BLUE}[+] Firmware/BIOS Details:${NC}"
sudo dmidecode -t bios | grep -E "Vendor:|Version:|Release Date:" | sed 's/^[ \t]*//;s/^/    /'

echo -e "\n${BLUE}[+] CPU & Topology Details:${NC}"
MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
SOCKETS=$(lscpu | grep "Socket(s):" | awk '{print $2}')
CORES_PER_SOCKET=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
THREADS_PER_CORE=$(lscpu | grep "Thread(s) per core:" | awk '{print $4}')
TOTAL_THREADS=$(nproc)

echo "    Model: $MODEL"
echo "    Topology: $SOCKETS Socket(s) | $CORES_PER_SOCKET Cores/Socket | $THREADS_PER_CORE Thread(s)/Core (Total $TOTAL_THREADS)"
NUMA_NODES=$(lscpu | grep "NUMA node(s):" | awk '{print $3}')
if [[ "$NUMA_NODES" -gt 1 ]]; then
    for i in $(seq 0 $((NUMA_NODES - 1))); do
        NODE_CPUS=$(cat /sys/devices/system/node/node$i/cpulist 2>/dev/null)
        NODE_MEM=$(numactl -H 2>/dev/null | grep "node $i size" | awk '{print $4 " " $5}')
        echo "      -> Node $i: CPUs [$NODE_CPUS] | Memory: ${NODE_MEM:-"Check numactl"}"
    done
else
    echo -e "    NUMA: [${GREEN}SINGLE-NODE${NC}] Unified memory access"
fi


if grep -Eiq 'vmx|svm' /proc/cpuinfo; then
    VIRT_TYPE=$(grep -Ei 'vmx|svm' /proc/cpuinfo | head -n1 | grep -qi vmx && echo "Intel VT-x" || echo "AMD-V")
    echo -e "    Virtualization: [${GREEN}ENABLED${NC}] $VIRT_TYPE"
fi

echo -e "\n${BLUE}[+] Active CPU Vulnerabilities & Mitigations:${NC}"
if [ -d /sys/devices/system/cpu/vulnerabilities/ ]; then
    for vuln_path in /sys/devices/system/cpu/vulnerabilities/*; do
        status=$(cat "$vuln_path")
        if [[ "$status" != "Not affected" ]]; then
            vuln_raw=$(basename "$vuln_path")
            vuln_pretty=$(echo "$vuln_raw" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
            
            # Color status only
            V_COL=$YELLOW
            [[ "$status" == *"Vulnerable"* ]] && V_COL=$RED
            printf "    %-25s : ${V_COL}%s${NC}\n" "$vuln_pretty" "$status"
        fi
    done
fi

echo -e "\n${BLUE}[+] PCI Lane Speed (NVMe Storage):${NC}"
NVME_DEVS=$(lspci | grep -i nvme | awk '{print $1}')
if [ -n "$NVME_DEVS" ]; then
    for addr in $NVME_DEVS; do
        MODEL_NAME=$(lspci -s "$addr" | cut -d: -f3-)
        echo "    - Device [$addr]:$MODEL_NAME"
        sudo lspci -vv -s "$addr" | grep -E "LnkCap:|LnkSta:" | \
            sed "s/LnkCap/  [Max] /; s/LnkSta/  [Curr]/" | sed 's/^[ \t]*/    /'
    done
fi

echo -e "\n${BLUE}[+] Disk Health & Capacity:${NC}"
TMP_SMART="/tmp/smart_audit.txt"
lsblk -dno NAME,MODEL,SIZE,TRAN | while read -r NAME MODEL SIZE TRAN; do
    [[ "$NAME" =~ loop|zram ]] && continue
    dev="/dev/$NAME"
    echo "  - [$NAME] $MODEL ($SIZE)"
    
    sudo smartctl -a "$dev" > "$TMP_SMART" 2>/dev/null
    
    # Check if NVMe or SATA
    if [[ "$NAME" =~ "nvme" || "$TRAN" == "nvme" ]]; then
        # NVMe Specific Output
        grep -iE "Critical Warning:|Percentage Used:|Temperature:|Data Units Written:" "$TMP_SMART" | sed 's/^/      /'
        HOURS=$(grep -i "Power On Hours:" "$TMP_SMART" | awk '{print $NF}' | tr -d ',')
    else
        # SATA Specific Output (Mapping IDs to readable names)
        # Check overall health first
        HEALTH=$(sudo smartctl -H "$dev" | grep "test result" | awk '{print $NF}')
        echo -e "      Overall Health: ${GREEN}${HEALTH:-UNKNOWN}${NC}"
        
        # Get Temperature and Reallocated Sectors for SATA
        # ID 194 is Temp, ID 5 is Reallocated Sectors
        awk '/194/ {print "      Temperature:         " $10 " Celsius"} 
             /  5 / {print "      Reallocated Sectors: " $10}' "$TMP_SMART"
        
        HOURS=$(awk '/Power_On_Hours/ {print $10}' "$TMP_SMART")
        [[ -z "$HOURS" ]] && HOURS=$(grep -i "Power_On_Hours" "$TMP_SMART" | awk '{print $4}')
    fi

    # Consistent Power On Time formatting
    if [[ -n "$HOURS" && "$HOURS" =~ ^[0-9]+$ ]]; then
        YEARS=$(( HOURS / 8760 ))
        DAYS=$(( (HOURS % 8760) / 24 ))
        if [ "$YEARS" -gt 0 ]; then
            echo "      Power On Time: $HOURS hours (~${YEARS}y ${DAYS}d)"
        else
            echo "      Power On Time: $HOURS hours (~${DAYS}d)"
        fi
    fi
    echo "----------------------------------------------------"
done
rm -f "$TMP_SMART"


echo -e "${BLUE}[+] Networking & Connectivity:${NC}"
lspci -nn | grep -E 'Ethernet|Network' | while read -r line; do
    addr=$(echo "$line" | awk '{print $1}')
    echo "  - $line"
    if sudo lspci -vv -s "$addr" | grep -q "Single Root I/O Virtualization"; then
        echo -e "    [${GREEN}CONFIRMED${NC}] SR-IOV Support Available"
    else
        echo -e "    [${RED}NONE${NC}] No SR-IOV detected."
    fi
done
ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo -e "  - Internet: ${GREEN}CONNECTED${NC}" || echo -e "  - Internet: ${RED}DISCONNECTED${NC}"

echo -e "\n${BLUE}[+] PCI Link & Lane Audit:${NC}"
DEVS=$(lspci -n | grep -E "0300|0108|0200" | awk '{print $1}')
for addr in $DEVS; do
    NAME=$(lspci -s "$addr" | cut -d: -f3- | sed 's/^[ \t]*//')
    echo "  - [$addr] $NAME"
    LNK_INFO=$(sudo lspci -vv -s "$addr" 2>/dev/null | grep -E "LnkCap:|LnkSta:")
    if [ -n "$LNK_INFO" ]; then
        CAP_SPEED=$(echo "$LNK_INFO" | grep "LnkCap:" | awk -F'Speed ' '{print $2}' | awk '{print $1}' | tr -d ',')
        CAP_WIDTH=$(echo "$LNK_INFO" | grep "LnkCap:" | awk -F'Width ' '{print $2}' | awk '{print $1}' | tr -d ',')
        STA_SPEED=$(echo "$LNK_INFO" | grep "LnkSta:" | awk -F'Speed ' '{print $2}' | awk '{print $1}' | tr -d ',')
        STA_WIDTH=$(echo "$LNK_INFO" | grep "LnkSta:" | awk -F'Width ' '{print $2}' | awk '{print $1}' | tr -d ',')
        
        if [[ "$CAP_WIDTH" != "$STA_WIDTH" || "$CAP_SPEED" != "$STA_SPEED" ]]; then
            echo -e "    [Current] Speed: $STA_SPEED | Width: $STA_WIDTH (${YELLOW}Downshifted${NC})"
        else
            echo -e "    [Current] Speed: $STA_SPEED | Width: $STA_WIDTH (${GREEN}Max Speed${NC})"
        fi
    fi
done

echo -e "\n${BLUE}[+] RAM Memory Details:${NC}"
sudo dmidecode -t memory | awk '
    /Size: [0-9]/ { s=$2 " " $3 }
    /Type: DDR/ { t=$2 }
    /Configured Memory Speed: [0-9]/ { 
        if (s != "No Module") {
            print "    - Slot " ++i ": " s " | " t " @ " $4 " " $5
        }
    }
'

echo -e "\n${BLUE}${BOLD}--- Audit Complete ---${NC}"
