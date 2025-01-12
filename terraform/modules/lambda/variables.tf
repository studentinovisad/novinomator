variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler_basename" {
  description = "The file basename for the entry point of the Lambda function"
  type        = string
}

variable "handler_function" {
  description = "The function name for the entry point of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime of the Lambda function"
  type        = string
}

variable "src_s3_bucket" {
  description = "The S3 bucket where the Lambda function code is stored"
  type        = string
}

variable "src_s3_key" {
  description = "The S3 key where the Lambda function code is stored"
  type        = string
}

variable "src_hash" {
  description = "The hash of the Lambda function code"
  type        = string
}

variable "architecture" {
  description = "The architecture of the Lambda function"
  type        = string
  default     = "arm64"
}

variable "memory_size" {
  description = "The memory size of the Lambda function"
  type        = number
  default     = 1769
}

variable "timeout" {
  description = "The timeout of the Lambda function"
  type        = number
  default     = 10
}

variable "environment" {
  description = "The environment variables of the Lambda function, ignored for Lambda@Edge"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "keep_warm" {
  description = "Whether to keep the Lambda function warm by invoking it every 5 minutes"
  type        = bool
  default     = false
}

variable "snap_start" {
  description = "Whether to enable snap start"
  type        = bool
  default     = false
}

variable "policy_attachment_arns" {
  description = "Additional policy arns to attach to the Lambda role"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.policy_attachment_arns) == length(distinct(var.policy_attachment_arns))
    error_message = "Duplicate arns are not allowed"
  }
}
