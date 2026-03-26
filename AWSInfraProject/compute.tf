# Imagem Oficial do Debian 12 (Data Source)
data "aws_ami" "debian12" {
  most_recent = true
  owners      = ["136693071363"] # Debian Official owner ID

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# EC2: Host Monitorado (srv-debian)
resource "aws_instance" "srv_debian" {
  ami                         = data.aws_ami.debian12.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet_publica.id
  vpc_security_group_ids      = [aws_security_group.sg_srv_debian.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile_segura.name
  associate_public_ip_address = true
  private_ip                  = "10.0.1.10" # Fixando IP conforme escopo

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }



  tags = {
    Name = "srv-debian-monitorado"
  }

  user_data_replace_on_change = false
  user_data                   = file("${path.module}/user_data.sh")
}

# Controle de Estado Visual (Debian)
resource "aws_ec2_instance_state" "srv_debian_state" {
  instance_id = aws_instance.srv_debian.id
  state       = "running"
}

# EC2: Zabbix Server + Grafana (srv-zabbix)
resource "aws_instance" "srv_zabbix" {
  ami                         = data.aws_ami.debian12.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet_publica.id
  vpc_security_group_ids      = [aws_security_group.sg_srv_zabbix.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile_segura.name
  associate_public_ip_address = true
  private_ip                  = "10.0.1.20" # Fixando IP para o Agent poder mandar metricas

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "srv-zabbix-server"
  }

  user_data_replace_on_change = false
  user_data                   = file("${path.module}/user_data.sh")
}

# Controle de Estado Visual (Zabbix Server)
resource "aws_ec2_instance_state" "srv_zabbix_state" {
  instance_id = aws_instance.srv_zabbix.id
  state       = "running"
}

# Outputs parciais para acesso

output "ip_publico_do_zabbix" {
  value       = aws_instance.srv_zabbix.public_ip
}

output "ip_publico_do_servidor_monitorado" {
  value       = aws_instance.srv_debian.public_ip
}

# Controle de Estado de Energia Individual (Ligar/Desligar)
# Altere para "stopped" a máquina que desejar pausar e rode `terraform apply`



