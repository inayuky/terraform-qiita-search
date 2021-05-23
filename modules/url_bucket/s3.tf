variable "name" {
  description = "バケット名"
}
variable "vpc_id" {
  description = "アクセス元VPCのID(このVPCからのみアクセス可能)"
}
variable "route_table_ids" {
  description = "VPCエンドポイントを配置するルートテーブルのID"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = var.vpc_id
  route_table_ids = var.route_table_ids
  service_name    = "com.amazonaws.ap-northeast-1.s3"
}

resource "aws_s3_bucket" "private" {
  bucket = var.name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # バケットが空ではなくてもdestroyで削除できる
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.private]
}

resource "aws_s3_bucket_policy" "read_vpc_only" {
  bucket = aws_s3_bucket.private.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Read-VPC-Only"
    Statement = [
      {
        Sid       = "VPCAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.private.arn}/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpc" = var.vpc_id
          }
        }
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.private]
}
