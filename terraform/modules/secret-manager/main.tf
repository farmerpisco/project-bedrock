resource "aws_secretsmanager_secret" "pb_db_username" {
  name = "${var.project_name}-db-username"

  tags = {
    Name = "${var.project_name}-db-username"
  }
}

resource "aws_secretsmanager_secret_version" "pb_db_username_version" {
  secret_id     = aws_secretsmanager_secret.pb_db_username.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "pb_db_password" {
  name = "${var.project_name}-db-password"

  tags = {
    Name = "${var.project_name}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "pb_db_password_version" {
  secret_id     = aws_secretsmanager_secret.pb_db_password.id
  secret_string = var.db_password
}