#!/bin/bash
set -e

echo "[+] Hardening EC2 (SSM only)"

# ==============================
# 1. SSM Agent
# ==============================
mkdir -p /tmp/ssm && cd /tmp/ssm
wget -q https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb

dpkg -i amazon-ssm-agent.deb || apt-get install -f -y

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

# ==============================
# 2. Timezone + updates
# ==============================
timedatectl set-timezone America/Sao_Paulo

apt-get update -y
apt-get upgrade -y

apt-get install -y unattended-upgrades chrony

dpkg-reconfigure -f noninteractive unattended-upgrades

# ==============================
# 3. NTP
# ==============================
systemctl enable chrony
systemctl restart chrony

# ==============================
# 4. Hardening Kernel
# ==============================
cat <<EOF > /etc/sysctl.d/99-hardening.conf
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0

net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0

net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0

net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1

net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.log_martians=1

# IPv6 off
net.ipv6.conf.all.disable_ipv6=1
EOF

sysctl --system

# ==============================
# 5. SSH OFF (total)
# ==============================
systemctl stop ssh || true
systemctl disable ssh || true

# remove binário pra garantir
apt-get purge -y openssh-server

# ==============================
# 6. Remover serviços desnecessários
# ==============================
apt-get purge -y \
  rsh-client \
  ftp \
  rpcbind

# ==============================
# 7. Permissões críticas
# ==============================
chmod 700 /root

# ==============================
# 8. Limpeza
# ==============================
apt-get autoremove -y
apt-get autoclean

echo "[+] Hardening finalizado (SSM only ativo)"