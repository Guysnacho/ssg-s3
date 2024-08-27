variable "bucket-name" {
  description = "The name of our bucket"
  type        = string
  default     = "bucketName"
  sensitive   = true
}

variable "organization" {
  description = "The name of my organization"
  type        = string
  default     = "organization"
  sensitive   = true
}
