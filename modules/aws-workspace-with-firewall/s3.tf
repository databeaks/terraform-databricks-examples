resource "aws_s3_bucket" "root_storage_bucket" {
  bucket = "${local.prefix}-rootbucket"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-rootbucket"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "root_storage_bucket" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}