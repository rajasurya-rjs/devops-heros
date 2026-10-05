terraform {
  required_version = ">= 1.7, < 2.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
module "cloud" {
  source      = "../../session19-cloud-terraform/Rajasurya-24BCS10086/cloud-project"
  region      = var.region
  name        = "rajasurya-final-devops"
  bucket_name = var.bucket_name
  web_cidr    = var.web_cidr
}
