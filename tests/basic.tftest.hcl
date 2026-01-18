mock_provider "azurerm" {}

run "basic_no_lock" {
  command = plan

  variables {
    name     = "rg-basic"
    location = "eastus"
    lock = {
      kind = "None"
      name = null
    }
    tags = {
      environment = "dev"
    }
  }
}

run "lock_default_name" {
  command = plan

  variables {
    name     = "rg-locked"
    location = "eastus2"
    lock = {
      kind = "CanNotDelete"
      name = null
    }
    tags = {}
  }
}

run "lock_custom_name" {
  command = plan

  variables {
    name     = "rg-custom-lock"
    location = "westus2"
    lock = {
      kind = "ReadOnly"
      name = "custom-lock-name"
    }
    tags = {}
  }
}

