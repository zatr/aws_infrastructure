resource "aws_codedeploy_app" "this" {
  name = var.application_name
}

resource "aws_iam_role" "codedeploy" {
  name = "${var.application_name}-codedeploy"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Application = var.application_tag
  }
}

data "aws_iam_policy_document" "codedeploy" {

  # Allow logging to CloudWatch
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region}:*:log-group:/aws/codedeploy/*"
    ]
  }

  # Allow EC2 describe instance, status
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "codedeploy"{
  role = aws_iam_role.codedeploy.name
  policy = data.aws_iam_policy_document.codedeploy.json
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name = aws_codedeploy_app.this.name
  deployment_group_name = aws_codedeploy_app.this.name
  service_role_arn = aws_iam_role.codedeploy.arn

  # Each tag set contains "ANY" filters. Deployment goes to the first tag that matches.
  # Create a new tag set to ALL tags must match
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.codedeploy_instance_name
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = var.environment
    }
  }
}
