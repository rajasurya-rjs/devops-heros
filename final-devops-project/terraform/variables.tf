variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "bucket_name" { type = string }
variable "web_cidr" {
  type    = string
  default = "192.0.2.1/32"
}
variable "cluster_version" {
  type        = string
  default     = null
  description = "Set an AWS-supported version when provisioning; null uses the service default."
}
