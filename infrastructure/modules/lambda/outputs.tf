output "lambda_invoke_arns" {
  value = {
    "auth"        = aws_lambda_function.auth_lambda.invoke_arn
    "register"    = aws_lambda_function.register_lambda.invoke_arn
    "get_notes"   = aws_lambda_function.get_notes_lambda.invoke_arn
    "create_note" = aws_lambda_function.create_note_lambda.invoke_arn
    "update_note" = aws_lambda_function.update_note_lambda.invoke_arn
    "delete_note" = aws_lambda_function.delete_note_lambda.invoke_arn
  }
}

output "lambda_function_names" {
  value = {
    "auth"        = aws_lambda_function.auth_lambda.function_name
    "register"    = aws_lambda_function.register_lambda.function_name
    "get_notes"   = aws_lambda_function.get_notes_lambda.function_name
    "create_note" = aws_lambda_function.create_note_lambda.function_name
    "update_note" = aws_lambda_function.update_note_lambda.function_name
    "delete_note" = aws_lambda_function.delete_note_lambda.function_name
  }
} 