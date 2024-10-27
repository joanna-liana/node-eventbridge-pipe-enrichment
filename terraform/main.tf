# Create the SQS queue
resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}

# Create the EventBridge rule
resource "aws_cloudwatch_event_rule" "my_event_rule" {
  name           = "MyRule"
  event_bus_name = "default"
  event_pattern = jsonencode({
    "source" = ["PRODUCER.source"]
  })
}

# EventBridge Target pointing to the SQS queue
resource "aws_cloudwatch_event_target" "event_target" {
  rule = aws_cloudwatch_event_rule.my_event_rule.name
  arn  = aws_sqs_queue.my_queue.arn
}

# Allow EventBridge to send messages to SQS queue
resource "aws_sqs_queue_policy" "allow_eventbridge" {
  queue_url = aws_sqs_queue.my_queue.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "SQS:SendMessage",
        "Resource" : aws_sqs_queue.my_queue.arn,
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : aws_cloudwatch_event_rule.my_event_rule.arn
          }
        }
      }
    ]
  })
}
