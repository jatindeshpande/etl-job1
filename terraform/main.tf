resource "aws_s3_bucket" "example1" {
  bucket = "var.bucket1"
}

resource "aws_s3_bucket" "example2" {
  bucket = "var.bucket2"
}