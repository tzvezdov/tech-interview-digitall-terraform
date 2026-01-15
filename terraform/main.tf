terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "tfstate-q2-digital"
    key    = "terraform.tfstate"
    region = "eu-north-1"

    encrypt = true
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Environment = "technical-interview"
      ManagedBy   = "terraform"
    }
  }
}
