variable "domain_name" {
  description = "The domain name to create Route53 zone and DNS records for"
  type        = string
}

variable "hosted_zone_id" {
  description = "The hosted zone ID of the wanted domain"
  type        = string
}

variable "recipients" {
  description = "Set of recipients allowed to receive emails"
  type        = set(string)
}

variable "bucket_name" {
  description = "The name of the bucket used to store received emails"
  type        = string
}

variable "bucket_policy_arn" {
  description = "The ARN of the bucket role with permissions to store received emails"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda to trigger on email received"
  type        = string
}

variable "lambda_arn" {
  description = "The ARN of the Lambda to trigger on email received"
  type        = string
}
