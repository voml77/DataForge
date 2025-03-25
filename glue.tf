resource "aws_glue_catalog_database" "dataforge_db" {
  name = "dataforge_database"
}

resource "aws_glue_crawler" "dataforge_crawler" {
  name         = "dataforge_s3_crawler"
  role         = aws_iam_role.glue_service_role.arn
  database_name = aws_glue_catalog_database.dataforge_db.name
  table_prefix  = "dataforge_"

  s3_target {
    path = "s3://mein-test-bucket-123456789/"
  }

  schedule = "cron(0 * * * ? *)" # optional: stündlich

  configuration = jsonencode({
    Version = 1.0,
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })
}

resource "aws_iam_role" "glue_service_role" {
  name = "DataForgeGlueServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_policy_attach" {
  name       = "glue-policy-attach"
  roles      = [aws_iam_role.glue_service_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = "DataForgeGlueS3AccessPolicy"
  description = "Erlaubt Glue Zugriff auf den DataForge S3 Bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::mein-test-bucket-123456789",
          "arn:aws:s3:::mein-test-bucket-123456789/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_s3_access_attach" {
  name       = "glue-s3-access-attach"
  roles      = [aws_iam_role.glue_service_role.name]
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}
