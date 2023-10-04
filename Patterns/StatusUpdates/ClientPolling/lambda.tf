resource "aws_lambda_function" "new_order_command" {

  function_name = "new_order_command"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"
  memory_size= 128
  filename = "lambdas/order/new_order_command.zip"  # Path to your Lambda deployment package
  architectures = ["arm64"]
  reserved_concurrent_executions = 5
  timeout = 3
  role = aws_iam_role.lambda_role.arn
  

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

resource "aws_iam_policy_attachment" "sqs_full_access" {
  name = "sqs_full_access"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  roles      = [aws_iam_role.lambda_role.name]
}


/*
resource "aws_iam_policy_attachment" "example" {
  policy_arn = aws_iam_policy.example.arn
  roles      = [aws_iam_role.example.name]
}

esource "aws_iam_policy" "example" {
  name        = "nome-da-sua-politica-iam-lambda"
  description = "Política para a função Lambda"

  # Defina as permissões necessárias para sua função Lambda aqui
}
*/

resource "aws_lambda_permission" "lambda_permission" {

  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_order_command.function_name
  principal     = "sqs.amazonaws.com"

  source_arn = aws_sqs_queue.new_order_queue.arn
}

resource "aws_lambda_event_source_mapping" "event_source_mapping_new_order" {
  batch_size             = 10 # O número de mensagens SQS para processar de uma vez
  event_source_arn       = aws_sqs_queue.new_order_queue.arn
  function_name          = aws_lambda_function.new_order_command.arn
  function_response_types = ["ReportBatchItemFailures"]
  #maximum_batching_window = 60 # Tempo máximo para agrupar mensagens em segundos
}