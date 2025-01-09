data "aws_region" "current" {}

locals {
  regional_domain_name = "${data.aws_region.current.name}.${var.domain_name}"
  routes_map           = { for route in var.routes : "${route.method}-${route.route}" => route }
}
