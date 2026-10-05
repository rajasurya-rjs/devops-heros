mock_provider "aws" {}
run "private_versioned_bucket" {
  command = plan
  assert {
    condition     = aws_s3_bucket_public_access_block.homework.block_public_policy && aws_s3_bucket_public_access_block.homework.restrict_public_buckets
    error_message = "Public access must remain blocked."
  }
  assert {
    condition     = aws_s3_bucket_versioning.homework.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be enabled."
  }
}
