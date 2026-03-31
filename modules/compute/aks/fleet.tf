module "kubernetes_fleet_members" {
  source = "../../kubernetes_fleet_managers/fleet_members"
  count  = try(var.settings.fleet_manager, null) == null ? 0 : 1

  global_settings = var.global_settings
  client_config   = var.client_config
  settings        = var.settings.fleet_manager
  name            = azurerm_kubernetes_cluster.aks.name
  aks_cluster     = azurerm_kubernetes_cluster.aks
  fleet_manager   = var.fleet_manager
}
