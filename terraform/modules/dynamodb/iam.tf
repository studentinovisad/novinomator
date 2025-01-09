# SCAN
data "aws_iam_policy_document" "scan" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:Scan"]
    resources = ["${aws_dynamodb_table.table.arn}"]
  }
}

resource "aws_iam_policy" "scan" {
  name        = "${var.table_name}-scan-policy"
  description = "IAM policy for scanning rows inside the DynamoDB table"
  policy      = data.aws_iam_policy_document.scan.json
}

# QUERY
data "aws_iam_policy_document" "query" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:Query"]
    resources = ["${aws_dynamodb_table.table.arn}"]
  }
}

resource "aws_iam_policy" "query" {
  name        = "${var.table_name}-query-policy"
  description = "IAM policy for querying rows inside the DynamoDB table"
  policy      = data.aws_iam_policy_document.query.json
}

# GET ITEM
data "aws_iam_policy_document" "get_item" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem"]
    resources = ["${aws_dynamodb_table.table.arn}"]
  }
}

resource "aws_iam_policy" "get_item" {
  name        = "${var.table_name}-get-item-policy"
  description = "IAM policy for getting items inside the DynamoDB table"
  policy      = data.aws_iam_policy_document.get_item.json
}

# PUT ITEM
data "aws_iam_policy_document" "put_item" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = ["${aws_dynamodb_table.table.arn}"]
  }
}

resource "aws_iam_policy" "put_item" {
  name        = "${var.table_name}-put-item-policy"
  description = "IAM policy for putting items inside the DynamoDB table"
  policy      = data.aws_iam_policy_document.put_item.json
}

# DELETE ITEM
data "aws_iam_policy_document" "delete_item" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:DeleteItem"]
    resources = ["${aws_dynamodb_table.table.arn}"]
  }
}

resource "aws_iam_policy" "delete_item" {
  name        = "${var.table_name}-delete-item-policy"
  description = "IAM policy for deleting items inside the DynamoDB table"
  policy      = data.aws_iam_policy_document.delete_item.json
}

# UPDATE ITEM
data "aws_iam_policy_document" "update_item" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = ["${aws_dynamodb_table.table.arn}"]
  }
}

resource "aws_iam_policy" "update_item" {
  name        = "${var.table_name}-update-item-policy"
  description = "IAM policy for updating items inside the DynamoDB table"
  policy      = data.aws_iam_policy_document.update_item.json
}
