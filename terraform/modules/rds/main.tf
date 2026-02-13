data "aws_secretsmanager_secret" "pb_db_username" {
  name = "${var.project_name}-db-username"
}

data "aws_secretsmanager_secret_version" "pb_db_username_version" {
  secret_id = data.aws_secretsmanager_secret.pb_db_username.id
}

data "aws_secretsmanager_secret" "pb_db_password" {
  name = "${var.project_name}-db-password"
}

data "aws_secretsmanager_secret_version" "pb_db_password_version" {
  secret_id = data.aws_secretsmanager_secret.pb_db_password.id
}

resource "aws_db_instance" "pb_mysql_db" {
  identifier_prefix   = "${var.project_name}-mysql"
  engine              = "mysql"
  engine_version      = "8.0"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "bedrock_catalog_db"

  username = data.aws_secretsmanager_secret_version.pb_db_username_version.secret_string
  password = data.aws_secretsmanager_secret_version.pb_db_password_version.secret_string

  vpc_security_group_ids = [var.pb_rds_sg_id]
  db_subnet_group_name  = var.pb_rds_subnet_group_name

  tags = {
    Name = "${var.project_name}-mysql-db"
  }
}

resource "aws_db_instance" "pb_postgresql_db" {
  identifier_prefix   = "${var.project_name}-postgresql"
  engine              = "postgres"
  engine_version      = "15"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "bedrock_order_db"

  username = data.aws_secretsmanager_secret_version.pb_db_username_version.secret_string
  password = data.aws_secretsmanager_secret_version.pb_db_password_version.secret_string

  vpc_security_group_ids = [var.pb_rds_sg_id]
  db_subnet_group_name  = var.pb_rds_subnet_group_name

  tags = {
    Name = "${var.project_name}-postgresql-db"
  }
}