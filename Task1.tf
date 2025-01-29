
provider "aws" {
  region = "eu-west-2"
}

# Create S3 buckets

resource "aws_s3_bucket" "bucket-a" {
  bucket = "bucket-a"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "bucket-b" {
  bucket = "bucket-b"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


# Lambda Execution role

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda Execution Policy Creation

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.bucket-a.arn,
          "${aws_s3_bucket.bucket-a.arn}/*",
          aws_s3_bucket.bucket-b.arn,
          "${aws_s3_bucket.bucket-b.arn}/*"
        ]
      }
    ]
  })
}

# Lambda Deployment

data "aws_lambda_layer_version" "pillow" {
  layer_name    = "Klayers-p39-Pillow" 
 
}
resource "aws_lambda_function" "metadata_lambda" {
  filename      = "lambda_function.zip"
  function_name = "metadata_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  layers = [data.aws_lambda_layer_version.pillow.arn]

  environment {
    variables = {
      DESTINATION_BUCKET = aws_s3_bucket.bucket-b.bucket
    }
  }
}

resource "aws_lambda_permission" "allow_bucket-a" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.metadata_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket-a.arn
}


#EventBridge Trigger for Lambda 
resource "aws_s3_bucket_notification" "bucket_a_notification" {
  bucket = aws_s3_bucket.bucket-a.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.metadata_lambda.arn
    events              = ["s3:ObjectCreated:*"]

    filter {
      key {
        filter_rules = [
          {
            name  = "suffix"
            value = ".jpg"
          }
        ]
      }
    }
  }
}






