variable "bucket_name" {
  description = "The name of the S3 bucket, the region and account ID will be appended to this name"
  type        = string
}

variable "bucket_name_suffix" {
  description = "Used to obfuscate the bucket name"
  type        = bool
  default     = true
}
