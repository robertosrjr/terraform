
/*
resource "aws_api_gateway_api_key" "api_key_orders_dev" {
  name = "api_key_orders_dev"
  description = "API Key Orders Dev"
  enabled          = true
}
/*
resource "aws_api_gateway_usage_plan" "api_key_orders_plan_dev" {
  name = "plans-developer-order"
  description = "Plans developer order"
  product_code = "ORDERS_API_DEV"
  quota_settings {
    limit = 1000
    offset = 2
    period = "MONTH"
  }
  throttle_settings {
    rate_limit = 1
    burst_limit = 50
  }

   api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_orders.id
    stage = aws_api_gateway_deployment.example.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "example" {
  key_id        = aws_api_gateway_api_key.api_key_orders_dev.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_key_orders_plan_dev.id
}
*/