resource "aws_iam_role" "ses_role" {
  name = "${var.domain_name}-ses-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ses.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ses_bucket_policy_attachment" {
  role       = aws_iam_role.ses_role.name
  policy_arn = var.bucket_policy_arn
}

resource "aws_lambda_permission" "ses_invoke" {
  statement_id  = "AllowSESInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "ses.amazonaws.com"
  function_name = var.lambda_function_name
}

data "aws_iam_policy_document" "send_email" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = ["arn:aws:ses:eu-central-1:491085392196:identity/*"]
  }
}

resource "aws_iam_policy" "send_email" {
  name        = "${var.domain_name}-ses-identity-policy"
  description = "IAM policy for sending email via SES for Lambda"
  policy      = data.aws_iam_policy_document.send_email.json
}
