# Create the SQS queue
resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}

# Create an EventBridge event bus
resource "aws_cloudwatch_event_bus" "custom_bus" {
  name = "custom-bus"
}

# Create an EventBridge rule for filtering events
resource "aws_cloudwatch_event_rule" "my_event_rule" {
  name           = "MyRule"
  event_bus_name = aws_cloudwatch_event_bus.custom_bus.name
  event_pattern = jsonencode({
    "source" = ["PRODUCER.source"]
  })
}

# EventBridge Target pointing to the SQS queue
resource "aws_cloudwatch_event_target" "event_target" {
  event_bus_name = aws_cloudwatch_event_bus.custom_bus.name
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

# Create an IAM Role for the enrichment Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Policy for Lambda to log and interact with EventBridge
resource "aws_iam_policy_attachment" "lambda_logging" {
  name       = "lambda_logging_policy_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_role.name]
}

# Enrichment Lambda function
resource "aws_lambda_function" "enrichment_lambda" {
  filename      = "lambda.zip" # Pre-packaged Lambda zip
  function_name = "EventEnrichmentLambda"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  role          = aws_iam_role.lambda_role.arn

  # Environment variable to pass any configuration data to Lambda
  environment {
    variables = {
      ENV_VAR_KEY = "value"
    }
  }
}


# IAM Policy to allow the pipe to invoke Lambda and send messages to SQS
resource "aws_iam_policy" "eventbridge_pipe_policy" {
  name = "eventbridge-pipe-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction",
          "sqs:SendMessage"
        ],
        "Resource" : [
          aws_lambda_function.enrichment_lambda.arn,
          aws_sqs_queue.my_queue.arn
        ]
      }
    ]
  })
}

# Attach the policy to the pipe role
resource "aws_iam_role_policy_attachment" "eventbridge_pipe_policy_attachment" {
  role       = aws_iam_role.eventbridge_pipe_role.name
  policy_arn = aws_iam_policy.eventbridge_pipe_policy.arn
}

# EventBridge Pipe with enrichment step
resource "aws_pipes_pipe" "event_pipe" {
  name     = "EventToSQSPipeWithEnrichment"
  source   = aws_cloudwatch_event_bus.custom_bus.arn
  target   = aws_sqs_queue.my_queue.arn
  role_arn = aws_iam_role.eventbridge_pipe_role.arn

  source_parameters {
    filter_criteria  {
      filter {
        pattern = jsonencode({
          "source" = ["PRODUCER.source"]
        })
      }
    }
  }

  # Enrichment step configuration
  enrichment = aws_lambda_function.enrichment_lambda.arn

  enrichment_parameters {
    input_template = jsonencode({
      "original_event" : "<$.detail>"
    })
  }
}

# IAM Role for the EventBridge Pipe to allow it to invoke Lambda and send messages to SQS
resource "aws_iam_role" "eventbridge_pipe_role" {
  name = "eventbridge-pipe-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pipes.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
