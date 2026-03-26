#!/bin/bash
# ========================================================
# Instalador Sênior Automático: Zabbix 7.0 + Grafana
# OS: Debian 12 (Bookworm)
# ========================================================
set -e

echo "[+] 1. Instalando Repositórios Oficiais..."
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
dpkg -i zabbix-release_7.0-2+debian12_all.deb
apt-get update -y

echo "[+] 1.5 Gerando Locale UTF-8 para o Frontend do Zabbix..."
apt-get install -y locales
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

echo "[+] 2. Instalando Core (Zabbix Server, Frontend, DB)..."
apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

echo "[+] 3. Configurando Banco de Dados MariaDB..."
systemctl start mariadb
systemctl enable mariadb

mysql -uroot -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;" || true
mysql -uroot -e "create user zabbix@localhost identified by 'zabbix';" || true
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -uroot -e "set global log_bin_trust_function_creators = 1;"

echo "[+] 4. Populando o Banco de Dados (Pode demorar uns 30s)..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -pzabbix zabbix

mysql -uroot -e "set global log_bin_trust_function_creators = 0;"

echo "[+] 5. Ajustando Senha do Banco no Zabbix Server..."
sed -i 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf

echo "[+] 6. Iniciando Serviços Zabbix..."
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo "[+] 7. Instalando Grafana Oficial..."
apt-get install -y apt-transport-https software-properties-common wget
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt-get update -y
apt-get install -y grafana
systemctl start grafana-server
systemctl enable grafana-server

echo "========================================================"
echo "[+] DEPLOY DA CAMADA APLICAÇÃO FINALIZADO! "
echo "[+] URL Zabbix:  http://EU_IP_PUBLICO/zabbix"
echo "[+] URL Grafana: http://MEU_IP_PUBLICO:3000"
echo "========================================================"
