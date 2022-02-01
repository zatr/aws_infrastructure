resource "aws_iam_role" "codebuild" {
  name = "codebuild-${var.repository}-${var.branch}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Application = var.application_tag
  }
}

data "aws_iam_policy_document" "codebuild" {
  // Allow logging to CloudWatch
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region}:*:log-group:/aws/codebuild/*"
    ]
  }
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.artifact_bucket}/${var.repository}-${var.branch}/*"]
  }
  statement {
    actions   = [
      "codecommit:GitPull",
      "codecommit:GitPush"
    ]
    effect    = "Allow"
    resources = ["arn:aws:codecommit:${var.aws_region}:${var.aws_account_id}:${var.repository}"]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_codebuild_project" "application" {
  name = "${var.repository}-${var.branch}"
  description = var.repository
  build_timeout = "10"
  service_role = aws_iam_role.codebuild.arn
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
  source_version = var.branch
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:5.0"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = false

    environment_variable {
      name  = "REPOSITORY"
      value = var.repository
    }
  }

  tags = {
    Application = var.application_tag
  }
}
