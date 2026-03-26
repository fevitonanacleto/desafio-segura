# main.tf

# 1. VPC Principal
resource "aws_vpc" "vpc_segura" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-lab-segura"
  }
}

# 2. Internet Gateway (Saída para Internet)
resource "aws_internet_gateway" "igw_segura" {
  vpc_id = aws_vpc.vpc_segura.id

  tags = {
    Name = "igw-lab-segura"
  }
}

# 3. Subnet Pública
resource "aws_subnet" "subnet_publica" {
  vpc_id                  = aws_vpc.vpc_segura.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Ativa IP público automático (auto-assign)
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "subnet-publica"
  }
}

# 4. Route Table (Roteamento da Subnet Pública)
resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.vpc_segura.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_segura.id
  }

  tags = {
    Name = "rt-publica"
  }
}

# 5. Associação da Route Table com a Subnet
resource "aws_route_table_association" "rta_publica" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.rt_publica.id
}
