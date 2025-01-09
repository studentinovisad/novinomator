data "aws_region" "current" {}

locals {
  current_region          = data.aws_region.current.name
  bounce_mail_from_domain = "bounce.${aws_sesv2_email_identity.ses_identity.email_identity}"
  click_domain            = "click.${aws_sesv2_email_identity.ses_identity.email_identity}"
}
