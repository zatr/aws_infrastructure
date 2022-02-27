# Build source, deploy to S3
module "cicd_aws_tester_main" {
  source            = "./pipelines/codecommit_to_s3"
  repository        = "aws_tester"
  branch            = "main"
  artifact_bucket   = aws_s3_bucket.build_artifacts.bucket
  application_tag   = "aws_tester"
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  deployment_bucket = local.deployment_bucket
}

# Build source, deploy to S3, invoke start_test_runner function
module "cicd_aws_tools_main" {
  source            = "./pipelines/codecommit_to_s3_invoke_lambda"
  repository        = "aws_tools"
  branch            = "main"
  artifact_bucket   = aws_s3_bucket.build_artifacts.bucket
  application_tag   = "aws_tools"
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  deployment_bucket = local.deployment_bucket
  lambda_function   = "start_test_runner"
}

# Get software from S3, deploy to EC2 instance
module "cicd_aws_tools_to_ec2_instance" {
  source                   = "./pipelines/s3_to_ec2"
  application_name         = "aws_tools_deployment"
  application_tag          = "aws_tools"
  artifact_bucket          = aws_s3_bucket.build_artifacts.bucket
  aws_region               = var.aws_region
  aws_account_id           = var.aws_account_id
  source_bucket            = "itp-deployments"
  source_object_key        = "aws_tools/s3_to_ec2_pipeline_source/aws_tools-main-build_15.zip"
  codedeploy_instance_name = "aws_tools"
  environment              = "dev"
}
