resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "main" {
  identifier        = "${var.name}-db"
  engine            = "postgres"
  engine_version    = "16.4"
  instance_class    = "db.m7g.large"
  multi_az          = true
  allocated_storage = 200
  storage_type      = "gp3"

  db_subnet_group_name = aws_db_subnet_group.main.name
  username             = "app"
  manage_master_user_password = true
  skip_final_snapshot  = true
}

# Storage and request charges come from c3x-usage.yml.
resource "aws_s3_bucket" "assets" {
  bucket = "${var.name}-assets"
}

resource "aws_iam_role" "thumbnailer" {
  name = "${var.name}-thumbnailer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Requests and duration come from c3x-usage.yml.
resource "aws_lambda_function" "thumbnailer" {
  function_name = "${var.name}-thumbnailer"
  role          = aws_iam_role.thumbnailer.arn
  runtime       = "python3.12"
  handler       = "app.handler"
  filename      = "thumbnailer.zip"
  memory_size   = 1024
}
