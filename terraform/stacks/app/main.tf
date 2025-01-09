module "s3_email_archive" {
  source = "../../modules/s3"

  bucket_name = "${var.project_name}-email-archive"
}

module "dynamodb_subscriptions" {
  source = "../../modules/dynamodb"

  table_name = "${var.project_name}-subscriptions"
  attributes = [
    {
      name     = "email"
      type     = "S"
      hash_key = true
    }
  ]
}

module "dynamodb_confirm_subscriptions" {
  source = "../../modules/dynamodb"

  table_name = "${var.project_name}-confirm-subscriptions"
  attributes = [
    {
      name     = "uuid"
      type     = "S"
      hash_key = true
    }
  ]
}

module "dynamodb_confirm_unsubscriptions" {
  source = "../../modules/dynamodb"

  table_name = "${var.project_name}-confirm-unsubscriptions"
  attributes = [
    {
      name     = "uuid"
      type     = "S"
      hash_key = true
    }
  ]
}

# Redirector
module "src_archiver_redirector" {
  source = "../../modules/src-archiver"

  source_file = "${var.source_code_path}/redirector.py"
}

module "s3_src_upload_redirector" {
  source = "../../modules/s3-src-upload"

  bucket_name          = "${var.project_name}-redirector-src"
  filename             = module.src_archiver_redirector.zipname
  content_base64       = module.src_archiver_redirector.content_base64
  content_base64sha256 = module.src_archiver_redirector.content_base64sha256
}

module "lambda_redirector" {
  source = "../../modules/lambda"

  function_name    = "${var.project_name}-redirector"
  handler_basename = module.src_archiver_redirector.basename_extentionless

  src_s3_bucket = module.s3_src_upload_redirector.bucket_id
  src_s3_key    = module.s3_src_upload_redirector.s3_key
  src_hash      = module.s3_src_upload_redirector.source_code_hash

  policy_attachment_arns = [
    module.s3_email_archive.policy_get_object_arn,
    module.dynamodb_subscriptions.policy_scan_arn
  ]

  environment = {
    "WHITELIST" = join(",", var.whitelist)
    "SENDER_EMAIL" = "no-reply@${var.domain_name}"
    "BUCKET_NAME" = module.s3_email_archive.bucket_id
    "SUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_subscriptions.dynamodb_table_name
    "UNSUBSCRIBE_URL" = "https://${var.domain_name}/unsubscribe"
    "VALID_TOPICS" = join(",", var.valid_topics)
  }
}

# Subscribe
module "src_archiver_subscribe" {
  source = "../../modules/src-archiver"

  source_file = "${var.source_code_path}/subscribe.py"
}

module "s3_src_upload_subscribe" {
  source = "../../modules/s3-src-upload"

  bucket_name          = "${var.project_name}-subscribe-src"
  filename             = module.src_archiver_subscribe.zipname
  content_base64       = module.src_archiver_subscribe.content_base64
  content_base64sha256 = module.src_archiver_subscribe.content_base64sha256
}

module "lambda_subscribe" {
  source = "../../modules/lambda"

  function_name    = "${var.project_name}-subscribe"
  handler_basename = module.src_archiver_subscribe.basename_extentionless

  src_s3_bucket = module.s3_src_upload_subscribe.bucket_id
  src_s3_key    = module.s3_src_upload_subscribe.s3_key
  src_hash      = module.s3_src_upload_subscribe.source_code_hash

  policy_attachment_arns = [
    module.dynamodb_confirm_subscriptions.policy_get_item_arn,
    module.dynamodb_confirm_subscriptions.policy_delete_item_arn,
    module.dynamodb_subscriptions.policy_put_item_arn
  ]

  environment = {
    "CONFIRM_SUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_confirm_subscriptions.dynamodb_table_name
    "SUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_subscriptions.dynamodb_table_name
  }
}

# Confirm Subscribe
module "src_archiver_confirm_subscribe" {
  source = "../../modules/src-archiver"

  source_file = "${var.source_code_path}/confirm-subscribe.py"
}

module "s3_src_upload_confirm_subscribe" {
  source = "../../modules/s3-src-upload"

  bucket_name          = "${var.project_name}-confirm-subscribe-src"
  filename             = module.src_archiver_confirm_subscribe.zipname
  content_base64       = module.src_archiver_confirm_subscribe.content_base64
  content_base64sha256 = module.src_archiver_confirm_subscribe.content_base64sha256
}

module "lambda_confirm_subscribe" {
  source = "../../modules/lambda"

  function_name    = "${var.project_name}-confirm-subscribe"
  handler_basename = module.src_archiver_confirm_subscribe.basename_extentionless

  src_s3_bucket = module.s3_src_upload_confirm_subscribe.bucket_id
  src_s3_key    = module.s3_src_upload_confirm_subscribe.s3_key
  src_hash      = module.s3_src_upload_confirm_subscribe.source_code_hash

  policy_attachment_arns = [
    module.dynamodb_confirm_subscriptions.policy_put_item_arn
  ]

  environment = {
    "CONFIRM_SUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_confirm_subscriptions.dynamodb_table_name
    "SENDER_EMAIL" = "no-reply@${var.domain_name}"
    "SUBSCRIBE_URL" = "https://${var.domain_name}/subscribe/verify"
    "TTL" = "3600"
  }
}

