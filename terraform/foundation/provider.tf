terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-pipeline-tf-state-592388987402"
    key            = "foundation/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "devops-pipeline-tf-lock"
    encrypt        = true
    profile        = "devops-project"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "devops-project"
}
