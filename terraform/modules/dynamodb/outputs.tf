output "dynamodb_table_name" {
  value = aws_dynamodb_table.table.name
}

output "policy_scan_arn" {
  value = aws_iam_policy.scan.arn
}

output "policy_query_arn" {
  value = aws_iam_policy.query.arn
}

output "policy_get_item_arn" {
  value = aws_iam_policy.get_item.arn
}

output "policy_put_item_arn" {
  value = aws_iam_policy.put_item.arn
}

output "policy_delete_item_arn" {
  value = aws_iam_policy.delete_item.arn
}

output "policy_update_item_arn" {
  value = aws_iam_policy.update_item.arn
}

output "policy_gpdu_item_arn" {
  value = aws_iam_policy.gpdu_item.arn
}

output "policy_all_item_arn" {
  value = aws_iam_policy.all_item.arn
}