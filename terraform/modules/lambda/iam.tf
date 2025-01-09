data "aws_iam_policy_document" "execute" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.execute.json
}

data "aws_iam_policy_document" "logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "logging" {
  name        = "${var.function_name}-logging-policy"
  path        = "/"
  description = "IAM policy for logging by Lambda"
  policy      = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment_dynamodb" {
  count = length(var.policy_attachment_arns)

  role       = aws_iam_role.lambda.name
  policy_arn = var.policy_attachment_arns[count.index]
}
