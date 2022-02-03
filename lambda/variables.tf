variable "name" {
  type = string
}

variable "lambda_file" {
  type    = string
  default = "lambda.py"
}

variable "lambda_zip" {
  type    = string
  default = "lambda.zip"
}

variable "handler" {
  type    = string
}

variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "aws_region" {
  type = string
}
