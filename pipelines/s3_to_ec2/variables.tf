variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = number
}

variable "application_name" {
  type = string
}

variable "application_tag" {
  type = string
}

variable "artifact_bucket" {
  type = string
  description = "Build artifacts bucket"
}

variable "source_bucket" {
  type = string
  description = "Bucket for source of pipeline"
}

variable "source_object_key" {
  type = string
  description = "Object key for source of pipeline"
}

variable "codedeploy_instance_name" {
  type        = string
  description = "Name of instance to deploy to"
}

variable "environment" {
  type = string
  description = "Dev, test, prod"
}
