#########################################################################################################
## Create keypair for ec2
#########################################################################################################
# CLI 서버용 키 페어의 개인 키
resource "tls_private_key" "ec2_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# CLI 서버용 키 페어, 위의 개인키를 이용해 생성
resource "aws_key_pair" "ec2_kp" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_pk.public_key_openssh
  tags = {
    Name = "${var.key_name}"
  }
}

# 위의 키 페어를 pem키로 로컬에 다운 받음
resource "local_file" "ssh_key" {
  filename        = "${var.pem_location}/${var.key_name}.pem"
  content         = tls_private_key.ec2_pk.private_key_pem
  file_permission = "0400"
}

#########################################################################################################
## Create ec2 instance and associated resources
#########################################################################################################
# CLI 서버에 적용할 보안그룹을 생성함
resource "aws_security_group" "ec2_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.sg_name}"
  }
}
# 보안그룹의 인바운드 규칙을 생성함
resource "aws_security_group_rule" "allow_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_8089" {
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  to_port           = 8089
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
# 보안그룹의 아웃바운드 규칙을 생성함
resource "aws_security_group_rule" "allow_all_ports_egress" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
# EC2 인스턴스가 AWS 리소스에 접근할 때 사용할 IAM 역할의 프로파일 생성함
resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.iam_instance_profile_name
  role = var.iam_instance_profile_role
  tags = {
    Name = "${var.iam_instance_profile_name}"
  }
}

# CLI 서버 인스턴스를 생성함
resource "aws_instance" "ec2_instance" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = aws_key_pair.ec2_kp.key_name
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  user_data = var.user_data

  user_data_replace_on_change = true

  tags = {
    Name = var.instance_name
  }
}
