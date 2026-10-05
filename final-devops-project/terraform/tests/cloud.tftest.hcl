mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/mock-homework" }
  }
  mock_data "aws_ami" {
    defaults = { id = "ami-00000000000000000" }
  }
}
variables { bucket_name = "rajasurya-final-offline-test" }
override_module {
  target = module.cloud
  outputs = {
    subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
    vpc_id      = "vpc-00000000000000000"
    instance_id = "i-00000000000000000"
    web_url     = "http://192.0.2.1"
    bucket_name = "rajasurya-final-offline-test"
  }
}
run "cluster_configuration" {
  command = plan
  assert {
    condition     = aws_eks_node_group.main.scaling_config[0].desired_size == 1
    error_message = "The lab should start with one worker."
  }
  assert {
    condition     = aws_eks_cluster.main.vpc_config[0].endpoint_private_access
    error_message = "Workers need private control-plane connectivity."
  }
}
