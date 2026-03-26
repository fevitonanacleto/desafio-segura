# Projeto Segura: Arquitetura de Monitoramento Sênior na AWS

Este documento consolida a arquitetura em nuvem provisionada para suportar a infraestrutura de monitoramento com Zabbix e Grafana. O projeto foi formatado utilizando **Infraestrutura como Código (Terraform)** e ancorado em metodologias corporativas de **DevSecOps**, **Zero Trust** e de gerenciamento de faturamento da nuvem **(FinOps)**.

## 1. Engenharia de Computação & Nuvem (AWS)

Para o ambiente de observabilidade transparente, projetou-se uma sub-rede lógica autônoma onde o tráfego externo é triado em diversas camadas lógicas antes de atingir as VMs:

- **Rede Virtual (VPC)**: Malha em `10.0.1.0/24` ligada a um *Internet Gateway*, permitindo que os pacotes fluam por rotas autorizadas.
- **Tamanho Limite (FinOps)**: Os hospedeiros rodam a base minimalista do *Debian 12* ancorados nos recursos t3.micro.
- **Gestão de Custos Ocultos (EBS)**: Cada servidor detém apenas um volume de bloco (gp3) cortado com limite rígido de 15 GB de retenção, totalizando 30 GB (limite exato absoluto do plano anual do AWS Free Tier). Por regra na AWS e script IaC, ao se desarmar uma infraestrutura (O *destroy*), o custo fantasma das áreas de disco também são rompidos e destruídos por proteção orgânica (`delete_on_termination`).

## 2. DevSecOps & Restrições Seguras (Zero Trust)

A segurança em ambientes de Nuvem Sênior dita que não ocorram acessos fáceis e permissivos sobre as malhas elásticas de instâncias. Isso foi arquitetado por meio de dois focos da segurança base AWS:

> [!IMPORTANT]
> **A Morte do Protocolo SSH Local (Porta 22) no Security Group**
> Para prover Zero Trust, derrubaram-se as portos inseguros web/SSH tradicionais abertos para toda Internet (`0.0.0.0/0`).
> A administração CLI de cada Host agora se dá estritamente via túneis mutáveis usando sessões web criptografadas pelo **AWS Systems Manager (SSM)** Session Manager e IAM Instance Profiles.

- **Políticas Restritivas:** As regras criadas customizadamente em JSON com privilégio mínimo impedem a aplicação não qualificada e sem propósito de "AmazonEC2FullAccess". Cada requisição (*Read Describe*, ou uso de disco) é testada e aprovada perante o código.
- **Autoridade Web Restrita:** Endpoints sensíveis da topologia, como os portais Painel do Zabbix (`80 HTTP`) e Visualização Gráfica Grafana (`3000`), encontram-se bloqueados em Firewall e Ingress Rules com listas restritas que aceitam IPs explícitos designados por quem gere o *Variable de terraform* no arquivo `.tfvars` (White-Listing).

## 3. Gestão e Hardening do Sistema (Bootstrapping)

Um ambiente produtivo real não deve pressupor intervenções de técnicos instalando pacotes ou editando arquivos operacionais em máquinas recém-criadas que atuam como Gado (Cattle). Para sanar isso, uma cadeia de *Bootstrapping IA/Bash* injeta via Cloud-init (`user_data.sh`) a automação logo após a BIOS, moldando o hardware e SO da seguinte forma:

> [!CAUTION]
> **Hardening via kernel Sysctl e SSH Purge**
> O agente Zabbix, e todo o parque Debian 12 estão formatados usando scripts Sysadmin avançados:
> - O binário do `openssh-server` é erradicado fisicamente da arquitetura logo no primeiro boot (`apt-get purge`).
> - Parâmetros nucleares (Kernel/sysctl) repelem SynFlood TCP e pacotes mutáveis falsificados com bloqueios a `accept_source_route` e roteamento oculto de pacotes mal formados no Linux.
> - Sincronização de Data `Timezone America/Sao_Paulo` + `chrony` mantendo horários rígidos, exigência vital dos relatórios das dashboards do Zabbix Server.
> - Atualizações críticas da fundação Canonical e OpenSource garantidas ativamente e silenciosamente por uma pipe do `unattended-upgrades`.

## 4. Estado Atual da Camada de Aplicação

O projeto provisiona tanto a estrutura física da malha como instala toda base aplicativa final:

- **Servidor Master 7.0 (srv-zabbix)**: Zabbix Server conectado, banco relacional MariaDB alimentado sem dependências de inserção manual, e portal de Administração Web já populado via Apache no IP Dinâmico EC2.
- **Atenas Distribuídas (Agents)**: A máquina virtual escrava (Debian 12 monitorada) compila via APT o `zabbix-agent`, e no fim amarra a String de rede e as Interfaces apontando perfeitamente e comunicando o Tráfego métrico com sucesso na aba Master de conectividade de Infra/Network de Host IP (`10.0.1.20` - Green ZBX Status Confirmado).
- **Camada Visual Auxiliar:** Os relatórios brutos do Zabbix serão embelezados com recursos adicionais via *Grafana*, pacote já devidamente abaixado e ativo nos serviços do systemd do banco Central.

---

### **Pendente para Entrega (Dia 2)**
- Configurar visualização dinâmica no Portal Grafana (Demonstração gráfica).
- Simular interrupção crítica de serviço a fim de ativar Triggers de Notificação e gerar Alertas no Histórico do portal (*Incident Management Demonstration*).
- Desdobramento local via Box/VM.
