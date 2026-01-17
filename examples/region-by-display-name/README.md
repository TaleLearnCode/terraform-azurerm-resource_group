# Region Selection by Display Name

This example shows how to choose the module's `location` by matching a human-friendly Azure region display name (e.g., "East US") to its region key (e.g., `eastus`). The module requires the region key, so we use the AVM regions utility module to map display names to keys.

## Usage

```hcl
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
  features {}
}

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

  lifecycle {
    precondition {
      condition     = local.selected_region != ""
      error_message = "No region key matched the desired display name."
    }
  }
}
```

## Notes
- The resource group module expects the region **key** (e.g., `eastus`), not the display name.
- The AVM regions utility exposes both the key and display name; we match on `display_name` and pass the corresponding key to `location`.
- Update `desired_display_name` to target a different region; the precondition fails early if no match is found.
- Outputs: `id`, `name`.
