resource "aws_s3_bucket" "reports" {
  bucket        = local.reports_bucket_name
  force_destroy = true
}
