terraform {
  backend "s3" {
    # Note: Verify these before creating infra
    bucket               = "kindblock-terraform-state-bucket"
    key                  = "kindblock/terraform.tfstate"
    region               = "ap-south-1"
    profile              = "personal"
    encrypt              = true
    use_lockfile         = true
    workspace_key_prefix = "workspaces"
  }

  required_version = ">= 1.10.0"
}

module "main-app" {
  source                             = "./infra"
  aws_region                         = var.aws_region
  project_name                       = lower(var.project_name)
  mysql_db_password                  = var.mysql_db_password
}