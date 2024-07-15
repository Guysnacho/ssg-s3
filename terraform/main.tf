terraform {
  cloud {
    organization = "<PULL FROM HCP>"

    workspaces {
      name = "<CHOOSE WORKSPACE NAME>"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<PULL FROM REGISTRY>"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}
