output "s3-bucket-region" {
  value       = module.s3-bucket.s3_bucket_region
  description = "Current S3 region"
  sensitive = true
}

output "s3-bucket-arn" {
  value       = module.s3-bucket.s3_bucket_arn
  description = "Current S3 arn"
  sensitive = true
}
