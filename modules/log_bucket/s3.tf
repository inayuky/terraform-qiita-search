variable "name" {
  description = "バケット名"
}

resource "aws_s3_bucket" "alb_log" {
  bucket = var.name

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }

  # バケットが空ではなくてもdestroyで削除できる
  force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_elb_service_account" "current" {}

# ALB等のAWSサービスからアクセスする際に必要
data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.current.id]
    }
  }
}

output "bucket_id" {
  value = aws_s3_bucket.alb_log.id
}
