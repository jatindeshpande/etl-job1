resource "aws_glue_job" "name" {
  name = "my-etl-job"
  role_arn = aws_iam_role.glue_role.arn
  glue_version = "4.0"
  worker_type  = "G.1X"
  number_of_workers = 2

  
  command {
    name = "glueetl"
    script_location = "s3://${var.bucket1}/scripts/gluejob.py"
    python_version  = "3"
  }

  default_arguments = {
    "--S3_SOURCE_PATH" = "s3://${var.bucket1}/data/"
    "--S3_TARGET_PATH" = "s3://${var.bucket1}/output/"
    "--job-language"    = "python"
  }
}