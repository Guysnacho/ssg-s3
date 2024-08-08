module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  bucket  = var.bucket-name

  # policy = jsonencode({
  #   "Version" : "2012-10-17",
  #   "Statement" : [
  #     {
  #       "Sid" : "PublicReadGetObject",
  #       "Effect" : "Allow",
  #       "Principal" : "*",
  #       "Action" : "s3:GetObject",
  #       "Resource" : "arn:aws:s3:::${var.bucket-name}/*"
  #     }
  #   ]
  # })

  # acl                      = "public-read"
  # attach_policy            = true
  # ignore_public_acls       = false
  # restrict_public_buckets  = false
  # control_object_ownership = true
  # object_ownership         = "BucketOwnerPreferred"
  force_destroy = true
}

data "aws_iam_policy_document" "s3_policy" {
  # Origin Access Identities
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }

  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
