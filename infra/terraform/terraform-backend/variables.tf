variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Terraform state bucket"
  type        = string
  default     = "solomon-phoenix-tf-state-174772361223"
}

variable "dynamodb_table_name" {
  description = "Terraform lock table"
  type        = string
  default     = "phoenix-tf-locks"
}