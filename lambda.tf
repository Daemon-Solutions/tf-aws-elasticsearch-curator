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
      ES_HOST                = "${var.es_host}"
      ES_PORT                = "${var.es_port}"
      SNAPSHOT_BUCKET        = "${var.snapshot_bucket}"
      SNAPSHOT_BUCKET_REGION = "${var.snapshot_bucket_region}"
      SNAPSHOT_NAME          = "${var.snapshot_name}"
      DELETE_INDEX_FILTERS   = "${jsonencode(var.delete_index_filters)}"
      SNAPSHOT_INDEX_FILTERS = "${jsonencode(var.snapshot_index_filters)}"
      TEST_MODE              = "${var.test_mode ? "true" : "false"}"
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
