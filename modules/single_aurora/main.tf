# RDS 보안 그룹 생성
resource "aws_security_group" "rds_sg" {
  name        = var.security_group_name
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.node_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "aurora" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

# RDS 클러스터 생성
resource "aws_rds_cluster" "aurora_mysql" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  database_name           = var.database_name
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  storage_encrypted       = var.storage_encrypted
  skip_final_snapshot     = var.skip_final_snapshot

  tags = {
    Name = var.cluster_identifier
  }
}

# RDS 클러스터 인스턴스 생성
resource "aws_rds_cluster_instance" "aurora_mysql_instance" {
  identifier          = var.instance_identifier
  cluster_identifier  = aws_rds_cluster.aurora_mysql.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.aurora_mysql.engine
  engine_version      = aws_rds_cluster.aurora_mysql.engine_version
  publicly_accessible = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.aurora.name

  tags = {
    Name = var.instance_identifier
  }
}
