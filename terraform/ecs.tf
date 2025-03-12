# Full disclosure, this modules a little overwhelming

locals {
  name   = "ex-${basename(path.cwd)}"

  container_name = "storefront-ecs"
  container_port = 3000

  tags = {
    Name       = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.0"

  cluster_name = local.name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  default_capacity_provider_use_fargate = false

  tags = local.tags
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 1024
  memory = 4096

  # Enables ECS Exec
  enable_execute_command = true

  volume = {
    # Storage volume, when given an empty map, our volume lives in memory
    my-vol = {}
  }
  launch_type = "FARGATE"

  # Container definition(s)
  container_definitions = {

    (local.container_name) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = data.aws_ecr_image.service_image.image_uri
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false
      # entry_point = ["node", "server.js"]

      # dependencies = [{
      #   containerName = "storefront"
      #   condition     = "START"
      # }]

      enable_cloudwatch_logging = true


      linux_parameters = {
        capabilities = {
          add = []
          drop = [
            "NET_RAW"
          ]
        }
      }

      # Not required for storefront, just an example
      # volumes_from = [{
      #   sourceContainer = "storefront"
      #   readOnly        = false
      # }]

      memory_reservation = 100
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex_ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  service_tags = {
    "ServiceTag" = "Tag on service level"
  }

  tags = local.tags
  # container_definitions = {
  #   (local.container_name) = {
  #     image = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
  #     port_mappings = [
  #       {
  #         name          = local.container_name
  #         containerPort = local.container_port
  #         protocol      = "tcp"
  #       }
  #     ]

  #     mount_points = [
  #       {
  #         sourceVolume  = "my-vol",
  #         containerPath = "/var/storefront/my-vol"
  #       }
  #     ]

  #     entry_point = ["/usr/sbin/apache2", "-D", "FOREGROUND"]

  #     # Example image used requires access to write to root filesystem
  #     readonly_root_filesystem = false

  #     enable_cloudwatch_logging              = true
  #     create_cloudwatch_log_group            = true
  #     cloudwatch_log_group_name              = "/aws/ecs/${local.name}/${local.container_name}"
  #     cloudwatch_log_group_retention_in_days = 7

  #     log_configuration = {
  #       logDriver = "awslogs"
  #     }
  #   }
  # }
}

################################################################################
# Supporting Resources
################################################################################

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
# data "aws_ssm_parameter" "ecs_optimized_ami" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
# }

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      # Allow all tcp traffic in through port 3000
      # Feel free to scope this rule down depending on your usecase.
      # Maybe you only want specific ranges available and divide those
      # ranges among individual ecs tasks.
      from_port   = 3000
      to_port     = 3000
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      # Allow all ipv4 traffic out
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }
  listeners = {
    ex_http = {
      port     = 3000
      protocol = "HTTP"

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        # Disabled until we get a good image running
        enabled           = true
        healthy_threshold = 5
        interval          = 30
        matcher           = "200"
        # Health check will be our hello endpoint
        path                = "/api/hello"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.tags
}

data "aws_ecr_image" "service_image" {
  repository_name = module.ecr.repository_name
  most_recent     = true
}
