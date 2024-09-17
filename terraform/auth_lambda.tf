locals {
  package_url = "https://required_packages_to_run_lambda_code.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

module "auth_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.9.0"

  function_name = "storefront-auth-lambda"
  runtime       = "nodejs20.x"
  handler       = "auth.handler"
  publish       = true
  environment_variables = {
    db_host     = module.db.cluster_endpoint
    db_username = var.db-username
    db_password = module.db.cluster_master_password
    db_name     = var.db-name
    secret      = var.cloudfront_secret
  }

  # use_existing_cloudwatch_log_group = true
  source_path            = "${path.module}/lib/auth.js"
  architectures          = ["arm64"]
  vpc_subnet_ids         = module.vpc.public_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
}
