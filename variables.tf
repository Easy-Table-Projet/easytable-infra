variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "db_name" {
  description = "Database Name"
  type        = string
}

variable "db_user" {
  description = "Database User"
  type        = string
}

variable "db_password" {
  description = "Database Password"
  type        = string
  sensitive   = true
}
