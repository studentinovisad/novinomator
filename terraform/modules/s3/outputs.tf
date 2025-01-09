output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "policy_get_object_arn" {
  value = aws_iam_policy.get_object.arn
}

output "policy_put_object_arn" {
  value = aws_iam_policy.put_object.arn
}
