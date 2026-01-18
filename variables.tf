variable "name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

#condition     = contains(keys(module.regions.regions), var.location)

variable "location" {
  description = "The Azure region for deployment of the Azure Resource Group"
  type        = string

  validation {
    condition     = contains(keys(module.regions.regions_by_name), var.location)
    error_message = "The provided location is not a valid Azure region according to AVM regions."
  }
}

variable "lock" {
  description = "The lock kind (None, CanNotDelete, ReadOnly) and optionally name"
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = {
    kind = "None"
    name = null
  }

  validation {
    condition     = contains(["None", "CanNotDelete", "ReadOnly"], var.lock.kind)
    error_message = "Lock kind must be one of: None, CanNotDelete, or ReadOnly."
  }
}

variable "tags" {
  description = "Tags for the resource group"
  type        = map(string)
  default     = {}
}
