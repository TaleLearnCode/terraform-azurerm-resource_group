# Azure Resource Group Terraform Module

[![Validate](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/validate.yml/badge.svg)](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/validate.yml)
[![Test](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/test.yml/badge.svg)](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/test.yml)
[![Quality](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/quality.yml/badge.svg)](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/quality.yml)
[![Release](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/release.yml/badge.svg)](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/actions/workflows/release.yml)

A production-ready Terraform module for creating and managing Azure Resource Groups with comprehensive features including management locks, location validation, and optional tagging.

## Features

- ✅ **Simple Resource Group Creation** - Quick deployment with minimal configuration
- 🔒 **Management Locks** - Protect resource groups from accidental deletion or modification
  - `CanNotDelete` lock for deletion protection
  - `ReadOnly` lock for complete modification prevention
  - Optional custom lock naming
- 🌍 **Location Validation** - Validated against Azure Verified Modules (AVM) regions utility
- 🏷️ **Optional Tags** - Apply consistent tagging across resource groups

---

## Usage

### Basic Example

Create a simple resource group with minimal configuration:

```hcl
module "resource_group" {
  source = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "~> 0.1"

  name     = "rg-dev-001"
  location = "eastus"
}
```

### With Tags

Add tags for resource organization and cost tracking:

```hcl
module "resource_group" {
  source  = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "~> 0.1"

  name     = "rg-prod-001"
  location = "eastus"

  tags = {
    environment  = "production"
    team         = "platform"
    cost-center  = "engineering"
    managed-by   = "terraform"
  }
}
```

### With Management Lock

Protect resource groups from accidental deletion:

```hcl
module "resource_group" {
  source  = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "~> 0.1"

  name     = "rg-prod-critical"
  location = "eastus"

  lock = {
    kind = "CanNotDelete"
    # name = "custom-lock-name"  # Optional: defaults to "{name}-lock"
  }

  tags = {
    environment = "production"
  }
}
```

### With Read-Only Lock

Prevent all modifications to resource group:

```hcl
module "resource_group" {
  source  = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "~> 0.1"

  name     = "rg-compliance"
  location = "westus2"

  lock = {
    kind = "ReadOnly"
    name = "compliance-lock"
  }
}
```

### Using Display Names for Regions

Select regions using human-friendly names instead of region keys:

```hcl
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.9"
}

locals {
  desired_region = "East US"
  region_key = [
    for key, region in module.regions.regions :
    key if lower(region.display_name) == lower(local.desired_region)
  ][0]
}

module "resource_group" {
  source  = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "~> 0.1"

  name     = "rg-regional"
  location = local.region_key
}
```

### Multi-Region Deployment

Deploy resource groups across multiple regions:

```hcl
locals {
  locations = {
    us  = "eastus"
    eu  = "westeurope"
    asia = "southeastasia"
  }

  tags = {
    managed-by = "terraform"
  }
}

module "resource_groups" {
  for_each = local.locations

  source  = "terraform-registry-url/azurerm-resource-group/azurerm"
  version = "~> 0.1"

  name     = "rg-${each.key}"
  location = each.value
  tags     = local.tags
}

output "resource_groups" {
  value = {
    for key, rg in module.resource_groups :
    key => {
      id   = rg.id
      name = rg.name
    }
  }
}
```

## Requirements

### Terraform

- **Minimum Version:** 1.9
- **Recommended Version:** 1.9.x or later

### Azure

- Active Azure subscription
- Appropriate permissions to create resource groups
- Azure Provider v4.0 or later

## Providers

| Name | Version | Scope |
|------|---------|-------|
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) | `~> 4.0` | Azure resources and management locks |
| [azurerm (alias: regions)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) | `~> 4.0` | AVM regions utility module |

### Module Dependencies

This module uses the Azure Verified Modules (AVM) regions utility:

| Name | Source | Version |
|------|--------|---------|
| regions | `Azure/avm-utl-regions/azurerm` | `~> 0.9` |

## Resources

This module creates and manages the following Azure resources:

| Name | Type | Purpose |
|------|------|---------|
| `azurerm_resource_group` | `resource` | Azure Resource Group container |
| `azurerm_management_lock` | `resource` | Management lock for protection (conditional) |

### Resource Details

#### azurerm_resource_group

Creates the Azure Resource Group with the specified name, location, and tags.

- **Includes:** Lifecycle precondition to validate location against AVM regions
- **Attributes:** Name, location, tags
- **Output:** Resource group ID and name

