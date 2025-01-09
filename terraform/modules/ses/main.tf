resource "aws_sesv2_email_identity" "ses_identity" {
  email_identity = var.domain_name

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }
}

resource "aws_sesv2_email_identity_mail_from_attributes" "ses_bounce" {
  email_identity         = aws_sesv2_email_identity.ses_identity.email_identity
  behavior_on_mx_failure = "REJECT_MESSAGE"
  mail_from_domain       = local.bounce_mail_from_domain
}

resource "aws_sesv2_email_identity_feedback_attributes" "example" {
  email_identity           = aws_sesv2_email_identity.ses_identity.email_identity
  email_forwarding_enabled = true
}

resource "aws_sesv2_account_suppression_attributes" "ses_suppression" {
  suppressed_reasons = ["BOUNCE", "COMPLAINT"]
}

resource "aws_sesv2_configuration_set" "ses_configuration_set" {
  configuration_set_name = "default"

  delivery_options {
    max_delivery_seconds = 300
    tls_policy           = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = true
  }

  sending_options {
    sending_enabled = true
  }

  suppression_options {
    suppressed_reasons = ["BOUNCE", "COMPLAINT"]
  }

  tracking_options {
    custom_redirect_domain = local.click_domain
    https_policy           = "REQUIRE"
  }
}

resource "aws_sesv2_configuration_set_event_destination" "ses_event_destination" {
  configuration_set_name = aws_sesv2_configuration_set.ses_configuration_set.configuration_set_name
  event_destination_name = "aws-ses"

  event_destination {
    cloud_watch_destination {
      dimension_configuration {
        default_dimension_value = "empty"
        dimension_name          = "MESSAGE_TAG"
        dimension_value_source  = "MESSAGE_TAG"
      }

      dimension_configuration {
        default_dimension_value = "empty"
        dimension_name          = "EMAIL_HEADER"
        dimension_value_source  = "EMAIL_HEADER"
      }

      dimension_configuration {
        default_dimension_value = "empty"
        dimension_name          = "LINK_TAG"
        dimension_value_source  = "LINK_TAG"
      }
    }

    enabled              = true
    matching_event_types = ["SEND", "REJECT", "BOUNCE", "COMPLAINT", "DELIVERY", "OPEN", "CLICK", "RENDERING_FAILURE", "DELIVERY_DELAY", "SUBSCRIPTION"]
  }
}

resource "aws_ses_receipt_rule_set" "rule_set" {
  rule_set_name = "receive"
}

resource "aws_ses_receipt_rule" "rule" {
  name          = "s3-and-lambda"
  rule_set_name = aws_ses_receipt_rule_set.rule_set.id
  recipients    = var.recipients
  enabled       = true
  scan_enabled  = true

  s3_action {
    position     = 1
    bucket_name  = var.bucket_name
    iam_role_arn = aws_iam_role.ses_role.arn
  }

  lambda_action {
    position        = 2
    function_arn    = var.lambda_arn
    invocation_type = "Event"
  }

  depends_on = [ aws_lambda_permission.ses_invoke ]
}

resource "aws_ses_active_receipt_rule_set" "active_rule_set" {
  rule_set_name = aws_ses_receipt_rule_set.rule_set.id
}
