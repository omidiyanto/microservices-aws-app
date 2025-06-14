output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "notes_table_name" {
  value = aws_dynamodb_table.notes.name
}

output "notes_table_arn" {
  value = aws_dynamodb_table.notes.arn
} 