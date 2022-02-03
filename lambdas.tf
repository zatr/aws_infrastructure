module "lambda_start_test_runner" {
  source  = "./lambda"
  name    = "start_test_runner"
  handler = "lambda.start_test_runner"
  aws_region = var.aws_region
}
