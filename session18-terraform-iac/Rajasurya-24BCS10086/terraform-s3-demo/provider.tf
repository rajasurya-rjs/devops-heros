terraform {
  required_version = ">= 1.7, < 2.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
provider "aws" {
  region = var.region
  default_tags {
    tags = { Owner = "Rajasurya", Enrollment = "24BCS10086", Purpose = "DevOps homework" }
  }
}
