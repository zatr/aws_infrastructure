data "aws_iam_policy_document" "codepipeline" {

  # Create build artifacts
  statement {
    actions   = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.artifact_bucket}/*"]
  }

  # Get source from CodeCommit and upload
  statement {
    actions   = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]
    effect    = "Allow"
    resources = ["arn:aws:codecommit:${var.aws_region}:${var.aws_account_id}:${var.repository}"]
  }

  # Start CodeBuild job
  statement {
    actions   = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    effect    = "Allow"
    resources = [aws_codebuild_project.application.arn]
  }

  # Deploy to S3
  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.deployment_bucket}/*"]
  }

  # Invoke Lambda function
  statement {
    actions   = ["lambda:InvokeFunction"]
    effect    = "Allow"
    resources = ["arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.lambda_function}"]
  }
}

resource "aws_iam_role" "codepipeline" {
  name = "${var.repository}-${var.branch}-codepipeline"
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

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.repository}-${var.branch}-codepipeline"
  role = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.repository}-${var.branch}"
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
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration    = {
        RepositoryName       = var.repository
        BranchName           = var.branch
        PollForSourceChanges = true
      }
      namespace = "SourceVariables"
    }
  }

  stage {
    name = "Build"

    action {
      category         = "Build"
      name             = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      configuration    = {
        ProjectName = aws_codebuild_project.application.name
      }
      namespace        = "BuildVariables"
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy_to_S3"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["BuildArtifact"]
      configuration    = {
        BucketName = var.deployment_bucket
        Extract    = false
        ObjectKey  = "${var.repository}/${var.branch}/${var.repository}-${var.branch}-build_#{BuildVariables.CODEBUILD_BUILD_NUMBER}.zip"
      }
    }
  }

  stage {
    name = "Invoke"

    action {
      name             = "Invoke_Lambda"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"
      input_artifacts  = ["BuildArtifact"]
      configuration    = {
        FunctionName   = var.lambda_function
        UserParameters = "#{BuildVariables.CODEBUILD_BUILD_NUMBER}"
      }
    }
  }
}
