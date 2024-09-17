locals {
  package_url = "https://required_packages_to_run_lambda_code.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

data "aws_caller_identity" "current" {}

module "auth_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.9.0"

  function_name = "storefront-auth-lambda"
  runtime       = "nodejs20.x"
  handler       = "auth.handler"
  publish       = true
  # lambda_at_edge = true

  # Environmental variables needed to log into database
  environment_variables = {
    db_host     = module.db.cluster_endpoint
    db_username = var.db-username
    db_password = module.db.cluster_master_password
    db_name     = var.db-name
    secret      = var.cloudfront_secret
  }

  # Might not be needed but lets specify open cors anyways
  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive", "storefront-secret"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }

  # use_existing_cloudwatch_log_group = true
  source_path            = "${path.module}/lib/auth.js"
  architectures          = ["arm64"]                 # Arm is cheeaaaper
  vpc_subnet_ids         = module.vpc.public_subnets # Public access through public VPC subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  # Sets up rules for your service role
  assume_role_policy_statements = {
    account_root = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        account_principal = {
          type        = "AWS",
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      }
    }
  }
  allowed_triggers = {
    // Allows any invoker through the API Gateway
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:us-west-2:${data.aws_caller_identity.current.account_id}:*/*"
    }
  }
}

# Allows you to add the lambda to VPC
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = module.auth_lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
