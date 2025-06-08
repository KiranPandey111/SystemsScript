#!/usr/bin/env bash
# system_report.sh – basic system info report

echo   

# Identity
HOST=$(hostname)
ME=$(whoami)
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# OS & uptime
. /etc/os-release
OS="$NAME $VERSION_ID"
UP=$(uptime -p | sed 's/^up //')

# CPU
CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
RAM=$(free -h | awk '/Mem:/ {print $2}')

# Disks
DISKS=$(lsblk -dn -o MODEL,SIZE | awk '{print $1" "$2}' | paste -sd ', ')

# Video
VIDEO=$(lspci | grep -E 'VGA|3D' | cut -d' ' -f5- | paste -sd ', ')

# Network
IF=$(ip route | awk '/default/ {print $5; exit}')
IP=$(ip -4 addr show $IF | awk '/inet/ {print $2}' | cut -d/ -f1)
GW=$(ip route | awk '/default/ {print $3; exit}')
DNS=$(awk '/nameserver/ {print $2}' /etc/resolv.conf | paste -sd ', ')

# Status
USERS=$(who | awk '{print $1}' | sort -u | paste -sd ',')
DS=$(df -h --output=target,avail | tail -n +2 | paste -sd ', ')
PC=$(ps -e | wc -l)
LOAD=$(awk '{printf "%s, %s, %s\n",$1,$2,$3}' /proc/loadavg)
PORTS=$(ss -tuln | awk 'NR>1{split($5,a,/:/);print a[length(a)]}' | sort -u | paste -sd ', ')
UFW=$(ufw status | head -1)

# Print report
cat <<EOF


System Information
OS: $OS
Uptime: $UP
CPU: $CPU
RAM: $RAM
Disk(s): $DISKS
Video: $VIDEO
Host Address: $IP
Gateway IP: $GW
DNS Server: $DNS

System Status

Users Logged In: $USERS
Disk Space: $DS
Process Count: $PC
Load Averages: $LOAD
Listening Network Ports: $PORTS
UFW Status: $UFW

EOF

echo  

