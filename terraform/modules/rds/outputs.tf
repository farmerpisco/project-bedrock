output "endpoint_mysql" {
  description = "The endpoint of the MySQL RDS instance"
  value       = aws_db_instance.pb_mysql_db.endpoint
}

output "port_mysql" {
  description = "The port of the MySQL RDS instance"
  value       = aws_db_instance.pb_mysql_db.port
}

output "endpoint_postgresql" {
  description = "The endpoint of the PostgreSQL RDS instance"
  value       = aws_db_instance.pb_postgresql_db.endpoint
}

output "port_postgresql" {
  description = "The port of the PostgreSQL RDS instance"
  value       = aws_db_instance.pb_postgresql_db.port
}