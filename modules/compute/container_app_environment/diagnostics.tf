module "diagnostics" {
  source = "../../diagnostics"

  resource_id       = azurerm_container_app_environment.cae.id
  resource_location = azurerm_container_app_environment.cae.location
  diagnostics       = var.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}