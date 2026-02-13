variable project_name {
  description = "Name of the project for resource naming"
  type        = string
}

variable db_username {
  description = "Username for the RDS database"
  type        = string
  sensitive   = true
}

variable db_password {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable pb_rds_sg_id {
  description = "The ID of the RDS security group"
  type        = string
}

variable pb_rds_subnet_group_name {
  description = "The name of the RDS subnet group"
  type        = string
}