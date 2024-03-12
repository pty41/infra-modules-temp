# Define the Terraform backend configuration
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }

  backend "s3" {}
}

# Define variables
variable "env" {
  type        = string
  description = "Name of environment"
}

