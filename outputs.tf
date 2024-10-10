# #############################################################################
# Outputs
# #############################################################################

output "resource_group" {
  value = azurerm_resource_group.rg
  description = "The Azure Resource Group."
}