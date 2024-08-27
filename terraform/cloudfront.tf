module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.0"

  comment             = "CDN for AWS S3 site."
  default_root_object = "index.html"
  # Helpful if you want to use this distribution as a "test" deployment before deploying to production
  #   staging = true

  create_origin_access_control = true
  origin = {
    s3_oac = { # with origin access control settings (recommended)
      domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control    = "s3_oac"
      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id # external OAС resource
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-west-2"
      }
    }

    s3_oac2 = { # with origin access control settings (recommended)
      domain_name              = module.failover_s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control    = "s3_oac2"
      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_shield = {
        enabled              = true
        origin_shield_region = "us-west-2"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_oac"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = true
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
