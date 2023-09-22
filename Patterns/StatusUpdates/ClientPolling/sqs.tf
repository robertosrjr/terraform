resource "aws_sqs_queue" "new_order_queue" {
  name  = "new-order-queue.fifo"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.new_order_dlq.arn,
    maxReceiveCount     = 5,             # Número máximo de tentativas antes do redirecionamento
  })

  delay_seconds            = 0
  max_message_size         = 262144 # 256 KB (o valor padrão)
  message_retention_seconds = 345600 # 4 dias (o valor padrão)
  visibility_timeout_seconds = 30    # 30 segundos (o valor padrão)
  receive_wait_time_seconds = 0     # 0 segundos (o valor padrão)
  fifo_queue               = true  # Não é uma fila FIFO (o valor padrão)
  content_based_deduplication = true # Não há deduplicação baseada em conteúdo (o valor padrão)
  kms_master_key_id        = ""    # Nenhum ID de chave KMS (o valor padrão)
}

resource "aws_sqs_queue" "new_order_dlq" {
  name = "new-order-dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true  
  delay_seconds               = 0
  max_message_size            = 262144       # 256 KB (o valor padrão)
  message_retention_seconds   = 345600       # 4 dias (o valor padrão)
  policy                      = jsonencode({})
  receive_wait_time_seconds   = 0            # 0 segundos (o valor padrão)
  visibility_timeout_seconds  = 30           # 30 segundos (o valor padrão)
}

#Configure a fila principal para enviar mensagens não processadas para a DLQ
resource "aws_sqs_queue_policy" "new_order_queue_policy" {
  queue_url = aws_sqs_queue.new_order_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "Allow-Redrive-To-DLQ",
      Effect    = "Allow",
      Principal = "*",
      Action    = "sqs:SendMessage",
      Resource  = aws_sqs_queue.new_order_dlq.arn,
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sqs_queue.new_order_queue.arn
        }
      }
    }]
  })
}






