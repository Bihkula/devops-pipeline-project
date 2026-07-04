# tfsec:ignore:aws-s3-enable-bucket-logging -- Access logging requires a separate log-destination bucket, disproportionate for this learning project's state bucket. Revisit in Phase 12 capstone.
resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-pipeline-tf-state-592388987402"
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# tfsec:ignore:aws-s3-encryption-customer-key -- AES256 is sufficient for a personal-project TF state bucket; customer-managed KMS adds cost/complexity disproportionate to this resource's risk. Revisit for team/production use.
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# tfsec:ignore:aws-dynamodb-table-customer-key -- AWS-managed key is sufficient here; same reasoning as the S3 bucket above.
resource "aws_dynamodb_table" "tf_lock" {
  name         = "devops-pipeline-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}

