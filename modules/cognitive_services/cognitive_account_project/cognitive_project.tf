// resource "azurecaf_name" "service" {
//   name          = var.settings.name
//   prefixes      = var.global_settings.prefixes
//   resource_type = "azurerm_cognitive_deployment"
//   random_length = var.global_settings.random_length
//   clean_input   = true
//   passthrough   = var.global_settings.passthrough
//   use_slug      = var.global_settings.use_slug
// }

resource "azurerm_cognitive_account_project" "project" {
  name                 = var.settings.name
  cognitive_account_id = var.cognitive_account_id
  location             = var.location
  description          = try(var.settings.description, null)
  display_name         = try(var.settings.display_name, null)

  dynamic "identity" {
    for_each = lookup(var.settings, "identity", {}) != {} ? [1] : []
    content {
      type         = lookup(var.settings.identity, "type", null)
      identity_ids = can(var.settings.identity.ids) ? var.settings.identity.ids : can(var.settings.identity.key) ? [var.remote_objects.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.identity.key].id] : null
    }
  }

  tags = var.tags

}
