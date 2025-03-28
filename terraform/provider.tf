terraform {
  backend "s3" {
    bucket         = "kevloh-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
