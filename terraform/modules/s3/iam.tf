data "aws_iam_policy_document" "get_object" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}", "${aws_s3_bucket.bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "get_object" {
  name        = "${local.bucket_name}-get-object-policy"
  path        = "/"
  description = "IAM policy for reading objects inside the S3 bucket"
  policy      = data.aws_iam_policy_document.get_object.json
}

data "aws_iam_policy_document" "put_object" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "put_object" {
  name        = "${local.bucket_name}-put-object-policy"
  path        = "/"
  description = "IAM policy for putting objects inside the S3 bucket"
  policy      = data.aws_iam_policy_document.put_object.json
}