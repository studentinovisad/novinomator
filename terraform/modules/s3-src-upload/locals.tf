locals {
  bucket_name = join("-", compact([var.bucket_name, one(random_password.suffix[*].result)]))
}