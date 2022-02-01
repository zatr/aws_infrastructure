module "cicd_aws_tester_main" {
  source = "./pipeline"
  repository = "aws_tester"
  branch = "main"
  artifact_bucket = aws_s3_bucket.aws_tester_build_artifacts.bucket
  application_tag = "aws_tester"
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
}

module "cicd_aws_tools_main" {
  source = "./pipeline"
  repository = "aws_tools"
  branch = "main"
  artifact_bucket = aws_s3_bucket.aws_tester_build_artifacts.bucket
  application_tag = "aws_tester"
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
}
