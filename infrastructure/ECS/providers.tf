terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }
      backend "s3" {
          bucket = "hackathon2024"
          key    = "hackathon2024/main/ecs_infra.tfstate"
          region = "us-east-1"
    }
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