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
  #authorizer_id = aws_api_gateway_authorizer.order_authorizer.id

  request_parameters = {
    "method.request.header.x-api-key" = true
    "method.request.header.Authorization" = true # Define api_key_required como verdadeira
  }
}

/*
resource "aws_api_gateway_authorizer" "order_authorizer" {
  name          = "order-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_orders.id
  type          = "TOKEN"
  identity_source = "method.request.header.x-api-key"
}
*/

# Crie uma integração AWS Service do tipo SQS
resource "aws_api_gateway_integration" "api_gateway_order_integration_order" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id             = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method             = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  type                    = "AWS"
  integration_http_method = "POST" # Método HTTP para a integração
  passthrough_behavior    = "NEVER"
  credentials             = "arn:aws:iam::247755251743:role/my-apigateway-sqs-role"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${aws_sqs_queue.new_order_queue.name}"

    request_parameters = {
      "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
    }

    request_templates = {
      "application/json" = "Action=SendMessage&MessageBody=$input.body&MessageGroupId=$input.params().header.get('groupId')"
    }
  
  }

resource "aws_api_gateway_deployment" "gateway_order_deployment_orders" {

  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api_gateway_orders_resource.id,
      aws_api_gateway_method.api_gateway_orders_method_post.id,
      aws_api_gateway_integration.api_gateway_order_integration_order.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "order_stage_development" {
  deployment_id = aws_api_gateway_deployment.gateway_order_deployment_orders.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_orders.id
  stage_name    = "dev"
}

## Alteração sem teste
resource "aws_api_gateway_method_settings" "order_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  stage_name  = aws_api_gateway_stage.order_stage_development.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}


resource "aws_api_gateway_api_key" "order_api_key" {
  name    = "order-api-key"
  description = "An example API key created with Terraform"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "order_usage_plan" {
  name         = "order-plan"
  description  = "my description"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_orders.id
    stage  = aws_api_gateway_stage.order_stage_development.stage_name
  }

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}


resource "aws_api_gateway_usage_plan_key" "order_usage_plan_key" {
  key_id = aws_api_gateway_api_key.order_api_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.order_usage_plan.id
}







resource "aws_api_gateway_method_response" "order_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = aws_api_gateway_method_response.order_method_response_200.status_code
  selection_pattern = "2\\d{2}"

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "order_method_response_400" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = "400"
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response_400" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = aws_api_gateway_method_response.order_method_response_400.status_code
  selection_pattern = "4\\d{2}"

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "order_method_response_500" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response_500" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = aws_api_gateway_method_response.order_method_response_500.status_code
  selection_pattern = "5\\d{2}"

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }
}