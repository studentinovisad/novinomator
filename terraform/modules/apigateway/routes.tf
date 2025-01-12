resource "aws_lambda_permission" "lambda_permission" {
  # for_each = local.routes_map

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.routes[0].function_name # each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each = local.routes_map

  api_id                 = aws_apigatewayv2_api.gateway.id
  integration_type       = var.integration_type
  integration_uri        = each.value.invoke_arn
  integration_method     = var.integration_method
  payload_format_version = var.payload_format_version
  connection_type        = var.connection_type
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = local.routes_map

  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "${each.value.method} ${each.value.route}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration[each.key].id}"
}
