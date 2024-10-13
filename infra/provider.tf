provider "aws" {
  region              = "us-east-1"
  profile             = "localstack"
  s3_force_path_style = true

  endpoints {
    s3         = "http://localhost:4566"
    iam        = "http://localhost:4566"
    sts        = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    lambda     = "http://localhost:4566"
  }
}
