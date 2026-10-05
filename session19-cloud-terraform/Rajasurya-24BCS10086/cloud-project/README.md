# cloud-project

[Setup, architecture, commands, results and screenshots](../README.md)

Run Terraform in this folder using the `devops-homework` profile in `ap-southeast-2`.
The configuration tests use a mock provider. The session README covers deployment,
resource checks and cleanup.

The optional `ami_id` input pins an image when the final project reuses this module.
Leaving it unset uses the latest Amazon Linux AMI lookup.
