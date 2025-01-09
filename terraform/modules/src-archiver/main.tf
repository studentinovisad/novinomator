data "archive_file" "zip" {
  type                    = "zip"
  source_content          = file(var.source_file)
  source_content_filename = local.basename
  output_path             = "${path.module}/tmp/${local.zipname}"
}
