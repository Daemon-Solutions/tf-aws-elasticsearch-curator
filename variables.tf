variable "name" {
  description = "A unique name within the AWS account for naming resources"
  default     = "elasticsearch-curator"
}

variable "es_host" {
  description = "The Elasticsearch host name"
  type        = "string"
}

variable "es_port" {
  description = "The Elasticsearch port number"
  default     = "9200"
}

variable "snapshot_bucket" {
  description = "The S3 bucket to save snapshots"
  type        = "string"
}

variable "snapshot_bucket_region" {
  description = "The S3 bucket region"
  type        = "string"
}

variable "snapshot_name" {
  description = "The Elasticsearch indices snapshot name. It supports Python strftime as per http://strftime.org/"
  type        = "string"
}

variable "delete_index_filters" {
  description = "List of Curator index filter maps used for finding indices to delete"
  type        = "list"
}

variable "snapshot_index_filters" {
  description = "List of Curator index filter maps  used for finding indices to snapshot"
  type        = "list"
}

variable "schedule_expression" {
  description = "CloudWatch schedule expression for running Curator"
  default     = "cron(0 1 * * ? *)"                                  // 1 am daily
}

variable "attach_vpc_config" {
  description = "Set this to true to deploy the Lambda function into a VPC"
  default     = false
}

variable "subnet_ids" {
  description = "List of VPC subnets"
  default     = []
}

variable "security_group_ids" {
  description = "List of VPC security groups"
  default     = []
}

variable "timeout" {
  description = "Timeout value in seconds for the Lambda function"
  default     = "60"
}

variable "test_mode" {
  description = "Set this to true to find indices but not delete them"
  default     = false
}
