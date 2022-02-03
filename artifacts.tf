resource "aws_s3_bucket" "build_artifacts" {
  bucket = local.build_artifacts_bucket
  acl    = "private"
}

resource "aws_s3_bucket" "deployment_bucket" {
  bucket = local.deployment_bucket
  acl    = "private"
}
