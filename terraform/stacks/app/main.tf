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

module "src_archiver_redirector" {
  source = "../../modules/src-archiver"

  source_file = "${var.redirector_path}"
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
  runtime          = "python3.13"
  handler_basename = module.src_archiver_redirector.basename_extentionless
  handler_function = "lambda_handler"

  src_s3_bucket = module.s3_src_upload_redirector.bucket_id
  src_s3_key    = module.s3_src_upload_redirector.s3_key
  src_hash      = module.s3_src_upload_redirector.source_code_hash

  policy_attachment_arns = [
    module.s3_email_archive.policy_get_object_arn,
    module.dynamodb_subscriptions.policy_scan_arn,
    module.ses.policy_send_email_arn
  ]

  environment = {
    "WHITELIST"                = join(",", var.whitelist)
    "SENDER_EMAIL"             = "no-reply@${var.domain_name}"
    "BUCKET_NAME"              = module.s3_email_archive.bucket_id
    "SUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_subscriptions.dynamodb_table_name
    "UNSUBSCRIBE_URL"          = "https://${var.domain_name}/unsubscribe"
    "VALID_TOPICS"             = join(",", var.valid_topics)
  }
}

module "src_archiver_sveltekit" {
  source = "../../modules/src-archiver"

  source_file = "${var.source_code_path}/lambda/index.mjs"
}

module "s3_src_upload_sveltekit" {
  source = "../../modules/s3-src-upload"

  bucket_name          = "${var.project_name}-sveltekit-src"
  filename             = module.src_archiver_sveltekit.zipname
  content_base64       = module.src_archiver_sveltekit.content_base64
  content_base64sha256 = module.src_archiver_sveltekit.content_base64sha256
}

module "lambda_sveltekit" {
  source = "../../modules/lambda"

  function_name    = "${var.project_name}-sveltekit"
  runtime          = "nodejs20.x"
  handler_basename = module.src_archiver_sveltekit.basename_extentionless
  handler_function = "handler"
  keep_warm        = true

  src_s3_bucket = module.s3_src_upload_sveltekit.bucket_id
  src_s3_key    = module.s3_src_upload_sveltekit.s3_key
  src_hash      = module.s3_src_upload_sveltekit.source_code_hash

  policy_attachment_arns = [
    module.ses.policy_send_email_arn,
    module.dynamodb_subscriptions.policy_gpdu_item_arn,
    module.dynamodb_confirm_subscriptions.policy_gpdu_item_arn,
    module.dynamodb_confirm_unsubscriptions.policy_gpdu_item_arn,
  ]

  environment = {
    "ORIGIN"                             = "https://${var.domain_name}"
    "SENDER_EMAIL"                       = "no-reply@${var.domain_name}"
    "TOPICS"                             = join(",", var.valid_topics)
    "VERIFY_TTL"                         = "3600"
    "SUBSCRIPTIONS_TABLE_NAME"           = module.dynamodb_subscriptions.dynamodb_table_name
    "CONFIRM_SUBSCRIPTIONS_TABLE_NAME"   = module.dynamodb_confirm_subscriptions.dynamodb_table_name
    "CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME" = module.dynamodb_confirm_unsubscriptions.dynamodb_table_name
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

module "s3_static_assets_bucket" {
  source = "../../modules/s3-static-assets-upload"

  bucket_name = "${var.project_name}-static-assets"
  assets_path = "${var.source_code_path}/s3"
}

module "cloudfront_cdn" {
  source = "../../modules/cloudfront"

  cloudfront_name     = "${var.project_name}-cdn"
  domain_name         = var.domain_name
  hosted_zone_id      = var.hosted_zone_id
  acm_certificate_arn = module.acm_certificate_cloudfront.cert_arn

  additional_origin_request_header_items = ["X-Forwarded-Host"]
  additional_cache_header_items          = ["X-Forwarded-Host"]

  default_cache_behavior = {
    target_origin_id = local.apigateway_origin_id
    allowed_methods  = ["HEAD", "GET", "OPTIONS", "DELETE", "POST", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET"]

    function_associations = [{
      name    = "sveltekit-rewriter"
      content = local.cloudfront_sveltekit_rewriter
    }]
  }

  ordered_cache_behaviors = concat(
    [
      for route in module.s3_static_assets_bucket.top_level_assets : {
        path_pattern     = route
        target_origin_id = local.s3_static_assets_origin_id
        allowed_methods  = ["HEAD", "GET", "OPTIONS"]
        cached_methods   = ["HEAD", "GET"]
      }
    ],
    [
      # for route in local.routes : {
      #   path_pattern     = route.route
      #   target_origin_id = local.apigateway_origin_id
      #   allowed_methods  = ["HEAD", "GET", "OPTIONS", "DELETE", "POST", "PUT", "PATCH"]
      #   cached_methods   = ["HEAD", "GET"]

      #   function_associations = [{
      #     name    = "sveltekit-rewriter"
      #     content = local.cloudfront_sveltekit_rewriter
      #   }]
      # }
    ]
  )

  origins = [
    {
      origin_id = local.s3_static_assets_origin_id
      origin_type = "s3"
      domain_name = module.s3_static_assets_bucket.bucket_domain_name
      s3_oai_id   = module.s3_static_assets_bucket.oai_id
    },
    {
      origin_id   = local.apigateway_origin_id
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

  domain_name          = var.ses_domain_name
  hosted_zone_id       = var.hosted_zone_id
  bucket_name          = module.s3_email_archive.bucket_id
  bucket_policy_arn    = module.s3_email_archive.policy_put_object_arn
  lambda_function_name = module.lambda_redirector.function_name
  lambda_arn           = module.lambda_redirector.arn
  recipients           = var.ses_recipients
}
