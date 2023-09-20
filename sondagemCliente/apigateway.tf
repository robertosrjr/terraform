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

# Recurso do Método HTTP POST com API Key Required
resource "aws_api_gateway_method" "api_gateway_orders_method_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id   = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method   = "POST"
  authorization = "NONE"  # Use "CUSTOM" para habilitar API Key

}

# Crie uma integração AWS Service do tipo SQS
resource "aws_api_gateway_integration" "api_gateway_order_integration_with_sqs" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id             = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method             = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  integration_http_method = "POST" # Método HTTP para a integração
  type                    = "AWS_PROXY"
  uri                     = "'247755251743:new-order-queue.fifo'"
  # Defina o "Path override" aqui
  request_parameters = {
    "integration.request.path.override" = "'47755251743:new-order-queue.fifo'"
  }


  #passthrough_behavior    = "WHEN_NO_MATCH"
  #timeout_milliseconds    = 29000
  #content_handling        = "passthrough"
  /*
  request_parameters      = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'",
    "integration.request.path.action" = "'SendMessage'"
  }
  */
}

/*
# Associe a integração com o método
resource "aws_api_gateway_method_settings" "aws_api_gateway_order_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  stage_name  = "dev" # Substitua pelo nome do seu estágio
  method_path = aws_api_gateway_resource.api_gateway_orders_resource.path
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
}
*/

/*
# Crie um deployment para a API Gateway
resource "aws_api_gateway_deployment" "order_deployment_dev" {
  depends_on    = [aws_api_gateway_integration.api_gateway_order_integration_with_sqs]
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_orders.id
  stage_name    = "dev" # Substitua pelo nome do seu estágio
}
*/
