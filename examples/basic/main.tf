variable "subscription_id" {
  description = "The Azure Subscription ID where the Resource Group will be created"
  type        = string
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

module "resource_group" {
  source = "../.."

  name     = "rg-basic-example"
  location = "eastus"

  # Tags are optional; include only what you need.
  tags = {
    environment = "dev"
    owner       = "example"
  }
}