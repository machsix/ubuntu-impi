#!/bin/bash
LLVM_VERSION=${1:-$LLVM_VERSION}
mkdir -p /usr/local/bin/llvm
for i in /usr/bin/*-${LLVM_VERSION}; do
  exe_name=$(basename $i)
  ln -sf ${i} /usr/local/bin/llvm/${exe_name%-${LLVM_VERSION}};
done
cat > /etc/profile.d/zzz_04-llvm.sh <<EOF
#!/bin/bash
export PATH=/usr/local/bin/llvm:\${PATH}
EOF
chmod 644 /etc/profile.d/zzz_04-llvm.sh