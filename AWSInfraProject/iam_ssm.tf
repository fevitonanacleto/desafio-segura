# iam_ssm.tf

# 1. IAM Role do Systems Manager (SSM)
resource "aws_iam_role" "ssm_role_segura" {
  name = "EC2RoleForSSMSeguraLab"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "Role-SSM-Basica"
  }
}

# 2. Vínculo (Attachment) da Managed Policy Oficial do SSM Core
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role_segura.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. Instance Profile (Contêiner para Injeção da Role na EC2)
resource "aws_iam_instance_profile" "ssm_profile_segura" {
  name = "EC2ProfileForSSMSeguraLab"
  role = aws_iam_role.ssm_role_segura.name
}
