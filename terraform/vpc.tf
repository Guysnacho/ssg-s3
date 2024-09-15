locals {
  vpc_cidr = "10.0.0.0/16"
  # vpc_cidr = "192.0.0.0/16"
  port = 5432
  azs  = ["us-west-2a", "us-west-2b"]
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.13.0"

#   name                 = "storefront_vpc"
#   cidr                 = local.vpc_cidr
#   azs                  = local.azs
#   public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
#   enable_dns_hostnames = true
#   enable_dns_support   = true
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "storefront_vpc"
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  create_database_internet_gateway_route = true
  create_database_nat_gateway_route      = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "storefront_security_group"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id



  # ingress
  # {
  #   action      = "allow"
  #   from_port   = 5432
  #   to_port     = 5432
  #   protocol    = "tcp"
  #   rule_action = "allow"
  #   rule_number = 100
  #   cidr_blocks = module.vpc.vpc_cidr_block
  # },
  # {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "tcp"
  #   rule_number = 100
  #   description = "PostgreSQL ingress access from within VPC"
  #   cidr_blocks = "0.0.0.0/0"
  # }
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      rule_number = 100
      description = "PostgreSQL ingress access from within VPC"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Allow PostgreSQL access from remote clients"
      cidr_blocks = "0.0.0.0/0" # Replace with a more specific range if needed
    }
  ]

  # {
  #   action      = "allow"
  #   from_port   = 5432
  #   to_port     = 5432
  #   protocol    = "-1"
  #   rule_action = "allow"
  #   rule_number = 100
  #   description = "PostgreSQL egress access from within VPC"
  #   cidr_blocks = module.vpc.vpc_cidr_block
  #   },
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1" # Allow all protocols
      rule_number = 100
      description = "PostgreSQL egress access from within VPC"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
