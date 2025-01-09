output "basename" {
  value = local.basename
}

output "basename_extentionless" {
  value = local.basename_extentionless
}

output "zipname" {
  value = local.zipname
}

output "content_base64" {
  value     = filebase64(data.archive_file.zip.output_path)
  sensitive = true # Don't output huge string
}

output "content_base64sha256" {
  value = data.archive_file.zip.output_base64sha256
}
