locals {
  bucket_name = join("-", compact([var.bucket_name, one(random_password.suffix[*].result)]))

  // Get a list of all files in the assets folder, excluding hidden files
  assets_fileset = fileset(var.assets_path, "**/[!.]*")

  // Map of asset file names to their content types
  assets_with_content_type_map = {
    for asset in local.assets_fileset :
    asset => lookup(var.content_types, ".${split(".", asset)[length(split(".", asset)) - 1]}", "application/octet-stream")
  }

  // Top level files and folders (e.g. index.html, images/*)
  top_level_assets = toset([
    for asset in local.assets_fileset :
    length(split("/", asset)) == 1 ?
    "/${split("/", asset)[0]}" :
    "/${split("/", asset)[0]}/*"
  ])
}
