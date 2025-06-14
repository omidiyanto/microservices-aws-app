resource "aws_s3_bucket" "frontend" {
  bucket = "mino-frontend"
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "frontend" {
  depends_on = [
    aws_s3_bucket_public_access_block.frontend,
    aws_s3_bucket_ownership_controls.frontend,
  ]

  bucket = aws_s3_bucket.frontend.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "frontend" {
  depends_on = [aws_s3_bucket_public_access_block.frontend]
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

# Upload frontend files
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.frontend.id
  key    = "index.html"
  source = "${path.module}/../../../frontend/index.html"
  content_type = "text/html"
  acl    = "public-read"

  depends_on = [aws_s3_bucket_acl.frontend]
}

resource "aws_s3_object" "js" {
  bucket = aws_s3_bucket.frontend.id
  key    = "app.js"
  source = "${path.module}/../../../frontend/app.js"
  content_type = "application/javascript"
  acl    = "public-read"

  depends_on = [aws_s3_bucket_acl.frontend]
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.frontend.id
  key    = "styles.css"
  source = "${path.module}/../../../frontend/styles.css"
  content_type = "text/css"
  acl    = "public-read"

  depends_on = [aws_s3_bucket_acl.frontend]
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.frontend.id
  key    = "error.html"
  source = "${path.module}/../../../frontend/error.html"
  content_type = "text/html"
  acl    = "public-read"

  depends_on = [aws_s3_bucket_acl.frontend]
} 