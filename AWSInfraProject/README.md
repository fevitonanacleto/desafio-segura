# Projeto Segura: Arquitetura de Monitoramento Sênior na AWS

Este documento consolida a arquitetura em nuvem provisionada para suportar a infraestrutura de monitoramento com Zabbix e Grafana. O projeto foi formatado utilizando **Infraestrutura como Código (Terraform)** e ancorado em metodologias corporativas de **DevSecOps**, **Zero Trust** e de gerenciamento de faturamento da nuvem **(FinOps)**.

---

## ⚡ Quick Start - Como Inicializar o Projeto

### Pré-requisitos

1. **Terraform** (v1.0+)  
   Baixe em: https://www.terraform.io/downloads
   
   Verifique a instalação:
   ```bash
   terraform --version
   ```

2. **AWS CLI** (v2)  
   Baixe em: https://aws.amazon.com/cli/
   
   Verifique a instalação:
   ```bash
   aws --version
   ```

3. **Credenciais da AWS** (Access Key ID + Secret Access Key)
   - Faça login na [AWS Console](https://console.aws.amazon.com)
   - Vá em **IAM → Users → Seu usuário → Security credentials**
   - Clique em **Create access key** e baixe o arquivo CSV
   - ⚠️ **Guarde em segurança! Nunca compartilhe essas credenciais**

### Passo 1: Configurar Credenciais AWS

⚠️ **IMPORTANTE:** Configure as credenciais AWS **localmente na sua máquina**, nunca as adicione ao código ou commits Git!

1. Gere um **Access Key** na AWS Console:
   - Faça login em [AWS Console](https://console.aws.amazon.com)
   - Vá em **IAM → Users → Seu usuário → Security credentials**
   - Clique em **Create access key**
   - Guarde o arquivo CSV com segurança

2. Configure no seu sistema operacional:

**Windows (PowerShell):**
```powershell
# Criar diretório
mkdir $env:USERPROFILE\.aws -Force
```

Depois edite manualmente `C:\Users\<SEU_USUARIO>\.aws\credentials` e adicione suas chaves ali (não as deixe no README ou Git).

**Linux/Mac:**
```bash
mkdir -p ~/.aws
nano ~/.aws/credentials
```

Edite com suas chaves locais.

3. Verifique se está funcionando:
```bash
aws sts get-caller-identity
```

Você deverá ver seu Account ID e ARN.

### Passo 2: Configurar o arquivo `terraform.tfvars`

Edite o arquivo `terraform.tfvars` com seus valores:

```hcl
# Região da AWS onde deseja criar recursos
aws_region = "us-east-1"  # ou outra região

# Seus endereços IP públicos (para permitir acesso ao Zabbix/Grafana)
# Para encontrar seu IP: https://www.meuip.com ou https://whatismyip.akamai.com
meus_ips = [
  "SEU_IP_PUBLICO/32",      # Seu IP de casa/escritório
  "OUTRO_IP_AUTORIZADO/32"  # IP de outro computador (opcional)
]

# Estado das instâncias: "running" (ligado) ou "stopped" (desligado - economiza custos)
estado_das_instancias = "running"
```

### Passo 3: Inicializar e Validar Terraform

```bash
# Entre no diretório do projeto
cd AWSInfraProject

# Inicializa o Terraform (baixa providers)
terraform init

# Valida a configuração
terraform validate

# Mostra o plano de execução (o que será criado)
terraform plan -out=tfplan
```

Revise cuidadosamente o plano. Procure por:
- ✅ VPC, Security Groups, EC2 instances
- ✅ IAM roles e policies
- ❌ Qualquer recurso inesperado

### Passo 4: Aplicar a Infraestrutura

```bash
# Cria os recursos na AWS (pode levar 5-10 minutos)
terraform apply tfplan

# Guarde os outputs:
terraform output
```

Você verá algo como:
```
zabbix_server_private_ip = "10.0.1.10"
debian_monitored_private_ip = "10.0.1.20"
zabbix_server_id = "i-0123456789abcdef0"
debian_monitored_id = "i-0987654321fedcba0"
```

### Passo 5: Acessar os Servidores via SSM Session Manager

Como **não há SSH aberto** (hardening de segurança), acesse via AWS Systems Manager:

**Via AWS Console:**
1. Vá em **AWS Systems Manager → Session Manager**
2. Clique em **Start session**
3. Selecione a instância (srv-zabbix ou srv-debian-monitored)
4. Conecte

**Via CLI (mais rápido):**
```bash
# Conectar ao servidor Zabbix
aws ssm start-session --target <ZABBIX_INSTANCE_ID> --region us-east-1

# Conectar ao servidor monitorado (Debian)
aws ssm start-session --target <DEBIAN_INSTANCE_ID> --region us-east-1
```

Substitua `<ZABBIX_INSTANCE_ID>` e `<DEBIAN_INSTANCE_ID>` pelos IDs retornados no `terraform output`.

### Passo 6: Acessar o Portal Zabbix Web

Uma vez que a infraestrutura está UP, o Zabbix está rodando. Você precisará fazer um port-forward via SSM ou configurar um proxy reverso.

**Opção simples (Local Port Forwarding via SSM):**

```bash
# Crie um túnel do seu computador para a porta 80 do servidor Zabbix
aws ssm start-session --target <ZABBIX_INSTANCE_ID> \
  --document-name AWS-StartPortForwardingSession \
  --parameters localPortNumber=8080,portNumber=80
```

Depois acesse: **http://localhost:8080**

Credenciais padrão do Zabbix:
- **Usuário:** Admin
- **Senha:** zabbix

### Passo 7: Destruir a Infraestrutura (quando não precisar mais)

⚠️ **Cuidado! Isso deletará TODOS os recursos e dados**

```bash
terraform destroy
```

Digite `yes` para confirmar.

---

## Troubleshooting

### Error: "credentials not found"
- Verifique se suas credenciais AWS estão em `~/.aws/credentials`
- Ou configure as variáveis de ambiente

### Error: "InvalidInstanceID.NotFound"
- Espere alguns segundos após o `terraform apply` antes de tentar conectar
- Verifique se a instância realmente foi criada no console AWS

### Error: "User: arn:aws:iam::... is not authorized"
- Sua chave AWS não tem permissões suficientes
- Crie uma com permissões de EC2, VPC, IAM, SSM

### Não consigo acessar o portal Zabbix
- Verifique se seu IP está adicionado corretamente no `terraform.tfvars`
- Certifique-se que a instância está em estado "running"

---

## 🔐 Gerenciamento de Tokens e Credenciais

### Tokens da AWS (Access Keys)

**Como criar novos tokens:**
1. Acesse a [AWS Console](https://console.aws.amazon.com)
2. Vá em **IAM → Users → Seu usuário → Security credentials**
3. Clique em **Create access key**
4. Escolha o caso de uso (ex: "Local development")
5. Baixe o CSV ou copie as credenciais
6. Guarde em local seguro (em um password manager, nunca no Git!)

**Como rotacionar tokens (recomendado a cada 90 dias):**
```bash
# Listar tokens ativos
aws iam list-access-keys --user-name SEU_USUARIO

# Desabilitar um token antigo
aws iam update-access-key --access-key-id AKIAIOSFODNN7EXAMPLE \
  --status Inactive --user-name SEU_USUARIO

# Deletar o token after confirming it's not in use
aws iam delete-access-key --access-key-id AKIAIOSFODNN7EXAMPLE \
  --user-name SEU_USUARIO
```

**⚠️ NUNCA**:
- Commite credenciais no Git
- Compartilhe suas chaves com terceiros
- Use keys de desenvolvimento em produção
- Deixe keys visíveis em screenshots/documentação

### Credenciais do Zabbix

Quando conectar ao portal Zabbix pela primeira vez, altere a senha padrão:

**Padrão:**
- **Usuário:** Admin
- **Senha:** zabbix

**Como alterar a senha:**
1. Faça login no http://localhost:8080 (via tunnel SSM)
2. Vá em **User profile** (canto superior direito)
3. Clique em **Change password**
4. Insira a nova senha (forte, com + 12 caracteres)
5. Salve as mudanças

### API Tokens do Zabbix (para automações)

Se precisar integrar Zabbix com ferramentas externas:

```bash
# Via SSH/SSM Session dentro do servidor Zabbix:
mysql -u zabbix -p zabbix -e "SELECT userid, alias FROM users WHERE alias='Admin';"

# Ou via Zabbix API (curl):
curl -X POST "http://localhost:80/api_jsonrpc.php" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
      "username": "Admin",
      "password": "SUA_NOVA_SENHA"
    },
    "id": 1
  }'
```

### API Tokens do Grafana

Similar ao Zabbix, o Grafana também suporta tokens para autenticação programática:

1. Acesse Grafana (se configurado)
2. Vá em **Configuration → API Keys**
3. Clique em **New API key**
4. Escolha uma role (Admin, Editor, Viewer)
5. Guarde o token gerado

Use em requisições:
```bash
curl -H "Authorization: Bearer eyJrIjoiT0tTcm50Vk42..." http://localhost:3000/api/users
```

---

## 💰 Custos e Free Tier

### AWS Free Tier (12 meses)

Este projeto foi otimizado para caber **gratuitamente** no Free Tier:

| Recurso | Limite Grátis | Nosso Uso |
|---------|---------------|----------|
| EC2 t3.micro | 750 horas/mês | ~360h/mês (2 instâncias) ✅ |
| EBS (gp3) | 30 GB total | 30 GB | ✅ |
| Data Transfer Out | 1 GB/mês | ~100-500 MB | ✅ |
| NAT Gateway | Pago | Não usado | ✅ |
| Elastic IP | Pago (se não em uso) | Não usado | ✅ |

**Estimativa mensal pós-Free Tier:**
- Operando 24/7: ~$12-15/mês
- Operando 12h/dia: ~$6-8/mês

### Como economizar

```hcl
# No terraform.tfvars:
estado_das_instancias = "stopped"  # Desliga quando não está usando
```

Instâncias paradas **não cobram**! Só o storage (EBS) continua sendo cobrado (~$1/mês).

### Monitorar custos

```bash
# Via AWS CLI
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

Ou acesse: **AWS Console → Cost Explorer**

---

## 📚 Estrutura de Arquivos

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

---

## 📚 Estrutura de Arquivos

```
AWSInfraProject/
├── main.tf                 # Recursos principais (VPC, subnets, EC2)
├── provider.tf             # Configuração do provider AWS
├── variables.tf            # Declaração de variáveis
├── terraform.tfvars        # Valores das variáveis (ADAPTE ESTE ARQUIVO)
├── security.tf             # Security Groups (firewall)
├── iam_ssm.tf              # IAM roles e policies para SSM
├── iam_policy.json         # Policy JSON customizada
├── compute.tf              # Configuração das instâncias EC2
├── user_data.sh            # Script de bootstrapping (hardening)
├── terraform.tfstate       # Estado da infraestrutura (não edite!)
├── terraform.tfstate.backup# Backup do estado
└── README.md               # Este arquivo
```

### Descrição dos Arquivos Principais

| Arquivo | Propósito |
|---------|----------|
| **main.tf** | Define VPC, subnets, route tables, gateways |
| **compute.tf** | Cria instâncias EC2 (Zabbix Server + Debian monitored) |
| **security.tf** | Define Security Groups (portas, IPs permitidos) |
| **iam_ssm.tf** | Cria roles IAM para acesso SSM (sem SSH) |
| **user_data.sh** | Script que roda na primeira inicialização (hardening) |
| **terraform.tfvars** | **EDITE ESTE** com seus valores (IPs, região, etc) |

---

## 🤝 Suporte e Dúvidas

Para problemas com:
- **Terraform:** Consulte [Terraform Docs](https://www.terraform.io/docs)
- **AWS:** Consulte [AWS Docs](https://docs.aws.amazon.com)
- **Zabbix:** Consulte [Zabbix Docs](https://www.zabbix.com/documentation)
- **Grafana:** Consulte [Grafana Docs](https://grafana.com/docs)

---

**Última atualização:** Março 2026  
**Status:** Projeto ativo e em desenvolvimento
