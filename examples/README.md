# Azure Resource Group Module - Examples

This directory contains example configurations demonstrating how to use the Azure Resource Group Terraform module.

## Overview

Each example is a self-contained Terraform configuration that demonstrates specific features and use cases of the module. All examples require Terraform >= 1.9 and the Azure provider.

## Examples

### 1. [Basic](./basic/)
**File:** [basic/README.md](./basic/README.md)

The simplest example showing how to create an Azure Resource Group with minimal required inputs.

**Demonstrates:**
- Basic resource group creation
- Optional tags configuration
- How to omit tags if not needed

**Key Features:**
- Minimal configuration
- Simple tag assignment
- Straightforward usage pattern

**Quick Start:**
```hcl
module "resource_group" {
  source = "../.."
  
  name     = "rg-example"
  location = "eastus"
  
  tags = {
    environment = "dev"
  }
}
```

---

### 2. [Locked](./locked/)
**File:** [locked/README.md](./locked/README.md)

Demonstrates how to apply management locks to protect resource groups from accidental deletion or modification.

**Demonstrates:**
- Applying `CanNotDelete` lock
- Applying `ReadOnly` lock
- Default lock naming convention
- Custom lock naming

**Key Features:**
- Prevents accidental resource deletion
- Protects against unauthorized modifications
- Customizable lock names
- Lock level selection (CanNotDelete, ReadOnly)

**Quick Start:**
```hcl
module "resource_group" {
  source = "../.."
  
  name     = "rg-locked-example"
  location = "eastus2"
  
  lock = {
    kind = "CanNotDelete"
    # name = "custom-lock-name"  # Optional: defaults to "{name}-lock"
  }
}
```

---

## Module Variables

All examples use the following module variables:

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | Yes | - | Name of the Azure Resource Group |
| `location` | string | Yes | - | Azure region for the resource group |
| `lock` | object | No | `{ kind = "None", name = null }` | Management lock configuration |
| `tags` | map(string) | No | `{}` | Tags for the resource group |

### Lock Object Schema

```hcl
lock = {
  kind = string       # Required: "None", "CanNotDelete", or "ReadOnly"
  name = string       # Optional: custom lock name, defaults to "{name}-lock"
}
```

---

## Module Outputs

All examples have access to the following module outputs:

```hcl
output "id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.this.name
}
```

---

## Prerequisites

### Required
- Terraform >= 1.9
- Azure Provider >= 4.0
- Azure Subscription (for applying examples)
- Appropriate Azure permissions

### Optional
- Azure CLI (for manual verification)
- Terraform Cloud account (for remote state)

---

## Running Examples

### Initialize Terraform
```bash
cd examples/<example-name>
terraform init
```

### Plan Deployment
```bash
terraform plan
```

### Apply Configuration
```bash
terraform apply
```

### Destroy Resources
```bash
terraform destroy
```

---

## Environment Setup

### Azure Authentication

Set Azure credentials via environment variables:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

Or use Azure CLI:
```bash
az login
```

---

## Example Use Cases

### Development Environments
Use the **Basic** example with appropriate tags:
```hcl
module "dev_rg" {
  source = "module-source"
  
  name     = "rg-dev-001"
  location = "eastus"
  
  tags = {
    environment = "dev"
    team        = "platform"
    cost-center = "engineering"
  }
}
```

### Production Environments
Use the **Locked** example with `CanNotDelete` protection:
```hcl
module "prod_rg" {
  source = "module-source"
  
  name     = "rg-prod-001"
  location = "eastus"
  
  lock = {
    kind = "CanNotDelete"
    name = "prod-resource-lock"
  }
  
  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

### Multi-Region Deployments
Use the **Region by Display Name** example:
```hcl
module "us_rg" {
  source = "module-source"
  
  name     = "rg-us-001"
  location = local.us_region  # Maps "East US" → "eastus"
}

module "eu_rg" {
  source = "module-source"
  
  name     = "rg-eu-001"
  location = local.eu_region  # Maps "UK South" → "uksouth"
}
```

---

## Choosing an Example

| Use Case | Recommended Example | Reason |
|----------|-------------------|--------|
| Quick start / Learning | **Basic** | Simplest, demonstrates core features |
| Production workloads | **Locked** | Adds protection against deletion |
| Multi-region deployments | **Region by Display Name** | Safer region selection with validation |
| Custom configurations | Combine any approach | Mix and match features as needed |

---

## Testing Examples

Each example is automatically tested by the CI/CD pipeline:

### Terraform Format
```bash
terraform fmt -check
```

### Terraform Validate
```bash
terraform validate
```

### Terraform Plan
```bash
terraform plan
```

### Terraform Test
```bash
terraform test -verbose
```

---

## Troubleshooting

### Module Not Found
Ensure the module source path is correct:
```hcl
source = "../.."  # From examples/<name> → root module
```

### Azure Authentication Issues
```bash
# Verify credentials
az account show

# Re-authenticate if needed
az login
```

### Invalid Location
Ensure the location is a valid Azure region:
```bash
# List available regions
az account list-locations --query "[].name" -o table
```

---

## Additional Resources

- [Module README](../README.md) - Main module documentation
- [Module Variables](../variables.tf) - Complete variable definitions
- [Module Outputs](../output.tf) - Available outputs
- [Changelog](../CHANGELOG.md) - Version history
- [Azure Regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/) - Available Azure regions

---

## Getting Help

For issues or questions:

1. **Check Example Documentation** - Each example has a dedicated README.md
2. **Review Module README** - See main module documentation
3. **Test Locally** - Run examples in your environment
4. **Check Logs** - Use `-verbose` flag for detailed output

---

## Contributing

When adding new examples:

1. Create a new directory under `examples/`
2. Include `main.tf` with the example configuration
3. Include `README.md` with usage instructions
4. Update this index file
5. Test with `terraform init`, `terraform validate`, and `terraform plan`

---

## License

These examples are provided as-is with the module. See the [main LICENSE](../LICENSE) for details.
