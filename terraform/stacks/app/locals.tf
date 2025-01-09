data "aws_region" "current" {}

locals {
  apigateway_domain_name          = "gateway.${var.domain_name}"
  apigateway_regional_domain_name = "${data.aws_region.current.name}.${local.apigateway_domain_name}"

  routes = [
    {
      function_name = module.lambda_subscribe.function_name
      invoke_arn    = module.lambda_subscribe.invoke_arn
      route         = "/subscribe/success"
      method        = "POST"
    },
    {
      function_name = module.lambda_confirm_subscribe.function_name
      invoke_arn    = module.lambda_confirm_subscribe.invoke_arn
      route         = "/subscribe"
      method        = "POST"
    },
    {
      function_name = module.lambda_unsubscribe.function_name
      invoke_arn    = module.lambda_unsubscribe.invoke_arn
      route         = "/unsubscribe/success"
      method        = "POST"
    },
    {
      function_name = module.lambda_confirm_unsubscribe.function_name
      invoke_arn    = module.lambda_confirm_unsubscribe.invoke_arn
      route         = "/unsubscribe"
      method        = "POST"
    }
  ]
}
