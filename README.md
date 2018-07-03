# tf-aws-elasticsearch-curator

This module creates a scheduled Lambda function that runs Elasticsearch Curator.

It currently only works with Elasticsearch 6.x.

## Features

* Creates snapshots of indices matching filters provided to the module
* Deletes indices matching filters provided to the module

## Usage

```js
module "elasticsearch_curator" {
  source = "tf-aws-elasticsearch-curator"

  name = "${var.envname}-es-curator"

  // Elasticsearch ARN is only required when signing requests using AWS Signature V4
  es_arn  = "${var.es_arn}"
  es_host = "${var.es_host}"
  es_port = "${var.es_port}"

  // Optionally specify a schedule (defaults to 1am daily).
  schedule_expression = "cron(0 3 * * ? *)"

  // Optionally deploy the Lambda function into a VPC.
  attach_vpc_config  = true
  security_group_ids = "${var.security_group_ids}"
  subnet_ids         = "${var.subnet_ids}"

  // Optionally creates a snapshot of a list of indices.
  snapshot_bucket        = "${var.snapshot_bucket}"
  snapshot_bucket_region = "eu-west-1"
  snapshot_name          = "kibana-%Y.%m.%d"

  // Specify the filters for Curator to use when finding indices to snapshot.
  // The documentation is not great for this but try looking at:
  // https://curator.readthedocs.io/en/v5.5.1/filters.html#indexlist
  // https://github.com/elastic/curator/blob/v5.5.4/curator/indexlist.py#L1136
  snapshot_index_filters = [
    {
      filtertype = "pattern"
      kind       = "prefix"
      value      = "logstash-"
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

  // Specify the filters for Curator to use when finding indices to delete.
  // The documentation is not great for this but try looking at:
  // https://curator.readthedocs.io/en/v5.5.1/filters.html#indexlist
  // https://github.com/elastic/curator/blob/v5.5.4/curator/indexlist.py#L1136
  delete_index_filters = [
    {
      filtertype = "pattern"
      kind       = "prefix"
      value      = "logstash-"
    },
    {
      filtertype = "age"
      source     = "name"
      direction  = "older"
      timestring = "%Y.%m.%d"
      unit       = "days"
      unit_count = 14
    },
  ]
}
```
