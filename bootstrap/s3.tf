resource "aws_s3_bucket" "liberty-state-bucket" {
  bucket = "liberty-state-bucket"
  acl = "private"
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
}

resource "aws_s3_bucket_public_access_block" "liberty-state-bucket-access-block" {
  bucket = aws_s3_bucket.liberty-state-bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

##################################################################################

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-artifacts-liberty"
  acl    = "private"
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
} 

resource "aws_s3_bucket_public_access_block" "codepipeline-artifacts-access-block" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}
