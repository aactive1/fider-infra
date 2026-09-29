resource "aws_s3_bucket" "terraform_state" {
  bucket = "aaden04-fider-terraform-state-us-east-1"


  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "fider-terraform-state"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }

#checkov:skip=CKV2_AWS_62:No event consumer is planned for the Terraform state bucket
#checkov:skip=CKV_AWS_18: Revisit for a longer-lived setup, but for now this is a temporary bucket for the Terraform state
#checkov:skip=CKV2_AWS_61: retaining state versions rather than setting up an expiry during the project
#checkov:skip=CKV_AWS_144: no second region is planned
#checkov:skip=CKV_AWS_145: the bucket already has SSE-S3 encryption; not using KMS keys for now
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}