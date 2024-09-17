variable "bucket-name" {
  description = "The name of our bucket"
  type        = string
  default     = "bucketName"
  sensitive   = true
}

variable "db-name" {
  description = "The name of our db"
  type        = string
  default     = "storefront"
  sensitive   = true
}

variable "db-username" {
  description = "The username of our db user"
  type        = string
  default     = "username"
  sensitive   = true
}

# variable "db-password" {
#   description = "The password of our db user"
#   type        = string
#   default     = "top_secret"
#   sensitive   = true
# }

variable "cloudfront_secret" {
  description = "Secret to be included in header and crosschecked in lambdas"
  type        = string
  default     = "blaaaahhh"
  sensitive   = true
}
