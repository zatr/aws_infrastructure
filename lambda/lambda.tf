resource "aws_lambda_function" "lambda_function" {
  role             = aws_iam_role.lambda.arn
  handler          = var.handler
  runtime          = var.runtime
  filename         = "${path.module}/${var.lambda_zip}"
  function_name    = var.name
  source_code_hash = filebase64sha256("${path.module}/${var.lambda_zip}")
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-lambda"
  path               = "/"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda" {
  // Allow logging to CloudWatch
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/*"
    ]
  }

  statement {
    actions   = [
      "codepipeline:PutJobSuccessResult",
      "codepipeline:PutJobFailureResult"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda" {
  role = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda.json
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/${var.lambda_file}"
  output_path = "${path.module}/${var.lambda_zip}"
}
