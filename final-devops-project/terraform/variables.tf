variable "region" {
  type    = string
  default = "ap-southeast-2"
}
variable "bucket_name" { type = string }
variable "web_ami_id" {
  type        = string
  default     = null
  description = "Pin the provisioned web AMI to preserve the server when new images are published."
}
variable "web_cidr" {
  type    = string
  default = "192.0.2.1/32"
}
variable "cluster_version" {
  type        = string
  default     = null
  description = "Set an AWS-supported version when provisioning; null uses the service default."
}

variable "node_instance_type" {
  type        = string
  default     = "c7i-flex.large"
  description = "One 4 GiB worker for the application, CSI, ingress, and monitoring lab."
}
