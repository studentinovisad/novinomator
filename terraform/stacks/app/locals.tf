data "aws_region" "current" {}

locals {
  cloudfront_sveltekit_rewriter = file("${var.source_code_path}/cloudfront/index.js")
  apigateway_origin_id          = "gateway"
  s3_static_assets_origin_id    = "s3"

  apigateway_domain_name          = "gateway.${var.domain_name}"
  apigateway_regional_domain_name = "${data.aws_region.current.name}.${local.apigateway_domain_name}"

  routes = [
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/"
      method        = "GET"
    },
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/subscribe"
      method        = "GET"
    },
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/subscribe"
      method        = "POST"
    },
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/subscribe/{uuid}"
      method        = "GET"
    },
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/unsubscribe"
      method        = "GET"
    },
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/unsubscribe"
      method        = "POST"
    },
    {
      function_name = module.lambda_sveltekit.function_name
      invoke_arn    = module.lambda_sveltekit.invoke_arn
      route         = "/unsubscribe/{uuid}"
      method        = "GET"
    }
  ]
}
