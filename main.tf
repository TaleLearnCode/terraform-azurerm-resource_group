# #############################################################################
# Terraform Module: Azure Resource Group
# #############################################################################

module "resource_name" {
  source  = "TaleLearnCode/naming/azurerm"
  version = "0.0.2-pre"

  resource_type  = "resource_group"
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
  srv_comp_abbr  = var.srv_comp_abbr
  custom_name    = var.custom_name
  location       = var.location
  environment    = var.environment
}

resource "azurerm_resource_group" "rg" {
  name     = module.resource_name.resource_name
  location = var.location
  tags     = var.tags
}