resource "aws_cloudwatch_event_target" "curator" {
  rule = "${aws_cloudwatch_event_rule.curator.name}"
  arn  = "${module.lambda.function_arn}"
}

resource "aws_cloudwatch_event_rule" "curator" {
  name                = "${var.name}"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.curator.arn}"
}
