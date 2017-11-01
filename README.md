# tf-aws-elasticsearch-curator

This module creates a scheduled Lambda function that runs Elasticsearch Curator.

It currently only works with Elasticsearch 5.x on EC2, but it would not take much work to support AWS Elasticsearch Service.

## Features

* Deletes indices matching the filters provided to the module

## Usage

```js
module "elasticsearch_curator" {
  source = "tf-aws-elasticsearch-curator"

  name = "${var.envname}-es-curator"

  es_host = "${var.es_host}"
  es_port = "${var.es_port}"

  // Optionally specify a schedule (defaults to 1am daily).
  schedule_expression = "cron(0 3 * * ? *)"

  // Optionally deploy the Lambda function into a VPC.
  attach_vpc_config  = true
  security_group_ids = "${var.security_group_ids}"
  subnet_ids         = "${var.subnet_ids}"

  // Specify the filters for Curator to use when finding indices to delete.
  // The documentation is not great for this but try looking at:
  // https://curator.readthedocs.io/en/5.3/filters.html#indexlist
  // https://github.com/elastic/curator/blob/v5.3.0/curator/indexlist.py#L1032
  index_filters = [
    {
      filtertype = "pattern"
      kind       = "prefix"
      value      = "logs"
    },
    {
      filtertype = "age"
      source     = "name"
      direction  = "older"
      timestring = "%Y.%m.%d"
      unit       = "days"
      unit_count = 3
    },
  ]
}
```
