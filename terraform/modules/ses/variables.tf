variable "domain_name" {
  description = "The domain name to create Route53 zone and DNS records for"
  type        = string
}

variable "hosted_zone_id" {
  description = "The hosted zone ID of the wanted domain"
  type        = string
}