# Unsubscribe
module "src_archiver_unsubscribe" {
  source = "../../modules/src-archiver"

  source_file = "${var.source_code_path}/unsubscribe.py"
}

module "s3_src_upload_unsubscribe" {
  source = "../../modules/s3-src-upload"

  bucket_name          = "${var.project_name}-unsubscribe-src"
  filename             = module.src_archiver_unsubscribe.zipname
  content_base64       = module.src_archiver_unsubscribe.content_base64
  content_base64sha256 = module.src_archiver_unsubscribe.content_base64sha256
}

module "lambda_unsubscribe" {
  source = "../../modules/lambda"

  function_name    = "${var.project_name}-unsubscribe"
  handler_basename = module.src_archiver_unsubscribe.basename_extentionless

  src_s3_bucket = module.s3_src_upload_unsubscribe.bucket_id
  src_s3_key    = module.s3_src_upload_unsubscribe.s3_key
  src_hash      = module.s3_src_upload_unsubscribe.source_code_hash

  policy_attachment_arns = [
    module.dynamodb_confirm_unsubscriptions.policy_get_item_arn,
    module.dynamodb_confirm_unsubscriptions.policy_delete_item_arn,
    module.dynamodb_subscriptions.policy_delete_item_arn
  ]

  environment = {
    "CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_confirm_unsubscriptions.dynamodb_table_name
    "SUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_subscriptions.dynamodb_table_name
  }
}

# Confirm Unsubscribe
module "src_archiver_confirm_unsubscribe" {
  source = "../../modules/src-archiver"

  source_file = "${var.source_code_path}/confirm-unsubscribe.py"
}

module "s3_src_upload_confirm_unsubscribe" {
  source = "../../modules/s3-src-upload"

  bucket_name          = "${var.project_name}-confirm-unsubscribe-src"
  filename             = module.src_archiver_confirm_unsubscribe.zipname
  content_base64       = module.src_archiver_confirm_unsubscribe.content_base64
  content_base64sha256 = module.src_archiver_confirm_unsubscribe.content_base64sha256
}

module "lambda_confirm_unsubscribe" {
  source = "../../modules/lambda"

  function_name    = "${var.project_name}-confirm-unsubscribe"
  handler_basename = module.src_archiver_confirm_unsubscribe.basename_extentionless

  src_s3_bucket = module.s3_src_upload_confirm_unsubscribe.bucket_id
  src_s3_key    = module.s3_src_upload_confirm_unsubscribe.s3_key
  src_hash      = module.s3_src_upload_confirm_unsubscribe.source_code_hash

  policy_attachment_arns = [
    module.dynamodb_confirm_unsubscriptions.policy_put_item_arn
  ]

  environment = {
    "CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_confirm_unsubscriptions.dynamodb_table_name
    "SENDER_EMAIL" = "no-reply@${var.domain_name}"
    "SUBSCRIBE_URL" = "https://${var.domain_name}/unsubscribe/verify"
    "TTL" = "3600"
  }
}

module "acm_certificate_apigateway" {
  source = "../../modules/acm-certificate"

  domain_name               = local.apigateway_domain_name
  subject_alternative_names = [local.apigateway_regional_domain_name]
  hosted_zone_id            = var.hosted_zone_id
}

module "apigateway_gateway" {
  source = "../../modules/apigateway"

  gateway_name        = "${var.project_name}-api-gateway"
  domain_name         = local.apigateway_domain_name
  hosted_zone_id      = var.hosted_zone_id
  acm_certificate_arn = module.acm_certificate_apigateway.cert_arn

  routes = local.routes
}

module "acm_certificate_cloudfront" {
  source = "../../modules/acm-certificate"

  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id

  providers = {
    aws = aws.global
  }
}

module "cloudfront_cdn" {
  source = "../../modules/cloudfront"

  cloudfront_name     = "${var.project_name}-cdn"
  domain_name         = var.domain_name
  hosted_zone_id      = var.hosted_zone_id
  acm_certificate_arn = module.acm_certificate_cloudfront.cert_arn

  default_cache_behavior = {
    # target_origin_id = "s3"
    target_origin_id = "gateway"
  }

  ordered_cache_behaviors = [
    for route in local.routes : {
      path_pattern     = route.route
      target_origin_id = "gateway"
      allowed_methods  = ["HEAD", "GET", "OPTIONS", "DELETE", "POST", "PUT", "PATCH"]
    }
  ]

  origins = [
    # {
    #   origin_id = "s3"
    #   origin_type = "s3"
    #   domain_name = ""
    #   s3_oai_id = ""
    # },
    {
      origin_id   = "gateway"
      origin_type = "custom"
      domain_name = module.apigateway_gateway.target_domain_name
    }
  ]

  providers = {
    aws = aws.global
  }
}

module "ses" {
  source = "../../modules/ses"

  domain_name     = var.ses_domain_name
  hosted_zone_id  = var.hosted_zone_id
  bucket_name     = module.s3_email_archive.bucket_id
  bucket_policy_arn = module.s3_email_archive.policy_put_object_arn
  lambda_function_name = module.lambda_redirector.function_name
  lambda_arn      = module.lambda_redirector.arn
  recipients      = var.ses_recipients
}
