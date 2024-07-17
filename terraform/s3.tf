module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  bucket  = var.bucket-name

  policy = jsonencode({
    "Version" : "2024-07-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket-name}/*"
        ]
      }
    ]
  })
  block_public_acls        = true
  restrict_public_buckets  = false
  control_object_ownership = false
  force_destroy            = true
}
