#!/bin/bash
mkdir -p /usr/lib/binfmt.d
cat > /usr/lib/binfmt.d/WSLInterop.conf  <<EOF
:WSLInterop:M::MZ::/init:PF
EOF

cat >> /etc/wsl.conf <<EOF
[boot]
systemd=true
EOF