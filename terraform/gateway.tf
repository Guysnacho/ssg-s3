module "gateway" {
  source        = "terraform-aws-modules/apigateway-v2/aws"
  name          = "storefront-gateway"
  description   = "Gateway for allowing requests from our storefront to talk to AWS resources."
  protocol_type = "HTTP"
  version       = "5.2.1"

  # API
  #   body = "import_me_from_local.yml"
  # domain_name = "supercool.real.com"
  domain_name           = "storefront"
  create_domain_name    = false
  create_domain_records = true
  create_certificate    = true
  hosted_zone_name      = "storefront-zone"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["POST", "GET"] # Allow all methods - ["*"]
    allow_origins = ["*"]
  }

  # Access logs
  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 1
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  # Routes & Integration(s) Defined on https://registry.terraform.io/modules/terraform-aws-modules/apigateway-v2/aws/latest#:~:text=integration%20%3D%20object(%7B
  routes = {
    "POST /sale" = {
      integration = {
        uri                    = module.sale_lambda.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
        description            = "Sale lambda"
        passthrough_behavior   = "WHEN_NO_TEMPLATES"
        # type                      = "AWS_PROXY"
      }
    }
    "POST /auth" = {
      integration = {
        uri                    = module.auth_lambda.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
        description            = "Auth lambda"
        passthrough_behavior   = "WHEN_NO_TEMPLATES"
        # type                      = "AWS_PROXY"
      }
    }
    "GET /catalog" = {
      integration = {
        uri                    = module.catalog_lambda.lambda_function_invoke_arn
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
        description            = "Catalog lambda"
        passthrough_behavior   = "WHEN_NO_TEMPLATES"
        # type                      = "AWS_PROXY"
      }
    }
    # "$default" = {
    #   integration = {
    #     uri = module.ecr
    #     description = "ECS Storefront"

    #   }
    # }
  }
}
