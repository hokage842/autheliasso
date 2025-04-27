module "network" {
    source = "./network"
    aws_region = var.aws_region
    project_prefix = "${terraform.workspace}-${var.project_name}"
}

module "backend" {
    source = "./backend"
    aws_region = var.aws_region
    project_prefix = "${terraform.workspace}-${var.project_name}"
    vpc_id = module.network.vpc_id
    public_subnets_ids = module.network.public_subnets_ids
    private_subnets_ids = module.network.private_subnets_ids
}
