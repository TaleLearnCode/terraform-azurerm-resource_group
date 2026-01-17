# Basic Resource Group Example

This example shows the minimal inputs needed to provision an Azure Resource Group with this module. Tags are optional and can be omitted if not required.

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

module "resource_group" {
  source = "../.."

  name     = "rg-basic-example"
  location = "eastus"

  # Tags are optional; remove this block if you do not need tags
  tags = {
    environment = "dev"
    owner       = "example"
  }
}
```

## Notes
- `location` must be one of the region keys returned by the AVM regions module (e.g., `eastus`, `westus2`).
- Omit the `tags` block entirely if you do not want to apply tags.
- Outputs exposed by the module: `id`, `name`.
