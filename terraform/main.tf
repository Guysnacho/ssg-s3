terraform {
  cloud {
    organization = "blackbelt_init"

    workspaces {
      name = "SSG-S3"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.89.0"
    }
  }

  required_version = ">= 1.10.0"
}

provider "aws" {
  region = "us-west-2"
}
