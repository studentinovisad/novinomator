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

  dnssec = true
  records = [
    // Email
    {
      name    = "",
      type    = "MX",
      ttl     = 300,
      records = ["10 inbound-smtp.eu-central-1.amazonaws.com"]
    },
    {
      name    = "mail",
      type    = "MX",
      ttl     = 300,
      records = ["10 feedback-smtp.eu-central-1.amazonses.com"]
    },
    {
      name    = "2pwqjxfiosrrqjuvcrwtgafu2eshm5bw._domainkey",
      type    = "CNAME",
      ttl     = 1800,
      records = ["2pwqjxfiosrrqjuvcrwtgafu2eshm5bw.dkim.amazonses.com"]
    },
    {
      name    = "cqnz4qn4bt7dyvhkejjbq6nz2ug5yda6._domainkey",
      type    = "CNAME",
      ttl     = 1800,
      records = ["cqnz4qn4bt7dyvhkejjbq6nz2ug5yda6.dkim.amazonses.com"]
    },
    {
      name    = "n37t5mcgqxzmoodaz6ltsqlcx3s3yvfn._domainkey",
      type    = "CNAME",
      ttl     = 1800,
      records = ["n37t5mcgqxzmoodaz6ltsqlcx3s3yvfn.dkim.amazonses.com"]
    },
    {
      name    = "_dmarc",
      type    = "TXT",
      ttl     = 300,
      records = ["v=DMARC1; p=none;"]
    },
    {
      name    = "",
      type    = "TXT",
      ttl     = 300,
      records = ["v=spf1 include:amazonses.com ~all"]
    },
    {
      name    = "mail",
      type    = "TXT",
      ttl     = 300,
      records = ["v=spf1 include:amazonses.com ~all"]
    }
  ]
}
