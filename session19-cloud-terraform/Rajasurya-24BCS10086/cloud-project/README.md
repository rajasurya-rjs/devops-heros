# cloud-project

[Complete commands, architecture, genuine AWS evidence and verified cleanup](../README.md)

Run Terraform in this folder with the `devops-homework` profile and selected Region `ap-southeast-2`.
The real VPC/EC2/S3 deployment, HTTP and AWS API checks, and twelve-resource destroy lifecycle were completed.
Mock-provider tests remain supplementary configuration checks and do not create AWS resources.

The optional `ami_id` input pins a previously provisioned image when this module is reused by the
final project, preventing replacement when AWS publishes a new AMI. Leaving it unset preserves
this session's existing latest-Amazon-Linux lookup. The completed Session 19 deployment and cleanup
evidence remain unchanged.
