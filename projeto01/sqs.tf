resource "aws_sqs_queue" "src_order_queue" {

  name                  = "src_order_queue.fifo"
  fifo_queue            = true
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"

  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_order_queue.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "developer"
  }
}

resource "aws_sqs_queue" "dlq_order_queue" {

  name                  = "dlq_order_queue.fifo"
  fifo_queue            = true
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"
}

data "aws_iam_policy_document" "sqs_policies" {

  statement {
    actions   = ["SQS:*"]
    resources = [aws_sqs_queue.src_order_queue.arn]
    effect    = "Allow"
  }
  statement {
    actions   = ["SQS:*"]
    resources = [aws_sqs_queue.dlq_order_queue.arn]
    effect    = "Allow"
  }
}

/*
resource "aws_sqs_queue_redrive_allow_policy" "example" {

  queue_url = aws_sqs_queue.dlq_order_queue.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.src_order_queue.arn]
  })
}
*/