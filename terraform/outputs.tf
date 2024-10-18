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
  value       = module.db.db_instance_arn
  description = "DB arn"
  sensitive   = true
}

output "db-port" {
  value       = module.db.db_instance_port
  description = "DB port"
  sensitive   = true
}

output "db-username" {
  value       = module.db.db_instance_username
  description = "DB username"
  sensitive   = true
}

output "db-endpoint" {
  value       = module.db.db_instance_endpoint
  description = "DB endpoint"
  sensitive   = true
}

output "db-name" {
  value       = var.db-name
  description = "DB name"
  sensitive   = true
}

output "api-route" {
  value       = module.gateway.api_endpoint
  description = "API gateway url"
  sensitive   = true
}

output "ecr-push-url" {
  value       = module.public_ecr.repository_url
  description = "ECR Repository URL"
  sensitive   = true
}
