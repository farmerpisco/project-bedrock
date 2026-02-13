variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}