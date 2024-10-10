# Azure Resource Group Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md)

This module manages an Azure Resource Group using the [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) Terraform provider.

## Providers

| Name    | Version |
| ------- | ------- |
| azurerm | ~> 4.1. |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| Regions | TaleLearnCode/regions/azurerm | ~> .0.0.1-pre |

## Resources

No resources.

## Usage

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
```

For more detailed instructions on using this module: please refer to the appropriate example:

- [Default](examples/default/README.md)

## Inputs

| Name            | Description                                                  | Type   | Default | Required |
| --------------- | ------------------------------------------------------------ | ------ | ------- | -------- |
| environment     | The environment where the resources are deployed to. | string | N/A     | yes      |
| location        | The Azure Region in which all resources will be created      | string | N/A     | yes      |
| subscription_id | The Azure Subscription Id to use for creating resources      | string | N/A     | yes      |
| name_prefix     | Optional prefix to apply to the generated name.              | string | ""      | no       |
| name_suffix     | Optional suffix to apply to the generated name.              | string | ""      | no       |
| srv_comp_abbr   | The abbreviation of the service or component for which the resources are being created for. | string | NULL    | no       |
| custom_name     | If set, the custom name to use instead of the generated name. | string | NULL    | no       |
| tags            | A map of tags to apply to all resources.                     | map    | N/A     | no       |

## Outputs

| Name           | Description                       |
|----------------|-----------------------------------|
| resource_group | The managed Azure Resource Group. |