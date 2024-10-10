# Example: Manage an Azure Resource Group

This module manages Azure Resource Groups using the [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) Terraform provider.  This example shows how to use the module to manage an Azure Resource using a generated name that conforms with the Microsoft Cloud Adoption Framework

## Example Usage

```hcl
module "example" {
  source  = "TaleLearnCode/resource_group/azurerm"
  version = "0.0.1-pre"
  providers = {
    azurerm = azurerm
  }

  srv_comp_abbr = "ILP"
  environment   = "dev"
  location      = "northcentralus"
}

output "resource_group_id" {
  value = module.example.resource_group.id
}

output "resource_group_name" {
  value = module.example.resource_group.name
}

output "resource_group_location" {
  value = module.example.resource_group.location
}
```

You are specifying three values:

- **srv_comp_abbr**: The abbreviation of the service or component for which the resources are being created for.
- **environment**: The environment where the resources are deployed to.
- **location**: The Azure Region in which all resources will be created.

> By convention, the module lower cases supplied name segments when generated the resource name.

This will result in an Azure Resource Group named: `rg-ILP-dev-usnc`.