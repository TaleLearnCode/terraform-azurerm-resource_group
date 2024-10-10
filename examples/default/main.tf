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