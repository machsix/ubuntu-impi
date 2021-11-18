#!/bin/bash
rm /etc/resolv.conf
touch /etc/wsl.conf
cat >> /etc/wsl.conf <<EOF
[network]
generateResolvConf = false
EOF
echo "nameserver 172.28.192.1" > /etc/resolv.conf
echo "Now: 1) Run 'wsl --shutdown' in powershell 2) Reopen your wsl"