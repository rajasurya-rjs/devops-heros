variable "region" {
  type    = string
  default = "ap-southeast-2"
}
variable "name" {
  type    = string
  default = "rajasurya-devops-hw19"
}
variable "bucket_name" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "web_cidr" {
  type        = string
  description = "CIDR allowed to access HTTP; set your own public IPv4/32."
  default     = "192.0.2.1/32"
}
