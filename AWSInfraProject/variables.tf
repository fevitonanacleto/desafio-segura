variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}



variable "meus_ips" {
  description = "Lista de endereços IP públicos para liberar acesso administrativo no Security Group"
  type        = list(string)
}

variable "estado_das_instancias" {
  description = "Define se as EC2 devem estar ligadas ou desligadas para economizar grana (running ou stopped)"
  type        = string
  default     = "running"
}

