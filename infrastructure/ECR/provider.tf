terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
  }
  #  backend "s3" {
  #        bucket = "personal-aws-terraform-projects"
  #        key    = "aws_ecs_end-to-end_project/main/ecr_infra.tfstate"
  #        region = "us-east-1"
  #  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBY = "Terraform"
      region    = "us-east-1"
    }
  }
}