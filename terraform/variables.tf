variable "bucket-name" {
  description = "The name of our bucket"
  type        = string
  default     = "bucketName"
  sensitive   = true
}

variable "db-username" {
  description = "The username of our db user"
  type        = string
  default     = "username"
  sensitive   = true
}

variable "db-name" {
  description = "The name of our db"
  type        = string
  default     = "storefrontDB"
  sensitive   = true
}