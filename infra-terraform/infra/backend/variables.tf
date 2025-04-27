variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "private_subnets_ids" {
  type = list(string)
}


variable "ebs_size" {
  type = number
  default = 10
}
