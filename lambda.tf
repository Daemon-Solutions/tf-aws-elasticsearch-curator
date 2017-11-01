module "lambda" {
  source = "../tf-aws-lambda"

  function_name = "${var.name}"
  description   = "Elasticsearch Curator"
  handler       = "main.lambda_handler"
  runtime       = "python2.7"
  timeout       = "${var.timeout}"

  source_path = "${path.module}/lambda"

  attach_policy = "${var.attach_vpc_config}"
  policy        = "${data.aws_iam_policy_document.allow_network_actions.json}"

  environment {
    variables = {
      ES_HOST       = "${var.es_host}"
      ES_PORT       = "${var.es_port}"
      INDEX_FILTERS = "${jsonencode(var.index_filters)}"
      TEST_MODE     = "${var.test_mode ? "true" : "false"}"
    }
  }

  attach_vpc_config = "${var.attach_vpc_config}"

  vpc_config {
    subnet_ids         = ["${var.subnet_ids}"]
    security_group_ids = ["${var.security_group_ids}"]
  }
}

data "aws_iam_policy_document" "allow_network_actions" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}
