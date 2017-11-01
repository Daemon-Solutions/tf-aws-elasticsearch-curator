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

variable "index_filters" {
  description = "List of Curator index filter maps"
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
