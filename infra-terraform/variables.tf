variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kindblock"

  validation {
    condition     = can(regex("^[a-zA-Z-]+$", var.project_name))
    error_message = "Value must contain only alphabetic characters and dashes."
  }
}

variable "terraform_state_s3_bucket_name" {
  description = "Unique S3 Bucket name for state files"
  type        = string
  # Dont change bucket name once it is created
  default = "kindblock-terraform-state-bucket"
}

variable "profile" {
  description = "The AWS profile to use"
  type        = string
}

variable "mysql_db_password" {
  type = string
}