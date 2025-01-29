# Creating User A and assigning policy

resource "aws_iam_user" "user_a" {
  name = "UserA"
}

resource "aws_iam_user_policy" "user_a_policy" {
  name = "UserA_S3_Policy"
  user = aws_iam_user.user_a.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bucket-a.arn,
          "${aws_s3_bucket.bucket-a.arn}/*"
        ]
      }
    ]
  })
}

# Creating User B and assigning policy

resource "aws_iam_user" "user_b" {
  name = "UserB"
}

resource "aws_iam_user_policy" "user_b_policy" {
  name = "UserB_S3_Policy"
  user = aws_iam_user.user_b.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bucket-b.arn,
          "${aws_s3_bucket.bucket-b.arn}/*"
        ]
      }
    ]
  })
}