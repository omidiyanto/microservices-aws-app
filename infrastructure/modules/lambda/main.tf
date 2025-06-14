resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "IAM policy for Lambda functions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda functions with null_resource dependencies to ensure files exist
resource "null_resource" "check_lambda_files" {
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "${path.module}/../../../backend/bin/auth.zip" ]; then
        echo "Error: Lambda zip file not found: ${path.module}/../../../backend/bin/auth.zip"
        exit 1
      fi
      if [ ! -f "${path.module}/../../../backend/bin/register.zip" ]; then
        echo "Error: Lambda zip file not found: ${path.module}/../../../backend/bin/register.zip"
        exit 1
      fi
      if [ ! -f "${path.module}/../../../backend/bin/get_notes.zip" ]; then
        echo "Error: Lambda zip file not found: ${path.module}/../../../backend/bin/get_notes.zip"
        exit 1
      fi
      if [ ! -f "${path.module}/../../../backend/bin/create_note.zip" ]; then
        echo "Error: Lambda zip file not found: ${path.module}/../../../backend/bin/create_note.zip"
        exit 1
      fi
      if [ ! -f "${path.module}/../../../backend/bin/update_note.zip" ]; then
        echo "Error: Lambda zip file not found: ${path.module}/../../../backend/bin/update_note.zip"
        exit 1
      fi
      if [ ! -f "${path.module}/../../../backend/bin/delete_note.zip" ]; then
        echo "Error: Lambda zip file not found: ${path.module}/../../../backend/bin/delete_note.zip"
        exit 1
      fi
    EOT
    interpreter = ["bash", "-c"]
  }

  # Make sure this is checked on every apply
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Lambda functions
resource "aws_lambda_function" "auth_lambda" {
  function_name = "mino_auth"
  filename      = "${path.module}/../../../backend/bin/auth.zip"
  handler       = "auth"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  timeout       = 10
  
  environment {
    variables = {
      USERS_TABLE = "MiNoUsers"
      JWT_SECRET  = "local-dev-jwt-secret"
    }
  }

  depends_on = [null_resource.check_lambda_files]
}

resource "aws_lambda_function" "register_lambda" {
  function_name = "mino_register"
  filename      = "${path.module}/../../../backend/bin/register.zip"
  handler       = "register"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  timeout       = 10
  
  environment {
    variables = {
      USERS_TABLE = "MiNoUsers"
    }
  }

  depends_on = [null_resource.check_lambda_files]
}

resource "aws_lambda_function" "get_notes_lambda" {
  function_name = "mino_get_notes"
  filename      = "${path.module}/../../../backend/bin/get_notes.zip"
  handler       = "get_notes"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  timeout       = 10
  
  environment {
    variables = {
      NOTES_TABLE = "MiNoNotes"
      JWT_SECRET  = "local-dev-jwt-secret"
    }
  }

  depends_on = [null_resource.check_lambda_files]
}

resource "aws_lambda_function" "create_note_lambda" {
  function_name = "mino_create_note"
  filename      = "${path.module}/../../../backend/bin/create_note.zip"
  handler       = "create_note"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  timeout       = 10
  
  environment {
    variables = {
      NOTES_TABLE = "MiNoNotes"
      JWT_SECRET  = "local-dev-jwt-secret"
    }
  }

  depends_on = [null_resource.check_lambda_files]
}

resource "aws_lambda_function" "update_note_lambda" {
  function_name = "mino_update_note"
  filename      = "${path.module}/../../../backend/bin/update_note.zip"
  handler       = "update_note"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  timeout       = 10
  
  environment {
    variables = {
      NOTES_TABLE = "MiNoNotes"
      JWT_SECRET  = "local-dev-jwt-secret"
    }
  }

  depends_on = [null_resource.check_lambda_files]
}

resource "aws_lambda_function" "delete_note_lambda" {
  function_name = "mino_delete_note"
  filename      = "${path.module}/../../../backend/bin/delete_note.zip"
  handler       = "delete_note"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  timeout       = 10
  
  environment {
    variables = {
      NOTES_TABLE = "MiNoNotes"
      JWT_SECRET  = "local-dev-jwt-secret"
    }
  }

  depends_on = [null_resource.check_lambda_files]
} 