terraform {
  required_providers {
    aws     = { source = "hashicorp/aws" }
    azurerm = { source = "hashicorp/azurerm" }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}