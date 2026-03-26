# Projeto Global Support Engineer: Monitoramento On-Premises & AWS Cloud

Bem-vindo ao repositório do Case Técnico para Global Support Engineer.

Este repositório consolida uma topologia dupla de infraestrutura para hospedar o núcleo de monitoramento **Zabbix / Grafana**, desenvolvido estrategicamente sob a óptica de Zero-Trust, Automação Declarativa e Hardening de Sistema Operacional.

## 🚀 Arquitetura do Projeto

O projeto foi segmentado em duas entregas centrais para englobar as restrições físicas On-Premises e a escalabilidade elástica da Nuvem AWS:

### 1. Ambiente Local Restrito (Vagrant LVM)
Localizado na pasta `/LocalInfraProject`. Atende *literalmente* aos requisitos físicos de virtualização On-Premises propostos pelo desafio:
- **Infra-as-Code Pura:** Orquestração autônoma do VirtualBox via `Vagrantfile`.
- **Hardware Extrutural:** 2 vCPUs e 4GB de RAM.
- **Armazenamento Profissional:** Provisionamento shell via *LVM2* em disco secundário de 20GB formatado e montado nativamente no *fstab*.
- **Observabilidade Agent-Side:** Zabbix Agent compilado autônomo com envio de métricas locais para a gerência principal.

### 2. O Espelho Escalável Nuvem (AWS Terraform IaC)
Localizado na pasta `/AWSInfraProject`. Uma expansão voluntária (*Over-Deliver*) focada na cultura SecOps de nuvem:
- **Isolamento de Redes:** Arquitetura limpa de VPC (Roteamento Dinâmico, Subnets Dedicadas e Internet Gateways).
- **FinOps Estrito:** Controle do limite exato do AWS Free Tier de EBS (15 GB GP3 por Host) e gerenciamento de Estados de Instância via Terraform para supressão de faturamento.
- **Zero-Trust Network:** Erradicação total do serviço *OpenSSH-Server* das imagens EC2. O acesso ao shell é puramente confiado ao **AWS Systems Manager (SSM)** via Session Manager sob Instance Profiles Least-Privilege, garantindo fechamento total de Firewalls e Auditoria de Acesso unificada em nuvem sem o uso das vulneráveis chaves `.pem`.
- **Hardening Avançado:** Scripting em Boot (User_Data) implantando mitigadores agressivos de Kernel Sysctl (*Syn Flood, IP Spoofing, redirects*) e sincronização NTP vital via *Chrony*.
- **Zabbix + Grafana Hub:** Centralização relacional dos dados com MariaDB e Data Visualization integrada via Dashboards do Grafana na porta segura administrativa.

---

## 🗺️ Guia de Auditoria de Código (Para Avaliadores)

A fim de embasar tecnicamente todas as decisões arquiteturais descritas no Relatório Executivo, a banca avaliadora pode inspecionar diretamente as estratégias nos arquivos-chave do repositório:

- **1. Zero Trust & Hardening OS** (`/AWSInfraProject/user_data.sh`): Onde a automação Bash erradica agressivamente os serviços do `openssh-server` e injeta proteções severas de Kernel no `sysctl` contra ataques SYN Flood/IP Spoofing.
- **2. Política de Redes Segurança / Security Groups** (`/AWSInfraProject/security.tf` e `/AWSInfraProject/iam_ssm.tf`): Onde a conexão da Porta 22 (SSH) é bloqueada massivamente e substitui-se o canal de administração por AWS SSM sob perfis Instance Profile.
- **3. FinOps & Provisionamento Puro** (`/AWSInfraProject/compute.tf`): Define a gestão de discos limitados a 15GB e os comandos restritos do Free Tier declarativos.
- **4. On-Premises & LVM Engine** (`/LocalInfraProject/Vagrantfile`): Na linha 40 deste arquivo encontra-se a automação Ruby/Bash que provisiona a máquina física host com 2 vCPUs e formata logicamente o volume inteiro em LVM `vg_data` usando zero cliques de infra.
- **5. O Relatório Visual de Impacto** (`/docs/apresentacao/index.html`): Portal front-end provendo as capturas de tela, painéis analíticos do Grafana e diagramas provando o Desafio sendo cumprido de ponta a ponta.

---

## 🛠 Bibliotecas e Ferramentas Empregadas
- **HashiCorp Terraform:** Orquestração de Cloud AWS.
- **HashiCorp Vagrant:** Virtualização de Computação Local.
- **LVM2 & Bash Scripting:** Hardening OS e Gerenciamento de Armazenamento Dinâmico.
- **AWS Cloud (VPC, EC2, SSM, IAM, Security Groups):** Elasticidade e Governança Lógica.
- **Zabbix 7.0 & Grafana:** Engine de Monitoramento e Observabilidade Analítica.
- **HTML/CSS/PrismJS (Apresentação Interna):** Documentação interativa em front-end nativo entregue ao Time de People.

---
*Este repósitório constitui o pacote de evidências do Laboratório Prático para Avaliação de Global Support Engineer Sênior.*
