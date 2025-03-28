resource "aws_glue_crawler" "parquet_crawler" {
  name          = "dataforge_parquet_crawler"
  role          = aws_iam_role.glue_service_role.arn
  database_name = aws_glue_catalog_database.dataforge_db.name
  table_prefix  = "parquet_"

  s3_target {
    path = "s3://mein-test-bucket-123456789/parquet/"
  }

  configuration = jsonencode({
    Version = 1.0,
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })
}
