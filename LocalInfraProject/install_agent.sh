#!/bin/bash
# ========================================================
# Instalador Rápido: Zabbix Agent (Debian 12)
# ========================================================
set -e

wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
dpkg -i zabbix-release_7.0-2+debian12_all.deb
apt-get update -y
apt-get install -y zabbix-agent

# Amarração com nosso Zabbix Server IaC Sênior (10.0.1.20)
sed -i 's/^Server=127.0.0.1/Server=10.0.1.20/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=127.0.0.1/ServerActive=10.0.1.20/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^Hostname=Zabbix server/Hostname=srv-debian-monitorado/g' /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent
systemctl enable zabbix-agent
echo "[+] Agent Instalado! Apontando com sucesso para -> 10.0.1.20"
