resource "azurerm_kubernetes_fleet_manager" "kfm" {
  name                = var.settings.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
