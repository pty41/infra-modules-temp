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

variable "env" {
  type        = string
  description = "Name of the environment"
}

