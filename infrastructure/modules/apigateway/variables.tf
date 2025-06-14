variable "lambda_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  type        = map(string)
}

variable "lambda_function_names" {
  description = "Map of Lambda function names"
  type        = map(string)
} 