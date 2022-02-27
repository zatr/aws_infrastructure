resource "aws_iam_role" "codepipeline" {
  name = "${var.application_name}-codepipeline"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Application = var.application_tag
  }
}

data "aws_iam_policy_document" "codepipeline" {

  # Get deployed software from S3
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["*"]
  }

  # Allow CodeDeploy create, get deployment
  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:deploymentgroup:${var.application_name}/${var.application_name}"
    ]
  }

  # Allow CodeDeploy get deployment config
  statement {
    actions = [
      "codedeploy:GetDeploymentConfig",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:deploymentconfig:*"
    ]
  }

  # Allow CodeDeploy register, get application revision
  statement {
    actions = [
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetApplicationRevision"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:application:${var.application_name}"
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.application_name}-codepipeline"
  role = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.application_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category         = "Source"
      name             = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration    = {
        S3Bucket              = var.source_bucket
        S3ObjectKey           = var.source_object_key
        PollForSourceChanges  = true
      }
      namespace = "SourceVariables"
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy_to_EC2"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      configuration    = {
        ApplicationName     = aws_codedeploy_app.this.name
        DeploymentGroupName = aws_codedeploy_deployment_group.this.deployment_group_name
      }
    }
  }
}
