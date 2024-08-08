output "s3_bucket-region" {
  value       = module.s3_bucket.s3_bucket_region
  description = "Current S3 region"
  sensitive = true
}

output "s3_bucket-arn" {
  value       = module.s3_bucket.s3_bucket_arn
  description = "Current S3 arn"
  sensitive = true
}
