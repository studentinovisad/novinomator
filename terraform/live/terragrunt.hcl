locals {
  aws_profile = "blokada_info"
  environment = "prod"
  domain_name = local.environment == "prod" ? "blokada.info" : "${local.environment}.blokada.info"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "blokada-info-shared-${local.environment}-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    profile        = local.aws_profile
    dynamodb_table = "blokada-info-shared-${local.environment}-tf-state-lock"
    encrypt        = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  profile = "${local.aws_profile}"
  region  = "eu-central-1"
}
EOF
}
