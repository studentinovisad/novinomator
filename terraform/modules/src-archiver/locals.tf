locals {
  basename               = basename(var.source_file)
  basename_extentionless = split(".", local.basename)[0]
  zipname                = "${local.basename}.zip"
}