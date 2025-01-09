include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${path_relative_from_include()}/..//stacks/app"
}

dependency "dns" {
  config_path = "../dns"
}

inputs = {
  aws_profile      = include.root.locals.aws_profile
  project_name     = "novinomator"
  domain_name      = "newsletter.${include.root.locals.domain_name}"
  hosted_zone_id   = dependency.dns.outputs.hosted_zone_id
  source_code_path = "../../src"
  ses_domain_name  = include.root.locals.domain_name
  ses_recipients   = ["newsletter@${include.root.locals.domain_name}"]
}
