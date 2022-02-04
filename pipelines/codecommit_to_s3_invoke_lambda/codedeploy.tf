resource "aws_codedeploy_app" "this" {
  name = "${var.repository}-${var.branch}"
}

resource "aws_iam_role" "codedeploy" {
  name = "codedeploy-${var.repository}-${var.branch}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

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
}