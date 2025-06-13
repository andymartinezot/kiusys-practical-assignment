resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "kiusys-db-subnets"
  subnet_ids = var.private_subnets
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "kiusys-db-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  backup_retention_period = 7
  storage_encrypted       = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = []
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = 2
  identifier          = "kiusys-db-node-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.r6g.large"
  engine              = "aurora-postgresql"
  publicly_accessible = false
}
