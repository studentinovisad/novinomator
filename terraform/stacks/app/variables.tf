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
  description = "Path to the build containing all Cloudfront, S3 and Lambda code"
  type        = string
}

variable "redirector_path" {
  description = "Path to the source code containing redirector function code"
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

variable "whitelist" {
  description = "Set of whitelisted emails that can send email via the newsletter"
  type        = set(string)
}

variable "valid_topics" {
  description = "Set of valid topics that can be used"
  type        = set(string)
}
