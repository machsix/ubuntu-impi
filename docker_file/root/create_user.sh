#!/bin/bash
read -p 'Username: ' username
read -p 'Password: ' password
useradd -m -p $(openssl passwd -1 "$password") ${username}
usermod -s /bin/bash -a -G sudo ${username}
echo -e "[user]\ndefault=${username}" >> /etc/wsl.conf
echo "Now: 1) Run 'wsl --shutdown' in powershell 2) Reopen your wsl"