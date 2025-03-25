resource "aws_cloudwatch_event_rule" "every_15_minutes" {
  name                = "DataForge_Lambda_Schedule"
  description         = "Löst alle 15 Minuten die Lambda-Funktion aus"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_15_minutes.name
  target_id = "DataForgeLambda"
  arn       = aws_lambda_function.dynamo_to_s3.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamo_to_s3.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_15_minutes.arn
}
