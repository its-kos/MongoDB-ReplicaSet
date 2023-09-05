terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0" // latest at time of writing
        }
    }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  //access_key = "my-access-key"
  //secret_key = "my-secret-key"
}