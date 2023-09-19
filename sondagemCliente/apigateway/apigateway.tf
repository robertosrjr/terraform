# Recurso do API Gateway
resource "aws_api_gateway_rest_api" "api_gateway_orders" {
  name        = "orders"
  description = "Orders API (tf)"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api_gateway_orders_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_orders.root_resource_id
  path_part   = "v1"
}

# Recurso do Método HTTP GET com API Key Required
resource "aws_api_gateway_method" "api_gateway_orders_method_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id   = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method   = "GET"
  authorization = "NONE"  # Use "CUSTOM" para habilitar API Key

}