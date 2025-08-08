terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "ix-dev"
}