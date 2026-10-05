mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = { id = "ami-00000000000000000" }
  }
}
variables {
  bucket_name = "rajasurya-offline-test-bucket"
}
run "network_and_compute_plan" {
  command = plan
  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Use two availability zones."
  }
  assert {
    condition     = aws_instance.web.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.artifacts.block_public_policy
    error_message = "S3 must be private."
  }
}
