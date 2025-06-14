terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  # LocalStack configuration
  endpoints {
    apigateway     = "http://192.168.0.250:4566"
    dynamodb       = "http://192.168.0.250:4566"
    lambda         = "http://192.168.0.250:4566"
    s3             = "http://192.168.0.250:4566"
    iam            = "http://192.168.0.250:4566"
    cloudwatchlogs = "http://192.168.0.250:4566"
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # S3 specific configurations for LocalStack
  s3_use_path_style = true
}

module "s3" {
  source = "./modules/s3"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "lambda" {
  source = "./modules/lambda"
  depends_on = [module.dynamodb]
}

module "apigateway" {
  source = "./modules/apigateway"
  lambda_invoke_arns = module.lambda.lambda_invoke_arns
  lambda_function_names = module.lambda.lambda_function_names
}

# Output the frontend URL
output "frontend_url" {
  value = "http://192.168.0.250:4566/${module.s3.bucket_name}/index.html"
}

# Output the API Gateway endpoint
output "api_endpoint" {
  value = module.apigateway.api_endpoint
}