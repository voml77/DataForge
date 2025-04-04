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
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::dataforge-model-storage/csv/*"
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
  timeout       = 30

  filename         = "${path.module}/../lambda/dynamo_to_s3.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/dynamo_to_s3.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = "DataForge_Structured"
      S3_BUCKET      = "mein-test-bucket-123456789"
    }
  }
}

resource "aws_iam_policy" "terraform_exec_policy" {
  name        = "DataForgeTerraformPolicy"
  description = "Policy für Terraform-Zugriffe auf AWS Ressourcen"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "iam:*",
          "rds:*",                      # <--- DAS hier gibt ALLE RDS-Rechte inkl. Modify
          "rds:ModifyDBInstance",
          "rds:ListTagsForResource",
          "rds:AddTagsToResource",
          "secretsmanager:*",
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "csv_to_rds" {
  function_name = "DataForge_CsvToRds"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "csv_to_rds.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300

  filename         = "${path.module}/../lambda/csv_to_rds.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/csv_to_rds.zip")

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.dataforge_db_sg.id]
  }

  environment {
    variables = {
      RDS_HOST     = aws_db_instance.dataforge_mysql.address
      RDS_USER     = "vadimadmin"
      RDS_USERNAME = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)["username"]
      RDS_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)["password"]
      RDS_DB_NAME  = "dataforge"
      S3_BUCKET    = "dataforge-model-storage"
      CSV_KEY      = "csv/fact_appointments.csv"
    }
  }

  depends_on = [aws_db_instance.dataforge_mysql]
}
resource "aws_iam_policy" "lambda_s3_csv_read_policy" {
  name        = "DataForgeLambdaS3CSVReadAccess"
  description = "Erlaubt dem Lambda-Executor das Lesen der CSV-Dateien im S3-Bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::dataforge-model-storage/csv/*"
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "attach_lambda_s3_csv_read" {
  name       = "AttachLambdaS3CSVReadPolicy"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.lambda_s3_csv_read_policy.arn
}
