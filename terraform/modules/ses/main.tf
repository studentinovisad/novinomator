resource "aws_ses_domain_identity" "ses" {
  domain = var.domain_name
}

resource "aws_ses_domain_dkim" "ses_dkim" {
  domain = aws_ses_domain_identity.ses.domain
}

resource "aws_ses_domain_mail_from" "ses_bounce" {
  domain           = aws_ses_domain_identity.ses.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.ses.domain}"
}
