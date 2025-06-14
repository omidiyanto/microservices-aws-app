resource "aws_api_gateway_rest_api" "mino_api" {
  name        = "MiNoAPI"
  description = "API for MiNo application"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Enable CORS
resource "aws_api_gateway_resource" "cors_resource" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  parent_id   = aws_api_gateway_rest_api.mino_api.root_resource_id
  path_part   = "{cors+}"
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.cors_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "cors_response" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [
    aws_api_gateway_method.cors_method
  ]
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = aws_api_gateway_method_response.cors_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.cors_integration,
    aws_api_gateway_method_response.cors_response
  ]
}

# Auth endpoints
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  parent_id   = aws_api_gateway_rest_api.mino_api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_post" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.mino_api.id
  resource_id             = aws_api_gateway_resource.auth.id
  http_method             = aws_api_gateway_method.auth_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns["auth"]
  
  depends_on = [
    aws_api_gateway_method.auth_post
  ]
}

# Register endpoint
resource "aws_api_gateway_resource" "register" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  parent_id   = aws_api_gateway_rest_api.mino_api.root_resource_id
  path_part   = "register"
}

resource "aws_api_gateway_method" "register_post" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.register.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "register_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.mino_api.id
  resource_id             = aws_api_gateway_resource.register.id
  http_method             = aws_api_gateway_method.register_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns["register"]
  
  depends_on = [
    aws_api_gateway_method.register_post
  ]
}

# Notes endpoints
resource "aws_api_gateway_resource" "notes" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  parent_id   = aws_api_gateway_rest_api.mino_api.root_resource_id
  path_part   = "notes"
}

# GET /notes - Get all notes
resource "aws_api_gateway_method" "get_notes" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.notes.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_notes_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.mino_api.id
  resource_id             = aws_api_gateway_resource.notes.id
  http_method             = aws_api_gateway_method.get_notes.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns["get_notes"]
  
  depends_on = [
    aws_api_gateway_method.get_notes
  ]
}

# POST /notes - Create a note
resource "aws_api_gateway_method" "create_note" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.notes.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_note_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.mino_api.id
  resource_id             = aws_api_gateway_resource.notes.id
  http_method             = aws_api_gateway_method.create_note.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns["create_note"]
  
  depends_on = [
    aws_api_gateway_method.create_note
  ]
}

# Note resource with ID
resource "aws_api_gateway_resource" "note" {
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  parent_id   = aws_api_gateway_resource.notes.id
  path_part   = "{noteId}"
}

# PUT /notes/{noteId} - Update a note
resource "aws_api_gateway_method" "update_note" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.note.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_note_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.mino_api.id
  resource_id             = aws_api_gateway_resource.note.id
  http_method             = aws_api_gateway_method.update_note.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns["update_note"]
  
  depends_on = [
    aws_api_gateway_method.update_note
  ]
}

# DELETE /notes/{noteId} - Delete a note
resource "aws_api_gateway_method" "delete_note" {
  rest_api_id   = aws_api_gateway_rest_api.mino_api.id
  resource_id   = aws_api_gateway_resource.note.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_note_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.mino_api.id
  resource_id             = aws_api_gateway_resource.note.id
  http_method             = aws_api_gateway_method.delete_note.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns["delete_note"]
  
  depends_on = [
    aws_api_gateway_method.delete_note
  ]
}

# Deploy the API
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.auth_lambda,
    aws_api_gateway_integration.register_lambda,
    aws_api_gateway_integration.get_notes_lambda,
    aws_api_gateway_integration.create_note_lambda,
    aws_api_gateway_integration.update_note_lambda,
    aws_api_gateway_integration.delete_note_lambda,
    aws_api_gateway_integration_response.cors_integration_response
  ]
  
  rest_api_id = aws_api_gateway_rest_api.mino_api.id
  stage_name  = "dev"
  
  # Trigger redeployment when needed
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.auth.id,
      aws_api_gateway_resource.register.id,
      aws_api_gateway_resource.notes.id,
      aws_api_gateway_resource.note.id,
      aws_api_gateway_method.auth_post.id,
      aws_api_gateway_method.register_post.id,
      aws_api_gateway_method.get_notes.id,
      aws_api_gateway_method.create_note.id,
      aws_api_gateway_method.update_note.id,
      aws_api_gateway_method.delete_note.id
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Lambda permissions
resource "aws_lambda_permission" "apigw_auth" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["auth"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mino_api.execution_arn}/*/${aws_api_gateway_method.auth_post.http_method}${aws_api_gateway_resource.auth.path}"
}

resource "aws_lambda_permission" "apigw_register" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["register"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mino_api.execution_arn}/*/${aws_api_gateway_method.register_post.http_method}${aws_api_gateway_resource.register.path}"
}

resource "aws_lambda_permission" "apigw_get_notes" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["get_notes"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mino_api.execution_arn}/*/${aws_api_gateway_method.get_notes.http_method}${aws_api_gateway_resource.notes.path}"
}

resource "aws_lambda_permission" "apigw_create_note" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["create_note"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mino_api.execution_arn}/*/${aws_api_gateway_method.create_note.http_method}${aws_api_gateway_resource.notes.path}"
}

resource "aws_lambda_permission" "apigw_update_note" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["update_note"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mino_api.execution_arn}/*/${aws_api_gateway_method.update_note.http_method}${aws_api_gateway_resource.note.path}"
}

resource "aws_lambda_permission" "apigw_delete_note" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names["delete_note"]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mino_api.execution_arn}/*/${aws_api_gateway_method.delete_note.http_method}${aws_api_gateway_resource.note.path}"
} 