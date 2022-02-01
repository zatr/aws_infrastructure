module "cicd" {
  source = "./pipeline"
  repository = "aws_tester"
  branch = "main"
  artifact_bucket = aws_s3_bucket.aws_tester_build_artifacts.bucket
  application_tag = "aws_tester"
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id
}
