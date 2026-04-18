resource "aws_glue_job" "name" {
  name = "my-etl-job"
  role_arn = aws_iam_role.glue_role.arn
  glue_version = "4.0"
  worker_type  = "G.1X"
  number_of_workers = 2
  max_retries       = 1
  timeout           = 10

  
  command {
    name = "glueetl"
    script_location = "s3://${var.bucket1}/scripts/gluejob.py"
    python_version  = "3"
  }

  default_arguments = {
    "--S3_SOURCE_PATH" = "s3://${var.bucket1}/data/"
    "--S3_TARGET_PATH" = "s3://${var.bucket2}/output/"
    "--job-language"    = "python"
  }
}

resource "aws_iam_role" "glue_role" {
  name = "glue_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_logs" {
  name = "glue-logs"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "access_bucket" {
  name = "s3-access-policy"
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:*"
      ]
      Resource = "*"
    }]
  })

  
}