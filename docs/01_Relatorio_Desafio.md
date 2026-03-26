# Relatório de Execução do Case Técnico: Global Support Engineer Sênior

**Candidato:** [SEU NOME AQUI]
**Vaga:** Global Support Engineer - **Segura**

---

## 1. Visão Executiva e Estratégia "Over-Deliver"

Para este desafio técnico, decidi adotar uma postura extremamente técnica e abrangente, refletindo não apenas o domínio operacional exigido no nível Sênior para o provisionamento local, mas também agregando uma visão profunda de **Segurança (Zero Trust), Hardening de OS e Infraestrutura como Código (IaC)**.

O escopo pedia o provisionamento de servidores locais no VirtualBox e monitoramento via Zabbix. Entreguei o projeto utilizando uma abordagem Híbrida e implacável em **duas frentes**:
1. **Cenário On-Premises (Local):** Atendimento 100% fidedigno às especificações técnicas solicitadas via automação Vagrant.
2. **Cenário Enterprise Nuvem (AWS):** Deploy espelhado de um ambiente de Produção na AWS, utilizando Terraform, Hardening extremo, Acesso sem Chaves SSH (SSM) e Gestão de Custos (FinOps).

*(Abaixo detalho cada uma dessas conquistas, os códigos desenvolvidos e as respectivas evidências).*

---

## 2. A Fundação de Automação: Cenário AWS Cloud (IaC)

Visando tangibilizar minha proatividade para o negócio da "Segura", construí e provisionei toda a infraestrutura através de IaC (Terraform). Todo o código (`compute.tf`, `security.tf`, `variables.tf`, e módulos de shell) foi versionado para garantir Imutabilidade e Governança total.

**Evidência 1: O Plano de Execução e o Código Terraform**
> **[COLE AQUI O SEU PRINT DO TERMINAL MOSTRANDO O CÓDIGO TF OU RODANDO O `terraform apply`]**

### 2.1. Arquitetura de Rede VPC (Isolamento Lógico)
A infraestrutura não foi jogada na rede default. Desenhei um isolamento criando uma VPC própria e subredes com roteamento controlado.

**Evidência 2: Tela do Console AWS mostrando nossa Rede VPC / Subnet / EC2**
> **[COLE AQUI O PRINT DO CONSOLE DA AWS MOSTRANDO DETALHES DA SUA EC2, O IP E A VPC QUE CRIAMOS LÁ]**

### 2.2. Acesso Safeless Zero-Trust (AWS Systems Manager - SSM)
Como um candidato alinhado com as políticas de acessos sensíveis (PAM), erradiquei chaves físicas corporativas (arquivos `.pem`) e senhas do escopo de administração do servidor. As instâncias EC2 foram expostas com a porta 22 (SSH) **trancada no firewall (Security Group)** para o mundo. 
O acesso de suporte foi confiado unicamente ao **AWS SSM Session Manager**, atrelado via Instace Profiles do IAM (`iam_ssm.tf`), garantindo logs contínuos e acesso shell via browser.

**Evidência 3: Acessando o Console da Máquina via AWS SSM (Sem Chave)**
> **[COLE AQUI O PRINT AQUELA TELA PRETA (PROMPT) DENTRO DO CONSOLE DA AWS ESCRITO `ssm-user`]**

### 2.3. Hardening de Sistema Operacional (Debian 12)
Para a camada de Host, o `user_data.sh` não apenas instalou pacotes. Ele implementou **Hardening** ativo da máquina, alinhado à defesa em profundidade:
- Purga completa do pacote `openssh-server` (já que o acesso ocorre pelo agente local do SSM).
- Ajustes de `sysctl.conf` para mitigação de IP Spoofing e proteção contra SYN Floods.
- Ajustes de sincronia de tempo segura (Chrony NTP) essenciais em monitoramento.

**Evidência 4: Trecho do Nosso Código de Hardening (`user_data.sh`)**
> **[COLE AQUI O PRINT DAQUELA PARTE DO ARQUIVO `user_data.sh` MOSTRANDO AS PROTEÇÕES DE SYSCTL E A PURGA DO SSH]**

---

## 3. O Fator Básico: Cenário On-Premise Local 

Para demonstrar respeito às raízes e aos requisitos exatos do edital, repliquei o cenário na arquitetura On-Premises exigida (Debian monitorado). O requisito era estrito: entregar a máquina host monitorada com exatos 2 vCPUs, 4GB de RAM e 20GB de disco configurado em LVM.

Para não recorrer a cliques manuais obsoletos no VirtualBox, criei um Script Vagrant (`Vagrantfile`) que constrói toda a camada de Hardware e formata o volume através da injeção nativa de comandos Linux:

**Evidência 5: Hardware Exigido (2 vCPUs e 4GB RAM) no SO do Debian Vagrant**
> **[COLE AQUI A FOTO DO SEU TERMINAL RODANDO O COMANDO `lscpu` E `free -h`]**

**Evidência 6: Estrutura LVM Automatizada de 20GB**
> **[COLE AQUI A FOTO DO SEU TERMINAL RODANDO `lsblk` E `lvs` MOSTRANDO A ARVORE DE DISCO VG_DATA]**

---

## 4. Integração de Plataformas e Teste de Desastre (Observabilidade)

A fase final do desafio focava na capacidade do Zabbix Server em coletar, organizar e responder à saúde do target.
O agente foi instalado em ambas as nuvens de forma unificada utilizando automação Shell.

**Evidência 7: Zabbix - Os Dois Hosts Cadastrados e Coletando**
> **[COLE AQUI O PRINT DA TELA DO ZABBIX LISTANDO OS ALVOS (STATUS GREEN ZBX)]**

Para testar o fluxo de Resposta a Incidentes, causei propositalmente uma interrupção dos serviços cortando (kill) o processo do agente de monitoramento diretamente no Host, engatilhando as *Triggers* de silêncio do agente.

**Evidência 8: A Resposta ao Incidente no Zabbix (Alarmando o Desastre)**
> **[COLE AQUI A NOSSA ULTIMA FOTO DO ZABBIX NO "CURRENT PROBLEMS" PISACANDO EM VERMELHO]**

**Evidência 9 (Bônus): O Grafana Atuando em Sinergia Avançada (Dashboard)**
> **[COLE AQUI A FOTO DO GRAFANA INTEGRIDADO QUE SUBIMOS NA AWS]**

---

## 5. Conclusão da Arquitetura

Foram empregadas dezenas de horas de refinamento neste pipeline para provar que a observabilidade é o fim, mas a infraestrutura base é o meio crítico de toda operação eficiente. O alinhamento perfeito entre as tecnologias (LVM físico vs Cloud Block Storage / Vagrant vs Terraform) comprova que estou apto a suportar os diretos do produto Core da "Segura".
