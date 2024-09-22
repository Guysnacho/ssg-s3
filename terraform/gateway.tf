module "gateway" {
  source        = "terraform-aws-modules/apigateway-v2/aws"
  name          = "Storefront Gateway"
  description   = "Gateway for allowing requests from our storefront to talk to AWS resources."
  protocol_type = "HTTP"

  domain_name = "supercool.real.com"
}
