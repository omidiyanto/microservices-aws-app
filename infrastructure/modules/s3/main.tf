resource "aws_s3_bucket" "frontend" {
  bucket = "mino-frontend"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket
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

# Upload frontend files - in practice, this would be done with a more sophisticated mechanism
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.frontend.bucket
  key    = "index.html"
  source = "${path.module}/../../../frontend/index.html"
  content_type = "text/html"
  etag = filemd5("${path.module}/../../../frontend/index.html")
  depends_on = [aws_s3_bucket.frontend]
}

resource "aws_s3_object" "js" {
  bucket = aws_s3_bucket.frontend.bucket
  key    = "app.js"
  source = "${path.module}/../../../frontend/app.js"
  content_type = "application/javascript"
  etag = filemd5("${path.module}/../../../frontend/app.js")
  depends_on = [aws_s3_bucket.frontend]
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.frontend.bucket
  key    = "styles.css"
  source = "${path.module}/../../../frontend/styles.css"
  content_type = "text/css"
  etag = filemd5("${path.module}/../../../frontend/styles.css")
  depends_on = [aws_s3_bucket.frontend]
} 