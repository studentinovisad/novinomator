resource "random_password" "suffix" {
  count = var.bucket_name_suffix ? 1 : 0

  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}
