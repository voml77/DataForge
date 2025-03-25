resource "aws_iam_role" "lambda_exec_role" {
  name = "DataForgeLambdaExecRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "DataForgeLambdaPolicy"
  description = "Erlaubt Lambda Zugriff auf DynamoDB, S3 und CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Scan",
          "dynamodb:GetItem"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

resource "aws_lambda_function" "dynamo_to_s3" {
  function_name = "DataForge_DynamoToS3"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "dynamo_to_s3.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/lambda/dynamo_to_s3.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/dynamo_to_s3.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = "DataForge_Structured"
      S3_BUCKET      = "mein-test-bucket-123456789"
    }
  }
}
