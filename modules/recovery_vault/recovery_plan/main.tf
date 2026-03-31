# locals {
#   module_tag = {
#     "module" = basename(abspath(path.module))
#   }
#   tags = var.base_tags ? merge(
#     var.global_settings.tags,
#     local.module_tag,
#     try(var.settings.tags, null)
#     ) : merge(
#     local.module_tag,
#     try(var.settings.tags,
#     null)
#   )
# }


# terraform {
#   required_providers {
#     azurecaf = {
#       source = "aztfmod/azurecaf"
#     }
#   }
# }


terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.0"
    }
  }
}
