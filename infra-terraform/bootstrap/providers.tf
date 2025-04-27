terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.87"
    }
  }

  required_version = ">= 1.10.0"
}

provider "aws" {
  region = var.aws_region
  profile = var.profile

  default_tags {
    tags = {
      ProjectName = var.project_name
    }
  }
}
