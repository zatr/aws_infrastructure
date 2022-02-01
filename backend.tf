terraform {
  backend "s3" {
    bucket = "itp-infrastructure-state"
    key = "aws_infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}
