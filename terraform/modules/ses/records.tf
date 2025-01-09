resource "aws_route53_record" "ses_verification" {
  zone_id = var.hosted_zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.ses.verification_token]
}

resource "aws_route53_record" "ses_dkim" {
  count   = 3
  
  zone_id = var.hosted_zone_id
  name    = "${aws_ses_domain_dkim.example.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.example.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_mx" {
  zone_id = var.hosted_zone_id
  name    = aws_ses_domain_identity.ses.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${local.current_region}.amazonaws.com"]
}

resource "aws_route53_record" "ses_bounce_mx" {
  zone_id = var.hosted_zone_id
  name    = aws_ses_domain_mail_from.ses_bounce.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${local.current_region}.amazonses.com"]
}

resource "aws_route53_record" "ses_bounce_spf" {
  zone_id = var.hosted_zone_id
  name    = aws_ses_domain_mail_from.ses_bounce.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}