#### azurerm_management_lock

Creates a management lock if `lock.kind != "None"`.

- **Count:** Conditional based on lock kind
- **Types:** CanNotDelete, ReadOnly
- **Scope:** Resource group
- **Name:** Custom or auto-generated as `{resource-group-name}-lock`

## Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `name` | `string` | N/A | Yes | Name of the Azure Resource Group |
| `location` | `string` | N/A | Yes | Azure region for resource deployment (validated against AVM regions) |
| `lock` | `object` | `{ kind = "None", name = null }` | No | Management lock configuration |
| `tags` | `map(string)` | `{}` | No | Tags to apply to the resource group |

### Input Details

#### name

```hcl
name = "rg-example"
```

- **Type:** string
- **Required:** Yes
- **Validation:** Standard Azure naming conventions (alphanumeric, hyphens)
- **Example Values:**
  - `rg-production-001`
  - `rg-dev-platform`
  - `rg-infrastructure`

#### location

```hcl
location = "eastus"
```

- **Type:** string
- **Required:** Yes
- **Validation:** Must be valid Azure region key
  - Validated against AVM regions module
  - Common values: `eastus`, `westus2`, `westeurope`, `southeastasia`
  - Use display names via AVM utility for human-friendly input
- **Note:** Precondition ensures only valid regions accepted

#### lock

```hcl
lock = {
  kind = "CanNotDelete"
  name = "custom-lock-name"
}
```

- **Type:** `object({ kind = string, name = optional(string) })`
- **Default:** `{ kind = "None", name = null }`
- **Required:** No
- **Options:**
  - `kind = "None"` - No lock applied
  - `kind = "CanNotDelete"` - Prevent deletion
  - `kind = "ReadOnly"` - Prevent all modifications
- **name Sub-attribute:**
  - Type: optional string
  - Default: `null` (auto-generated as `{resource-group-name}-lock`)
  - Use custom name for specific lock naming requirements

#### tags

```hcl
tags = {
  environment = "production"
  team        = "platform"
  cost-center = "engineering"
}
```

- **Type:** `map(string)`
- **Default:** `{}`
- **Required:** No
- **Recommended Tags:**
  - `environment` - dev/staging/prod
  - `team` - Owning team
  - `cost-center` - Cost tracking
  - `managed-by` - Infrastructure tool
  - `created-date` - Creation timestamp

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | The ID of the created resource group |
| `name` | `string` | The name of the created resource group |

### Output Details

#### id

The fully qualified Azure resource ID for the resource group.

```hcl
output "resource_group_id" {
  value = module.resource_group.id
}

# Output: /subscriptions/{subscriptionId}/resourceGroups/rg-example
```

#### name

The name of the created resource group.

```hcl
output "resource_group_name" {
  value = module.resource_group.name
}

# Output: rg-example
```

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines on:

- Getting started and setting up development environment
- Development workflow and best practices
- Commit message conventions
- Pull request process
- Testing requirements
- Documentation standards
- Code review process
- Reporting bugs and suggesting features

Thank you for helping improve this project!

---

## License

This module is licensed under the [MIT License](./LICENSE).

This allows:
- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use

## Support

### Issues

Report issues on [GitHub Issues](https://github.com/TaleLearnCode/terraform-azurerm-resource_group/issues):
- Include Terraform version
- Include provider version
- Include example configuration
- Include error output

### Documentation

- 📖 [Module Examples](./examples/README.md)
- 📖 [CI/CD Pipelines](./.github/GitHubActions.md)
- 📖 [Changelog](./CHANGELOG.md)

### Community

- [Terraform Community Slack](https://hashicorp-community.slack.com/)
- [Terraform Discuss Forum](https://discuss.hashicorp.com/c/terraform)
- [Azure Terraform Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Release Notes

See [CHANGELOG.md](./CHANGELOG.md) for release history and version information.

### Version Support

- **Current:** v0.1.0 (January 2026)
- **Status:** Stable
- **Support:** Active development

## Related Resources

### Similar Modules

- [terraform-azurerm-resource-group](https://github.com/Azure/terraform-azurerm-resource-group)
- [aztf-resource-group](https://github.com/aztfmods/module-avm-res-resources-resourcegroup)

### Azure Documentation

- [Azure Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Azure Regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/)
- [Management Locks](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources)

### Terraform Documentation

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/recommended-practices)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Module Testing](https://developer.hashicorp.com/terraform/language/tests)
