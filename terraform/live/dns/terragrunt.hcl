include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${path_relative_from_include()}/..//stacks/dns"
}

inputs = {
  aws_profile = include.root.locals.aws_profile
  environment = include.root.locals.environment
  domain_name = include.root.locals.domain_name

  dnssec  = true
  records = []
}
