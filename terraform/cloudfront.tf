module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.0"

  comment = "CDN for AWS S3 site."
  default_root_object = "./index.html"
  # Helpful if you want to use this distribution as a "test" deployment before deploying to production
  #   staging = true

  # create_origin_access_identity = true
  # origin_access_identities = {
  #   s3_bucket = module.s3_bucket.s3_bucket_id
  # }

  create_origin_access_control = true
  # origin_access_control = {
  #   s3_oac = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  origin = {

    # appsync = {
    #   domain_name = module.s3_bucket.s3_bucket_bucket_domain_name
    #   custom_origin_config = {
    #     http_port              = 80
    #     https_port             = 443
    #     origin_protocol_policy = "match-viewer"
    #     origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    #   }

    #   custom_header = [
    #     {
    #       name  = "X-Forwarded-Scheme"
    #       value = "https"
    #     },
    #     {
    #       name  = "X-Frame-Options"
    #       value = "SAMEORIGIN"
    #     }
    #   ]

    #   origin_shield = {
    #     enabled              = true
    #     origin_shield_region = "us-west-2"
    #   }
    # }

    s3_oac = { # with origin access control settings (recommended)
      domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control    = "s3_oac"                                               # key in `origin_access_control`
      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id # "E345SXM82MIOSU" # external OAС resource
    }

    s3_oac2 = { # with origin access control settings (recommended)
      domain_name              = module.failover_s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control    = "s3_oac2"                                              # key in `origin_access_control`
      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id # "E345SXM82MIOSU" # external OAС resource
    }
  }

  # origin_group = {
  #   group_one = {
  #     failover_status_codes      = [403, 404, 500, 502]
  #     primary_member_origin_id   = "s3_oac"
  #     domain_name                = module.s3_bucket.s3_bucket_bucket_regional_domain_name
  #   }
  # }

  default_cache_behavior = {
    target_origin_id       = "s3_oac"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = true

    # cache_policy_id            = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
    # response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"

  }

  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_100" # Price Classes https://aws.amazon.com/cloudfront/pricing/#:~:text=China%20pricing%20page.%20%3E%3E-,Price%20Class,-Price%20classes%20provide

}
resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "s3_oac"
  origin_access_control_origin_type = "s3"
  description                       = "CloudFront access to S3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
