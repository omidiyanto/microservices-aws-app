resource "aws_dynamodb_table" "users" {
  name           = "MiNoUsers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "email"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }
}

resource "aws_dynamodb_table" "notes" {
  name           = "MiNoNotes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "noteId"
  range_key      = "userId"

  attribute {
    name = "noteId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }
  
  attribute {
    name = "createdAt"
    type = "S"
  }

  global_secondary_index {
    name               = "UserIdIndex"
    hash_key           = "userId"
    range_key          = "createdAt"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }
} 