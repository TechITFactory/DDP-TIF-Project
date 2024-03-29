terraform {
  backend "s3" {
    bucket         = "techit-1707050150"
    region         = "us-east-1"
    key            = "DDP-TIF-Project/DevOps/Jenkins-Server-TF/terraform.tfstate"
    dynamodb_table = "Lock-Files-EKS"
    encrypt        = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}