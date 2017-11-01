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

module "elasticsearch_curator" {
  source = "../"

  name = "${random_id.name.hex}"

  es_host = "localhost"
  es_port = "9200"

  test_mode = true

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
