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

# Use the AVM regions utility to select a region by its display name, then pass the region key into the module.
module "regions" {
  source           = "Azure/avm-utl-regions/azurerm"
  version          = "~> 0.9.3"
  enable_telemetry = false
}

locals {
  desired_display_name = "East US"
  region_keys_matching = [for key, region in module.regions.regions : key if lower(region.display_name) == lower(local.desired_display_name)]
  selected_region      = length(local.region_keys_matching) > 0 ? element(local.region_keys_matching, 0) : ""
}

module "resource_group" {
  source = "../.."

  name     = "rg-region-by-display-name"
  location = local.selected_region

  tags = {
    environment = "test"
  }
}

# Fail fast if the display name did not match any region keys.
check "region_validation" {
  assert {
    condition     = local.selected_region != ""
    error_message = "No region key matched the desired display name."
  }
}