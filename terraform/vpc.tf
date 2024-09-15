locals {
  # vpc_cidr = "10.0.0.0/16"
  vpc_cidr = "192.0.0.0/16"
  port     = 5432
  azs      = ["us-west-2a", "us-west-2b"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "storefront_vpc"
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_internet_gateway_route = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "storefront_security_group"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id


  # ingress
  ingress_with_cidr_blocks = [
    {
      action      = "allow"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      rule_action = "allow"
      rule_number = 100
      description = "PostgreSQL ingress access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
  egress_with_cidr_blocks = [
    {
      action      = "allow"
      from_port   = 5432
      to_port     = 5432
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 100
      description = "PostgreSQL egress access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}
