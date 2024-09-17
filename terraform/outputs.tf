output "s3_bucket-region" {
  value       = module.s3_bucket.s3_bucket_region
  description = "Current S3 region"
  sensitive   = true
}

output "s3_bucket-arn" {
  value       = module.s3_bucket.s3_bucket_arn
  description = "Current S3 arn"
  sensitive   = true
}

output "db-arn" {
  value       = module.db.cluster_arn
  description = "DB cluster arn"
  sensitive   = true
}

output "db-port" {
  value       = module.db.cluster_port
  description = "DB cluster port"
  sensitive   = true
}

output "db-username" {
  value       = module.db.cluster_master_username
  description = "DB cluster username"
  sensitive   = true
}

output "db-endpoint" {
  value       = module.db.cluster_endpoint
  description = "DB cluster endpoint"
  sensitive   = true
}

output "db-name" {
  value       = module.db.cluster_database_name
  description = "DB cluster address"
  sensitive   = true
}
