resource "aws_route53_record" "ses_dkim" {
  count = 3

  zone_id = var.hosted_zone_id
  name    = "${aws_sesv2_email_identity.ses_identity.dkim_signing_attributes.tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${aws_sesv2_email_identity.ses_identity.dkim_signing_attributes.tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses_mx" {
  zone_id = var.hosted_zone_id
  name    = aws_sesv2_email_identity.ses_identity.email_identity
  type    = "MX"
  ttl     = "1800"
  records = ["10 inbound-smtp.${local.current_region}.amazonaws.com"]
}

resource "aws_route53_record" "ses_bounce_mx" {
  zone_id = var.hosted_zone_id
  name    = local.bounce_mail_from_domain
  type    = "MX"
  ttl     = "1800"
  records = ["10 feedback-smtp.${local.current_region}.amazonses.com"]
}

resource "aws_route53_record" "ses_spf" {
  zone_id = var.hosted_zone_id
  name    = aws_sesv2_email_identity.ses_identity.email_identity
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "ses_bounce_spf" {
  zone_id = var.hosted_zone_id
  name    = local.bounce_mail_from_domain
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "ses_dmarc" {
  zone_id = var.hosted_zone_id
  name    = "_dmarc.${aws_sesv2_email_identity.ses_identity.email_identity}"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=none;"]
}

resource "aws_route53_record" "ses_tracking" {
  zone_id = var.hosted_zone_id
  name    = local.click_domain
  type    = "CNAME"
  ttl     = "1800"
  records = ["r.${local.current_region}.awstrack.me"]
}
