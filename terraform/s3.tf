module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  bucket  = var.bucket-name

  policy = data.aws_iam_policy_document.s3_policy.json
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  attach_policy      = true
  ignore_public_acls = false
  # restrict_public_buckets  = false
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
  block_public_acls        = false
  force_destroy            = true
}

module "failover_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  bucket  = "${var.bucket-name}-failover"

  policy = data.aws_iam_policy_document.failover_s3_policy.json
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  acl                = "public-read"
  attach_policy      = true
  ignore_public_acls = false
  # restrict_public_buckets  = false
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  block_public_acls        = false
  force_destroy            = true
}

data "aws_iam_policy_document" "s3_policy" {
  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
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

data "aws_iam_policy_document" "failover_s3_policy" {
  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${module.failover_s3_bucket.s3_bucket_arn}/*"]
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
