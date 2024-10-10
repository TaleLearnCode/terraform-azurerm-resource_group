# #############################################################################
# Modules
# #############################################################################

module "regions" {
  source  = "TaleLearnCode/regions/azurerm"
  version = "0.0.1-pre"
  azure_region = var.location
}