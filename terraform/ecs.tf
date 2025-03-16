# Full disclosure, this modules a little overwhelming

locals {
  name = "ex-${basename(path.cwd)}"

  container_name = "storefront-ecs"
  container_port = 3000

  tags = {
    Name       = local.name
    Repository = "27th time's the charm"
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
  depends_on = [ data.aws_ecr_image.service_image ]

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

  # load_balancer = {
  #   service = {
  #     target_group_arn   = module.alb.target_groups["ex_ecs"].arn
  #     load_balancer_name = local.name
  #     container_name     = local.container_name
  #     container_port     = local.container_port
  #   }
  # }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.security_group.security_group_id
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

data "aws_ecr_image" "service_image" {
  depends_on = [ module.ecr ]
  repository_name = module.ecr.repository_name
  most_recent     = true
}
