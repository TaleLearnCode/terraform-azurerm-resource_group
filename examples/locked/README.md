# Locked Resource Group Example

This example provisions a resource group with a management lock. You can add a custom lock name if desired; otherwise it defaults to `{name}-lock`.

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

  name     = "rg-locked-example"
  location = "eastus2"

  lock = {
    kind = "CanNotDelete" # or "ReadOnly"
    # name = "custom-lock-name" # optional; defaults to "{name}-lock"
  }

  tags = {
    environment = "prod"
    managed_by  = "terraform"
  }
}
```

## Notes
- Valid lock kinds: `None`, `CanNotDelete`, `ReadOnly`.
- If `lock.kind` is not `None`, a management lock is created at the resource group scope.
- `location` must be one of the region keys returned by the AVM regions module.
- Outputs: `id`, `name`.
