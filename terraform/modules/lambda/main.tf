resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  handler       = "${var.handler_basename}.${var.handler_function}"
  runtime       = var.runtime
  role          = aws_iam_role.lambda.arn

  s3_bucket        = var.src_s3_bucket
  s3_key           = var.src_s3_key
  source_code_hash = var.src_hash

  architectures = [var.architecture]
  memory_size   = var.memory_size
  timeout       = var.timeout

  dynamic "snap_start" {
    for_each = var.snap_start ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  environment {
    variables = var.environment
  }
}
