resource "aws_dynamodb_table" "dataforge_table" {
  name           = "DataForgeTable"
  billing_mode   = "PAY_PER_REQUEST"  # Nutzt Free Tier optimal
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"  # String als Primärschlüssel
  }

  tags = {
    Name        = "DataForgeTable"
    Environment = "Development"
  }
}

resource "aws_dynamodb_table" "structured_table" {
  name         = "DataForge_Structured"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S"  # String als Primärschlüssel
  }

  attribute {
    name = "Timestamp"
    type = "N"  # Zahl für Sortierung
  }

  global_secondary_index {
    name            = "TimestampIndex"
    hash_key        = "ID"
    range_key       = "Timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name = "DataForge_Structured"
  }
}

resource "aws_dynamodb_table" "semi_structured_table" {
  name         = "DataForge_JSON"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"

  attribute {
    name = "PK"
    type = "S"
  }

  tags = {
    Name = "DataForge_JSON"
  }
}

resource "aws_dynamodb_table" "key_value_store" {
  name         = "DataForge_KeyValue"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Key"

  attribute {
    name = "Key"
    type = "S"
  }

  tags = {
    Name = "DataForge_KeyValue"
  }
}
