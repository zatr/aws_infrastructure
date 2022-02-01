resource "aws_s3_bucket" "aws_tester_build_artifacts" {
  bucket = "itp-cicd-build-artifacts"
  acl = "private"

  tags = {
    Application = "aws_tester"
  }
}
