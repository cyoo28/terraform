terraform {
  backend "s3" {
    bucket = "026090555438-terraform-state"
    key = "eks.tfstate"
    region = "us-east-1"
    profile = "ix-dev"
  }
}
