module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda?ref=v0.12.0"

  function_name = "${var.name}"
  description   = "Elasticsearch Curator"
  handler       = "main.lambda_handler"
  runtime       = "python3.6"
  timeout       = "${var.timeout}"

  source_path = "${path.module}/lambda"

  attach_policy = "${var.es_request_signing}"
  policy        = "${data.aws_iam_policy_document.allow_es_actions.json}"

  environment {
    variables = {
      ES_HOST                = "${var.es_host}"
      ES_PORT                = "${var.es_port}"
      ES_REGION              = "${coalesce(var.es_region, data.aws_region.current.name)}"
      ES_SIGNING             = "${var.es_request_signing ? 1 : 0}"
      ES_SSL                 = "${var.es_ssl ? 1 : 0}"
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

data "aws_iam_policy_document" "allow_es_actions" {
  statement {
    effect = "Allow"

    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${var.es_arn}/*",
    ]
  }
}
