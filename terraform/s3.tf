module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  bucket  = var.bucket-name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "PublicReadGetObject",
            "Effect" : "Allow",
            "Principal" : "*",
            "Action" : "s3:GetObject",
            "Resource" : "arn:aws:s3:::${var.bucket-name}/*"
          }
        ]
      }
    ]
  })
  block_public_acls       = false
  attach_public_policy    = true
  restrict_public_buckets = false
  object_ownership        = "BucketOwnerPreferred"

  force_destroy = true
}
