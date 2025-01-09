resource "aws_apigatewayv2_api" "gateway" {
  name          = var.gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy
}

resource "aws_apigatewayv2_domain_name" "domain_name_latency" {
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping_latency" {
  api_id      = aws_apigatewayv2_api.gateway.id
  domain_name = aws_apigatewayv2_domain_name.domain_name_latency.id
  stage       = aws_apigatewayv2_stage.stage.id
}

resource "aws_apigatewayv2_domain_name" "domain_name_regional" {
  domain_name = local.regional_domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping_regional" {
  api_id      = aws_apigatewayv2_api.gateway.id
  domain_name = aws_apigatewayv2_domain_name.domain_name_regional.id
  stage       = aws_apigatewayv2_stage.stage.id
}
