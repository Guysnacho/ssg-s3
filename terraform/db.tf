

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.9.0"

  identifier = "storefront-db"

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16"         # DB option group
  instance_class       = "db.m5.large"

  allocated_storage     = 5
  max_allocated_storage = 7

  db_name  = var.db-name
  username = var.db-username
  port     = 5432

  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = true
  storage_type                    = "gp2"

  # db_subnet_group_name   = module.vpc.database_subnet_group
  # vpc_security_group_ids = [module.security_group.security_group_id]

  blue_green_update = {
    enabled = true
  }
  parameters = [
    # required for blue-green deployment
    {
      name         = "rds.logical_replication"
      value        = 1
      apply_method = "pending-reboot"
    }
  ]
}
