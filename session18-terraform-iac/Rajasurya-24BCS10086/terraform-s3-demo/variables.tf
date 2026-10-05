variable "region" {
  type    = string
  default = "ap-southeast-2"
}
variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name; contains no credentials."
}
