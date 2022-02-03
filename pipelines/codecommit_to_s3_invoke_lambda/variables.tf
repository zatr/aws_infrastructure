variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = number
}

variable "repository" {
  type        = string
  description = "CodeCommit repository name"
}

variable "branch" {
  type        = string
  description = "CodeCommit branch name"
}

variable "artifact_bucket" {
  type        = string
  description = "Build artifacts bucket"
}

variable "application_tag" {
  type = string
}

variable "deployment_bucket" {
  type        = string
  description = "Bucket to deploy software packages"
}

variable "lambda_function" {
  type        = string
  description = "Name of the Lambda function to invoke"
}