resource "aws_lambda_function" "new_order_command" {

  function_name = "new_order_command"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"
  role = aws_iam_role.lambda_role.arn
  filename = "new_order_command.zip"  # Path to your Lambda deployment package
  architectures = ["arm64"]

  tracing_config {
    mode = "Active"  # Habilita o AWS X-Ray
  }
}

resource "aws_iam_role" "lambda_role" {

  name = "new_order_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_permission" "lambda_permission" {

  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_order_command.function_name
  principal     = "sqs.amazonaws.com"

  source_arn = aws_sqs_queue.new_order_queue.arn
}





