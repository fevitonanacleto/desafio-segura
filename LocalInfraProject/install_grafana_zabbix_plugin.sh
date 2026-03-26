#!/bin/bash
# ========================================================
# Instalador de Integração: Grafana + Zabbix Plugin
# ========================================================
set -e

echo "[+] 1. Instalando o Plugin Oficial do Zabbix (Alexander Zobnin) no Grafana..."
grafana-cli plugins install alexanderzobnin-zabbix-app

echo "[+] 2. Reiniciando o Servidor do Grafana para aplicar o novo módulo..."
systemctl restart grafana-server

echo "========================================================"
echo "[+] INTEGRAÇÃO PRONTA NO BACKEND!"
echo "[+] Próximos passos na Interface Web do Grafana:"
echo "    1. Acesse: http://SEU_IP_PUBLICO:3000 (admin/admin)"
echo "    2. Vá em: Administration -> Plugins -> Procure por 'Zabbix' e habilite."
echo "    3. Vá em: Connections -> Data Sources -> Add data source -> Zabbix"
echo "    4. URL da API: http://localhost/zabbix/api_jsonrpc.php"
echo "    5. User/Pass: Admin / zabbix (ou a senha que você configurou no painel do Zabbix)"
echo "========================================================"
