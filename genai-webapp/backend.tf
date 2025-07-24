terraform {
  backend "s3" {
    bucket = "026090555438-terraform-state"
    key = "genai-webapp.tfstate"
    region = "us-east-1"
    profile = "ix-dev"
  }
}
