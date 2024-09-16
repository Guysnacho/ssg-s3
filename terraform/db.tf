module "db" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name          = "aurora-storefront-db"
  database_name = var.db-name

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "14.7"
  instance_class = "db.serverless"

  vpc_id = module.vpc.vpc_id

  security_group_rules = {
    vpc_ingress = {
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
      # cidr_blocks = module.vpc.database_subnets_cidr_blocks
    }
    egress_example = {
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Egress to anywhwere"
      # cidr_blocks = ["10.33.0.0/28"]
      # description = "Egress to corporate printer closet"
    }
  }

  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 2
  autoscaling_target_cpu   = 40
  serverlessv2_scaling_configuration = {
    max_capacity = 80
    min_capacity = 30
  }

  autoscaling_enabled             = true
  db_cluster_activity_stream_mode = "async"
  instances = {
    1 = {
      instance_class            = "db.serverless"
      db_parameter_group_name   = "default.aurora-postgresql14"
      db_cluster_instance_class = "db.m5.large"
    }
    # 2 = {
    #   identifier     = "static-member-1"
    #   instance_class = "db.serverless"
    # }
    # 3 = {
    #   identifier     = "excluded-member-1"
    #   instance_class = "db.serverless"
    # }
  }

  # endpoints = {
  #   static = {
  #     identifier     = "static-custom-endpt"
  #     type           = "ANY"
  #     static_members = ["static-member-1"]
  #     tags           = { Endpoint = "static-members" }
  #   }
  #   excluded = {
  #     identifier       = "excluded-custom-endpt"
  #     type             = "READER"
  #     excluded_members = ["excluded-member-1"]
  #     tags             = { Endpoint = "excluded-members" }
  #   }
  # }

  # Uncomment to manually set db auth via pipeline params
  master_username = var.db-username
  # master_password = var.db-password
  manage_master_user_password = true

  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = true
  storage_type                    = "aurora"

  db_subnet_group_name   = "Public"
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnets                = module.vpc.public_subnets

  publicly_accessible = true
  network_type        = "IPV4"
  putin_khuylo        = true

  storage_encrypted   = true
  skip_final_snapshot = true
  apply_immediately   = true
  depends_on          = [module.vpc]

  # Databases using Secrets Manager are not currently supported for Blue Green Deployments
  # blue_green_update = {
  #   enabled = true
  # }
  # parameters = [
  #   # required for blue-green deployment
  #   {
  #     name         = "rds.logical_replication"
  #     value        = 1
  #     apply_method = "pending-reboot"
  #   }
  # ]
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = "storefront_security_group"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id


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
      from_port   = local.port
      to_port     = local.port
      protocol    = "-1" # Allow all protocols
      description = "Allow PostgreSQL access from remote clients"
      cidr_blocks = "0.0.0.0/0" # Replace with a more specific range if needed
    }
  ]

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
