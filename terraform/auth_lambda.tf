locals {
  package_url = "https://required_packages_to_run_lambda_code.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

module "auth_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.9.0"

  function_name = "storefront-auth-lambda"
  runtime       = "nodejs20.9"
  handler       = "index.js"

  # use_existing_cloudwatch_log_group = true
  
}