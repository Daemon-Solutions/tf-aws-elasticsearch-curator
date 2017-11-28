terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "random_id" "name" {
  prefix      = "tf-aws-elasticsearch-curator-test-"
  byte_length = 8
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tf-aws-elasticsearch-curator-test-bucket"
  acl    = "private"

  tags {
    Name        = "Elasticsearch Curator test bucket"
    Environment = "Dev"
  }
}

module "elasticsearch_curator" {
  source = "../"

  name = "${random_id.name.hex}"

  es_host = "localhost"
  es_port = "9200"

  test_mode = true

  schedule_expression = "rate(1 day)"

  snapshot_bucket        = "${aws_s3_bucket.bucket.id}"
  snapshot_bucket_region = "eu-west-1"
  snapshot_name          = "kibana-%Y.%m.%d"

  snapshot_index_filters = [
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

  delete_index_filters = [
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
