terraform {
  cloud {
    organization = "tunjiprod"

    workspaces {
      name = "SSG-S3"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}
