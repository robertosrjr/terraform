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
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
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

resource "aws_api_gateway_stage" "api_gateway_stage_dev" {
  deployment_id = aws_api_gateway_deployment.gateway_order_deployment_orders.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_orders.id
  stage_name    = "dev"
}

resource "aws_api_gateway_method_response" "order_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "order_method_response_400" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "order_method_response_500" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "api_gateway_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_orders.id
  resource_id = aws_api_gateway_resource.api_gateway_orders_resource.id
  http_method = aws_api_gateway_method.api_gateway_orders_method_post.http_method
  status_code = aws_api_gateway_method_response.order_method_response_200.status_code
  selection_pattern = "2\\d{2}"

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOT
        #set($inputRoot = $input.path('$'))
        {
          "statusCode": 200,
          "message": "Resposta personalizada com dados do SQS",
          "data":{
            "requestId": \"$inputRoot.SendMessageResponse.ResponseMetadata.RequestId\",
            "messageId": \"$inputRoot.SendMessageResponse.SendMessageResult.MessageId\",
            "sequenceNumber": \"$inputRoot.SendMessageResponse.SendMessageResult.SequenceNumber\"
          } 
        }
    EOT
  }
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

