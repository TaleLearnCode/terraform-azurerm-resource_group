# Region by Display Name Example

This example demonstrates how to safely select an Azure region by its display name using the Azure Verified Module (AVM) for regions.

## Overview

Instead of hardcoding region keys (like `westus2`), this example uses the AVM regions module to map human-readable display names to region keys. This approach is:

- **Safe** - Automatically validates region display names
- **Readable** - Uses familiar region names like "West US 2"
- **Maintainable** - Region names are managed centrally
- **Flexible** - Easy to change regions in code

## Usage

```hcl
module "rg" {
  source = "path-to-module"

  name     = "rg-example"
  location = module.regions.regions_by_display_name["West US 2"]

  lock = {
    kind = "None"
  }

  tags = {}
}
```

## Configuration

Update the region by changing the display name in the `regions_by_display_name` map:

**Common Azure Regions:**
- "East US"
- "West US"
- "West US 2"
- "Central US"
- "South Central US"
- "North Central US"
- "East US 2"
- "Canada Central"
- "Canada East"
- "UK South"
- "UK West"
- "West Europe"
- "North Europe"
- "France Central"
- "Germany West Central"
- "Switzerland North"
- "Sweden Central"
- "Australia East"
- "Australia Southeast"
- "Japan East"
- "Japan West"
- "Korea Central"
- "Korea South"
- "Southeast Asia"
- "East Asia"
- "South India"
- "Central India"
- "West India"
- "Brazil South"
- "Saudi Arabia North"
- "UAE North"
- "South Africa North"

## Prerequisites

Before running this example, ensure you have:

1. **Terraform** installed (v1.5.0 or higher)
2. **Azure CLI** authenticated:
   ```bash
   az login
   ```
3. **Valid Azure Subscription:**
   ```bash
   export ARM_SUBSCRIPTION_ID="your-subscription-id"
   ```

## Running the Example

### Initialize Terraform

```bash
terraform init
```

### Plan the Deployment

```bash
terraform plan \
  -var="subscription_id=$ARM_SUBSCRIPTION_ID"
```

### Apply the Configuration

```bash
terraform apply \
  -var="subscription_id=$ARM_SUBSCRIPTION_ID"
```

### Destroy Resources

```bash
terraform destroy \
  -var="subscription_id=$ARM_SUBSCRIPTION_ID"
```

## Outputs

After applying, the example outputs:

- **resource_group_id** - The ID of the created Resource Group
- **resource_group_name** - The name of the Resource Group
- **region_key** - The actual region key used (e.g., `westus2`)

View outputs:

```bash
terraform output
```

## How It Works

### Step 1: Load Regions Module

```hcl
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.9"
}
```

This module provides:
- `regions` - Map of all valid Azure regions by key
- `regions_by_display_name` - Map of regions by human-readable names

### Step 2: Reference Region by Display Name

```hcl
location = module.regions.regions_by_display_name["West US 2"]
```

This safely converts "West US 2" → "westus2"

### Step 3: Use Location in Module

```hcl
module "resource_group" {
  source = "../.."
  
  location = module.regions.regions_by_display_name["West US 2"]
}
```

## Benefits vs Hardcoding

### ❌ Hardcoded Region
```hcl
location = "westus2"  # Easy to typo, hard to remember
```

### ✅ Display Name Mapping
```hcl
location = module.regions.regions_by_display_name["West US 2"]  # Clear, validated
```

## Changing Regions

To create a Resource Group in a different region, update the display name:

```hcl
# Current: West US 2
location = module.regions.regions_by_display_name["West US 2"]

# Change to: East US
location = module.regions.regions_by_display_name["East US"]
```

Then apply:

```bash
terraform apply \
  -var="subscription_id=$ARM_SUBSCRIPTION_ID"
```

## Error Handling

### Invalid Display Name

If you use an invalid region display name:

```hcl
location = module.regions.regions_by_display_name["Invalid Region"]
```

You'll get a clear error:

```
Error: Unsupported attribute

  on main.tf line XX:
   XX:   location = module.regions.regions_by_display_name["Invalid Region"]
```

**Solution:** Use a valid Azure region display name from the list above.

## Advanced: Combining with Locks

This example can be extended to include management locks:

```hcl
module "resource_group" {
  source = "../.."

  name     = "rg-region-by-name"
  location = module.regions.regions_by_display_name["West US 2"]

  lock = {
    kind = "CanNotDelete"
    name = "rg-lock"
  }

  tags = {}
}
```

## Cleanup

Remove all resources created by this example:

```bash
terraform destroy \
  -var="subscription_id=$ARM_SUBSCRIPTION_ID"
```

## Related Examples

- [basic](../basic/) - Minimal Resource Group creation
- [locked](../locked/) - Resource Group with management locks

## References

- [Azure Verified Module for Regions](https://registry.terraform.io/modules/Azure/avm-utl-regions/azurerm/latest)
- [Azure Regions Naming](https://learn.microsoft.com/en-us/azure/azure-regions)
- [Terraform Modules Documentation](https://www.terraform.io/language/modules)
