data "aws_iam_policy_document" "codepipeline" {
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.artifact_bucket}/${var.repository}-${var.branch}/*"]
  }
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
  statement {
    actions   = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    effect    = "Allow"
    resources = [aws_codebuild_project.application.arn]
  }
}

resource "aws_iam_role" "codepipeline" {
  name = "codepipeline-${var.repository}-${var.branch}"
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
      },
    ]
  })

  tags = {
    Application = var.application_tag
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "codepipeline-${var.repository}-${var.branch}"
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
      namespace = "BuildVariables"
    }
  }
}
