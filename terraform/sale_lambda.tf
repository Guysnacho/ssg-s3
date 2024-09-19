data "aws_caller_identity" "current" {}

data "archive_file" "sale_package" {
  type        = "zip"
  source_dir  = "${path.module}/lib/sale/"
  output_path = "${path.module}/lib/sale/deployment_package.zip"
  excludes    = [".gitignore", "README.md", "testbench.js", "package-lock.json", "deployment_package.zip"]
}

module "sale_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.9.0"

  function_name      = "storefront-sale-lambda"
  description        = "Lambda for handling user login and signup requests"
  runtime            = "nodejs20.x"
  handler            = "index.handler"
  publish            = true
  authorization_type = "NONE"
  timeout            = 10
  # Without a zipped package
  # source_path            = "${path.module}/lib/sale/sale.js"
  # source_path  = "${path.module}/lib/sale/"

  local_existing_package = data.archive_file.package.output_path
  package_type           = "Zip"
  create_package         = false

  architectures = ["arm64"] # Arm is cheeaaaper
  # lambda_at_edge     = true

  # Environmental variables needed to log into database
  environment_variables = {
    db_host     = module.db.db_instance_endpoint
    db_username = var.db-username
    # Not an output of a normal RDS instance
    # db_password = module.db.cluster_master_password
    db_secret = module.db.db_instance_master_user_secret_arn
    secret    = var.cloudfront_secret
    # found this by running `terraform state show insert_module_here`
    # Replace `insert_module_here` with your specific instance from a `terraform state list`
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
  # VPC got in the way of public access https://repost.aws/questions/QU1WLg4Q2-TCqznkgmpPnW0g/getting-secret-from-lambda-times-out-when-attached-to-vpc-subnet
  # vpc_subnet_ids                     = module.vpc.public_subnets # Public access through public VPC subnets
  # vpc_security_group_ids             = [module.security_group.security_group_id]
  # replacement_security_group_ids     = [module.vpc.default_security_group_id]
  attach_network_policy              = true
  replace_security_groups_on_destroy = true
  create_lambda_function_url         = true

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

  attach_policy_statements = true
  policy_statements = {
    secret_read = {
      effect    = "Allow",
      actions   = ["secretsmanager:GetSecretValue", "secretsmanager:ListSecrets"],
      resources = ["*"]
    }
  }
  # allowed_triggers = {
  #   // Allows any invoker through the API Gateway
  #   APIGatewayAny = {
  #     service    = "apigateway"
  #     source_arn = "arn:aws:execute-api:us-west-2:${data.aws_caller_identity.current.account_id}:*/*/*/*"
  #   }
  # }
}

# Allows you to add the lambda to VPC
# resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
#   role       = module.sale_lambda.lambda_role_name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }
