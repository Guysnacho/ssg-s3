module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  bucket  = "black-belt-init-ssg-s3"


  block_public_acls       = true
  restrict_public_buckets = false
  force_destroy           = true
}
