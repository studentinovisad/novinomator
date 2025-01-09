variable "aws_profile" {
  description = "The AWS profile to use for the aliased global provider"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used to generating resource names"
  type        = string
}

variable "domain_name" {
  description = "Domain name to use for Cloudfront and API Gateway"
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted zone ID of the wanted domain"
  type        = string
}

variable "source_code_path" {
  description = "Path to the source code containing all functions' code"
  type        = string
}

variable "ses_domain_name" {
  description = "Domain name to use for SES"
  type        = string
}

variable "ses_recipients" {
  description = "Set of recipients allowed to receive emails"
  type        = set(string)
}
