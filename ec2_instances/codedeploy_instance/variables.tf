variable "ami" {
  type        = string
  description = "AMI ID"
}

variable "instance_type" {
  type = string
}

variable "tag_name" {
  type = string
}

variable "tag_environment" {
  type = string
  description = "Dev, test, prod"
}
