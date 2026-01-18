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

# Use the Azure Verified Module for Regions to safely select region by display name
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.9"
}

# Select the region by display name and use the region key for location
module "resource_group" {
  source = "../.."

  name = "rg-region-by-name-example"
  # Use region key instead of display name - access the 'name' property to get the region key
  location = module.regions.regions_by_display_name["West US 2"].name

  lock = {
    kind = "None"
    name = null
  }

  tags = {
    environment = "test"
    example     = "region-by-display-name"
  }
}

output "resource_group_id" {
  description = "The ID of the created Resource Group"
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "The name of the created Resource Group"
  value       = module.resource_group.name
}

output "region_key" {
  description = "The region key used for the Resource Group location"
  value       = module.regions.regions_by_display_name["West US 2"]
}
