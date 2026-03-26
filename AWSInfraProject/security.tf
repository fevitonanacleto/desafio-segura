# Security Group para o Servidor Monitorado (srv-debian)
resource "aws_security_group" "sg_srv_debian" {
  name        = "secgroup-srv-debian"
  description = "Permite acesso SSH apenas do meu IP e 10050 do Zabbix Server"
  vpc_id      = aws_vpc.vpc_segura.id



  # Zabbix Agent (Restrito ao Zabbix Server IP - 10.0.1.20)
  ingress {
    description = "Zabbix Agent Inbound"
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.20/32"]
  }

  # Ping Interno para testes (Opcional, restrito a VPC)
  ingress {
    description = "ICMP from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vpc_segura.cidr_block]
  }

  # Opcional (Outbound livre para baixar pacotes)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-srv-debian"
  }
}

# Security Group para o Zabbix Server (srv-zabbix)
resource "aws_security_group" "sg_srv_zabbix" {
  name        = "secgroup-srv-zabbix"
  description = "Permite acesso SSH e WEB apenas do meu IP e comunicacao com Agents"
  vpc_id      = aws_vpc.vpc_segura.id



  # HTTP Web Interface (Zabbix) - Restrito ao IP Publico do usuario
  ingress {
    description = "HTTP for Zabbix UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.meus_ips
  }

  # Grafana - Restrito ao IP Publico do usuario
  ingress {
    description = "Port for Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.meus_ips
  }

  # Zabbix Trapper (Restrito a Subnet da VPC)
  ingress {
    description = "Zabbix Trapper Inbound"
    from_port   = 10051
    to_port     = 10051
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet_publica.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-srv-zabbix"
  }
}
