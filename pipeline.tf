module "cicd_aws_tester_main" {
  source = "./pipelines/codecommit_to_s3"
  repository = "aws_tester"
  branch = "main"
  artifact_bucket = aws_s3_bucket.build_artifacts.bucket
  application_tag = "aws_tester"
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
  deployment_bucket = local.deployment_bucket
}

module "cicd_aws_tools_main" {
  source = "./pipelines/codecommit_to_s3"
  repository = "aws_tools"
  branch = "main"
  artifact_bucket = aws_s3_bucket.build_artifacts.bucket
  application_tag = "aws_tools"
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
  deployment_bucket = local.deployment_bucket
}
