resource "aws_iam_role" "generate_report_role" {
  name = "generate-report-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "generate_report_policy" {
  name        = "generate-report-policy"
  description = "Policy for generating reports"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.reports.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "generate_report_policy_attachment" {
  role       = aws_iam_role.generate_report_role.name
  policy_arn = aws_iam_policy.generate_report_policy.arn
}

resource "aws_lambda_function" "generate_report" {
  function_name    = "generate-report"
  runtime          = "go1.x"
  role             = aws_iam_role.generate_report_role.arn
  handler          = "generate-report"
  filename         = "../bin/generate-report.zip"
  source_code_hash = filesha1("../bin/generate-report.zip")
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      ENVIRONMENT = local.environment
      BUCKET_NAME = aws_s3_bucket.reports.bucket
    }
  }
}
