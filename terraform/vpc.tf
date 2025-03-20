locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-west-2a", "us-west-2b"]
}

# Public VPC
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
  version = "5.19.0"

  name = "storefront_vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  # database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  # create_database_internet_gateway_route = false
  # create_database_nat_gateway_route      = false
  enable_nat_gateway                     = true
  single_nat_gateway                     = true
  # enable_vpn_gateway                     = false
  create_igw                             = true
}
