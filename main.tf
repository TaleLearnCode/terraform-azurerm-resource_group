module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.9.3"
  enable_telemetry = false
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    precondition {
      condition     = contains(keys(module.regions.regions), var.location)
      error_message = "location must be one of the regions returned by module.regions."
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