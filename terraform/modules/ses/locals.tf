data "aws_region" "current" {}

locals {
    current_region = data.aws_region.current.name
}
