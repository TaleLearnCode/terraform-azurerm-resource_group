module "regions" {
  source           = "Azure/avm-utl-regions/azurerm"
  version          = "~> 0.11.0"
  enable_telemetry = false
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    precondition {
      condition     = length(regexall("^[a-z0-9]+$", replace(replace(var.location, " ", ""), "-", ""))) > 0
      error_message = "location must be a valid Azure region name (lowercase letters, numbers, and hyphens only)."
    }
  }
}

resource "azurerm_management_lock" "this" {
  count      = var.lock.kind != "None" ? 1 : 0
  name       = var.lock.name != null ? var.lock.name : "${var.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = var.lock.kind
  notes      = "Managed by Terraform"
}