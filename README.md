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

## 🛠 Bibliotecas e Ferramentas Empregadas
- **HashiCorp Terraform:** Orquestração de Cloud AWS.
- **HashiCorp Vagrant:** Virtualização de Computação Local.
- **LVM2 & Bash Scripting:** Hardening OS e Gerenciamento de Armazenamento Dinâmico.
- **AWS Cloud (VPC, EC2, SSM, IAM, Security Groups):** Elasticidade e Governança Lógica.
- **Zabbix 7.0 & Grafana:** Engine de Monitoramento e Observabilidade Analítica.
- **HTML/CSS/PrismJS (Apresentação Interna):** Documentação interativa em front-end nativo entregue ao Time de People.

---
*Este repósitório constitui o pacote de evidências do Laboratório Prático para Avaliação de Global Support Engineer Sênior.*
